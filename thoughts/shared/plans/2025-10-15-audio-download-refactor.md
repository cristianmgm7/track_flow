# Audio Download & Cache Separation Implementation Plan

## Overview

This plan refactors the audio download system to properly separate caching (for playback) from downloading (for export). Currently, the "download" feature is just a thin wrapper around the cache system that shares files with UUID-based filenames. This implementation will add proper download functionality with user-friendly filenames, permission-based access control, and support for downloading both active versions and specific versions.

## Current State Analysis

### Key Issues Identified

1. **No Download Permission**: Any user with track access can "download" (cache + share) files
2. **Poor Filename UX**: Users see UUID filenames (`8a7f9d2b-3c1e-4f6a-9b8d-7e5c4a3f2d1b.mp3`) instead of track names
3. **Confusing UX**: Download requires two taps if file isn't cached (download, then retry)
4. **No Version Selection**: Can only download active version from track actions
5. **Cache/Download Conflation**: No distinction between caching for playback vs exporting for download

### What Currently Works

- **File extension preservation**: Cache system correctly preserves original extensions (`.mp3`, `.wav`, `.m4a`, etc.)
- **Cache naming**: Files stored as `{trackId}/{versionId}.{ext}` in `/Documents/trackflow/audio/tracks/`
- **Metadata storage**: `AudioTrackDTO.extension` (line 13) stores the extension
- **Track name available**: `AudioTrack.name` contains user-provided track title
- **Version metadata**: `TrackVersion.versionNumber` and `TrackVersion.label` available
- **Permission system**: Robust permission checking pattern exists throughout the app

### Current File Structure

**Cache Storage** (`audio_storage_repository_impl.dart:48-53`):
```
/Documents/trackflow/audio/tracks/
  └── {trackId}/
      └── {versionId}.mp3
```

**Metadata Available**:
- `AudioTrack.name` - Track title (e.g., "My Awesome Beat")
- `AudioTrackDTO.extension` - File extension (e.g., ".mp3")
- `TrackVersion.versionNumber` - Version number (e.g., 2)
- `TrackVersion.label` - Optional label (e.g., "Final Mix")

## Desired End State

### Key Features

1. **Permission-Based Downloads**: New `downloadTrack` permission in `ProjectPermission` enum
2. **User-Friendly Filenames**: Format `"{trackName}_v{versionNumber}.{ext}"` (e.g., `"My_Awesome_Beat_v2.mp3"`)
3. **Share Sheet Export**: Use native share sheet with temporary file copy having proper filename
4. **Dual Download Entry Points**:
   - Track actions menu: Downloads active version
   - Version actions menu: Downloads specific version
5. **Permission Checking**: UI gates download actions, domain validates permissions
6. **Clean Architecture**: Dedicated `DownloadTrackUseCase` following existing patterns
7. **Shared Cache**: Reuse cache storage, create temporary copy with friendly name for sharing

### Verification

- User with Viewer role cannot see Download action
- User with Editor+ role sees Download action
- Downloaded file has format: `Track_Name_v2.mp3` (not UUID)
- Download works for both active version and specific versions
- Permission denied throws `ProjectPermissionException`
- Share sheet opens with proper filename
- Tests pass for permission validation

## What We're NOT Doing

- ❌ Creating separate download storage (reusing cache)
- ❌ Implementing platform-specific download folders (using share sheet for all platforms)
- ❌ Adding download history or management UI
- ❌ Supporting quality/format conversion
- ❌ Batch downloads
- ❌ Background download notifications
- ❌ Download progress tracking (assuming file is cached or caches quickly)
- ❌ Preserving original uploaded filename (using track title instead)

## Implementation Approach

We'll follow TrackFlow's Clean Architecture + DDD pattern:

1. **Domain Layer**: Add permission, create use case, define repository contract
2. **Data Layer**: Implement filename generation and temporary file creation
3. **Presentation Layer**: Update BLoC, modify UI actions, add permission gates
4. **Testing**: Unit tests for domain logic, permission validation

The implementation reuses the existing cache system and creates temporary files with user-friendly names only during the share operation.

---

## Phase 1: Domain Layer - Permission & Use Case

### Overview
Add the `downloadTrack` permission to the domain layer and create a dedicated use case for downloading tracks with proper permission validation and filename generation.

### Changes Required

#### 1. Add Download Permission
**File**: `lib/features/projects/domain/value_objects/project_permission.dart`
**Changes**: Add new permission to enum

```dart
enum ProjectPermission {
  // premisions for project
  editProject,
  deleteProject,
  // premisions for collaborators
  addCollaborator,
  removeCollaborator,
  updateCollaboratorRole,
  // premisions for tracks
  addTrack,
  editTrack,
  deleteTrack,
  downloadTrack,  // ← ADD THIS
  // premisions for comments
  addComment,
  editComment,
  deleteComment,
  // premisions for project tasks
  addTask,
  editTask,
  deleteTask,
  // premisions for project files
  addFile,
  editFile,
  deleteFile,
}
```

**Rationale**: Separates download permission from edit/delete permissions, allowing granular control.

---

#### 2. Update Role Permission Matrix
**File**: `lib/features/projects/domain/entities/project_collaborator.dart`
**Changes**: Add `downloadTrack` to role permission lists

**Line 58-98**: Update `hasPermission()` method:

```dart
bool hasPermission(ProjectPermission p) {
  if (specificPermissions.contains(p)) return true;

  switch (role.value) {
    case ProjectRoleType.owner:
      return true;
    case ProjectRoleType.admin:
      return [
        ProjectPermission.editProject,
        ProjectPermission.addCollaborator,
        ProjectPermission.removeCollaborator,
        ProjectPermission.updateCollaboratorRole,
        ProjectPermission.addTrack,
        ProjectPermission.editTrack,
        ProjectPermission.deleteTrack,
        ProjectPermission.downloadTrack,  // ← ADD THIS
        ProjectPermission.addComment,
        ProjectPermission.editComment,
        ProjectPermission.deleteComment,
        ProjectPermission.addTask,
        ProjectPermission.editTask,
        ProjectPermission.deleteTask,
        ProjectPermission.addFile,
        ProjectPermission.editFile,
        ProjectPermission.deleteFile,
      ].contains(p);
    case ProjectRoleType.editor:
      return [
        ProjectPermission.addTrack,
        ProjectPermission.editTrack,
        ProjectPermission.downloadTrack,  // ← ADD THIS
        ProjectPermission.addComment,
        ProjectPermission.editComment,
        ProjectPermission.addTask,
        ProjectPermission.editTask,
        ProjectPermission.addFile,
        ProjectPermission.editFile,
      ].contains(p);
    case ProjectRoleType.viewer:
      return false;  // Viewers cannot download
  }
}
```

**Rationale**: Editors and Admins can download; Viewers cannot (aligns with your business model).

---

#### 3. Create Download Track Use Case
**File**: `lib/features/audio_track/domain/usecases/download_track_usecase.dart` (NEW FILE)
**Changes**: Create new use case

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

/// Downloads a track version with user-friendly filename for sharing
@injectable
class DownloadTrackUseCase {
  final AudioStorageRepository _audioStorageRepository;
  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;
  final ProjectsRepository _projectsRepository;
  final SessionService _sessionService;

  DownloadTrackUseCase({
    required AudioStorageRepository audioStorageRepository,
    required AudioTrackRepository audioTrackRepository,
    required TrackVersionRepository trackVersionRepository,
    required ProjectsRepository projectsRepository,
    required SessionService sessionService,
  })  : _audioStorageRepository = audioStorageRepository,
        _audioTrackRepository = audioTrackRepository,
        _trackVersionRepository = trackVersionRepository,
        _projectsRepository = projectsRepository,
        _sessionService = sessionService;

  /// Downloads track version and returns path to temporary file with friendly name
  ///
  /// Returns:
  /// - Right(filePath): Path to temporary file ready for sharing
  /// - Left(Failure): Permission error, cache error, or track not found
  Future<Either<Failure, String>> call({
    required String trackId,
    String? versionId, // If null, uses active version
  }) async {
    try {
      // 1. Get current user
      final userId = await _sessionService.getUserId();
      if (userId == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // 2. Get track
      final trackResult = await _audioTrackRepository.getTrackById(
        AudioTrackId.fromUniqueString(trackId),
      );
      if (trackResult.isLeft()) {
        return left(const ServerFailure('Track not found'));
      }
      final track = trackResult.getOrElse(() => throw Exception('Unreachable'));

      // 3. Get project and check permission
      final projectResult = await _projectsRepository.getProjectById(
        track.projectId,
      );
      if (projectResult.isLeft()) {
        return left(const ServerFailure('Project not found'));
      }
      final project = projectResult.getOrElse(() => throw Exception('Unreachable'));

      final currentUserCollaborator = project.collaborators.firstWhere(
        (c) => c.userId.value == userId,
        orElse: () => throw const UserNotCollaboratorException(),
      );

      if (!currentUserCollaborator.hasPermission(ProjectPermission.downloadTrack)) {
        return left(const ProjectPermissionException());
      }

      // 4. Determine version to download
      final targetVersionId = versionId ?? track.activeVersionId?.value;
      if (targetVersionId == null) {
        return left(const ServerFailure('No version available for download'));
      }

      // 5. Get cached audio path
      final cachedPathResult = await _audioStorageRepository.getCachedAudioPath(
        AudioTrackId.fromUniqueString(trackId),
        versionId: TrackVersionId.fromUniqueString(targetVersionId),
      );

      if (cachedPathResult.isLeft()) {
        return left(const ServerFailure('Track not cached yet'));
      }
      final cachedPath = cachedPathResult.getOrElse(() => throw Exception('Unreachable'));

      // 6. Get version info for filename
      final versionResult = await _trackVersionRepository.getVersionById(
        TrackVersionId.fromUniqueString(targetVersionId),
      );
      if (versionResult.isLeft()) {
        return left(const ServerFailure('Version not found'));
      }
      final version = versionResult.getOrElse(() => throw Exception('Unreachable'));

      // 7. Generate user-friendly filename
      final extension = _getExtensionFromPath(cachedPath);
      final sanitizedName = _sanitizeFilename(track.name);
      final friendlyFilename = '${sanitizedName}_v${version.versionNumber}$extension';

      // 8. Create temporary copy with friendly name
      final cachedFile = File(cachedPath);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$friendlyFilename');

      // Remove old temp file if exists
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // Copy to temp with friendly name
      await cachedFile.copy(tempFile.path);

      return right(tempFile.path);
    } on ProjectPermissionException catch (_) {
      return left(const ProjectPermissionException());
    } on UserNotCollaboratorException catch (_) {
      return left(const UserNotCollaboratorException());
    } catch (e) {
      return left(ServerFailure('Download failed: $e'));
    }
  }

  /// Extract file extension from path
  String _getExtensionFromPath(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '.mp3';
    return path.substring(lastDot).toLowerCase();
  }

  /// Sanitize filename for filesystem compatibility
  /// Replaces spaces with underscores, removes special characters
  String _sanitizeFilename(String name) {
    // Replace spaces with underscores
    var sanitized = name.replaceAll(' ', '_');

    // Remove or replace special characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

    // Limit length to 100 characters
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized;
  }
}
```

**Rationale**:
- Follows existing use case patterns (permission check, repository coordination)
- Creates temporary file with friendly name only when needed
- Reuses cache system (no duplicate storage)
- Returns temporary file path for sharing

---

### Success Criteria

#### Automated Verification:
- [x] Code compiles: `flutter analyze`
- [ ] Dependency injection generates: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Unit tests pass: `flutter test test/features/audio_track/domain/usecases/download_track_usecase_test.dart`

#### Manual Verification:
- [x] Permission enum includes `downloadTrack`
- [x] Editor and Admin roles have `downloadTrack` permission
- [x] Viewer role does NOT have `downloadTrack` permission
- [ ] Use case is registered in DI container

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the tests were successful before proceeding to Phase 2.

---

## Phase 2: Data Layer - Repository Enhancement

### Overview
Enhance the audio track repository to support getting track metadata needed for downloads. No new repository is needed - we're just adding helper methods.

### Changes Required

#### 1. Add Track Metadata Helper
**File**: `lib/features/audio_track/domain/repositories/audio_track_repository.dart`
**Changes**: Document that `getTrackById` provides all needed metadata

**No code changes needed** - existing `getTrackById` method already returns complete `AudioTrack` entity with name and all metadata.

---

#### 2. Ensure Version Repository Method Exists
**File**: `lib/features/track_version/domain/repositories/track_version_repository.dart`
**Changes**: Verify `getVersionById` method exists

Check if method exists around line 20-30. If not present, add:

```dart
/// Get track version by ID
Future<Either<Failure, TrackVersion>> getVersionById(TrackVersionId versionId);
```

**Then implement in**: `lib/features/track_version/data/repositories/track_version_repository_impl.dart`

```dart
@override
Future<Either<Failure, TrackVersion>> getVersionById(
  TrackVersionId versionId,
) async {
  try {
    final localResult = await _localDataSource.getVersionById(versionId.value);
    return localResult.fold(
      (failure) => Left(failure),
      (doc) {
        if (doc == null) {
          return Left(ServerFailure('Version not found'));
        }
        return Right(doc.toDomain());
      },
    );
  } catch (e) {
    return Left(ServerFailure('Failed to get version: $e'));
  }
}
```

**Add to local datasource**: `lib/features/track_version/data/datasources/track_version_local_data_source.dart`

```dart
Future<Either<Failure, TrackVersionDocument?>> getVersionById(String versionId) async {
  try {
    final doc = await _isar.trackVersionDocuments
        .filter()
        .idEqualTo(versionId)
        .findFirst();
    return Right(doc);
  } catch (e) {
    return Left(CacheFailure('Failed to get version: $e'));
  }
}
```

**Rationale**: Use case needs version metadata (version number) to generate filename.

---

### Success Criteria

#### Automated Verification:
- [x] Code compiles: `flutter analyze`
- [x] Repository methods callable from use case
- [ ] Unit tests pass for repository: `flutter test test/features/track_version/data/repositories/`

#### Manual Verification:
- [x] `getById` returns version entity with `versionNumber` field
- [x] Method follows existing repository patterns

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 3.

---

## Phase 3: Presentation Layer - BLoC Events & States

### Overview
Add download events and states to the TrackCacheBloc (reusing existing BLoC since download uses cache system).

### Changes Required

#### 1. Add Download Events
**File**: `lib/features/audio_cache/presentation/bloc/track_cache_event.dart`
**Changes**: Add new event for download request

Add after existing events (around line 50):

```dart
/// Request to download track with friendly filename
class DownloadTrackRequested extends TrackCacheEvent {
  final String trackId;
  final String? versionId; // null = active version

  const DownloadTrackRequested({
    required this.trackId,
    this.versionId,
  });

  @override
  List<Object?> get props => [trackId, versionId];
}
```

**Rationale**: Separate event for download distinguishes it from caching in BLoC logic.

---

#### 2. Add Download States
**File**: `lib/features/audio_cache/presentation/bloc/track_cache_state.dart`
**Changes**: Add states for download success/failure

Add after existing states (around line 70):

```dart
/// Download ready - file path with friendly name for sharing
class TrackDownloadReady extends TrackCacheState {
  final String trackId;
  final String filePath; // Path to temp file with friendly name

  const TrackDownloadReady({
    required this.trackId,
    required this.filePath,
  });

  @override
  List<Object> get props => [trackId, filePath];
}

/// Download failed - either permission denied or file not ready
class TrackDownloadFailure extends TrackCacheState {
  final String trackId;
  final String error;
  final bool isPermissionError;

  const TrackDownloadFailure({
    required this.trackId,
    required this.error,
    this.isPermissionError = false,
  });

  @override
  List<Object> get props => [trackId, error, isPermissionError];
}
```

**Rationale**: Separate states allow UI to handle permission errors differently from cache errors.

---

#### 3. Add Download Event Handler to BLoC
**File**: `lib/features/audio_cache/presentation/bloc/track_cache_bloc.dart`
**Changes**: Add event handler and use case injection

**Add to constructor** (around line 20):

```dart
final DownloadTrackUseCase _downloadTrackUseCase;

TrackCacheBloc({
  // ... existing parameters
  required DownloadTrackUseCase downloadTrackUseCase,
})  : // ... existing initializations
      _downloadTrackUseCase = downloadTrackUseCase,
      super(TrackCacheInitial()) {
  // ... existing event handlers
  on<DownloadTrackRequested>(_onDownloadTrackRequested);
}
```

**Add event handler method** (around line 150):

```dart
Future<void> _onDownloadTrackRequested(
  DownloadTrackRequested event,
  Emitter<TrackCacheState> emit,
) async {
  emit(TrackCacheOperationInProgress(trackId: event.trackId));

  final result = await _downloadTrackUseCase(
    trackId: event.trackId,
    versionId: event.versionId,
  );

  emit(
    result.fold(
      (failure) {
        final isPermissionError = failure is ProjectPermissionException;
        return TrackDownloadFailure(
          trackId: event.trackId,
          error: failure.message,
          isPermissionError: isPermissionError,
        );
      },
      (filePath) => TrackDownloadReady(
        trackId: event.trackId,
        filePath: filePath,
      ),
    ),
  );
}
```

**Rationale**: BLoC coordinates use case call and emits appropriate states for UI to handle.

---

### Success Criteria

#### Automated Verification:
- [x] Code compiles: `flutter analyze`
- [ ] BLoC tests pass: `flutter test test/features/audio_cache/presentation/bloc/`
- [x] Event/State equality works correctly

#### Manual Verification:
- [x] Events extend `TrackCacheEvent` properly
- [x] States extend `TrackCacheState` properly
- [x] BLoC handler calls use case correctly

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 4.

---

## Phase 4: UI Layer - Track Actions Menu

### Overview
Update the track actions menu to use the new download system with permission checking and proper filename handling.

### Changes Required

#### 1. Update Track Download Action
**File**: `lib/features/audio_track/presentation/widgets/audio_track_actions.dart`
**Changes**: Replace current download implementation (lines 77-144)

**Replace lines 77-144** with:

```dart
AppBottomSheetAction(
  icon: Icons.download,
  title: 'Download',
  subtitle: 'Save this track to your device',
  onTap: () async {
    final bloc = context.read<TrackCacheBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Close bottom sheet first
    navigator.pop();

    // Request download (will check permissions and generate friendly filename)
    bloc.add(DownloadTrackRequested(
      trackId: track.id.value,
      versionId: null, // null = active version
    ));

    // Listen for download result
    final subscription = bloc.stream.listen((state) {
      if (state is TrackDownloadReady && state.trackId == track.id.value) {
        // Download ready - open share sheet
        Share.shareXFiles([
          XFile(state.filePath),
        ], text: 'Download ${track.name}');
      } else if (state is TrackDownloadFailure && state.trackId == track.id.value) {
        // Download failed
        final message = state.isPermissionError
            ? 'You do not have permission to download this track'
            : state.error;

        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: state.isPermissionError ? Colors.red : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (state is TrackCacheOperationInProgress &&
                 state.trackId == track.id.value) {
        // Show preparing message
        messenger.showSnackBar(
          SnackBar(
            content: Text('Preparing ${track.name} for download...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    // Auto-cancel subscription after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  },
),
```

**Rationale**:
- Simplified flow - single tap downloads
- Shows preparing message while working
- Handles permission errors with clear messaging
- File has friendly name when shared

---

#### 2. Add Permission Gate to Track Actions
**File**: `lib/features/audio_track/presentation/widgets/audio_track_actions.dart`
**Changes**: Gate download action with permission check

**Modify the static method signature** (line 20) to accept project:

```dart
static List<AppBottomSheetAction> forTrack(
  BuildContext context,
  ProjectId projectId,
  AudioTrack track,
  Project project, // ← ADD THIS
)
```

**Then wrap download action conditionally** (before the download action):

```dart
// Check if user has download permission
final userState = context.watch<UserProfileBloc>().state;
final String? currentUserId =
    userState is UserProfileLoaded ? userState.profile.id.value : null;
bool canDownload = false;
if (currentUserId != null) {
  final me = project.collaborators.firstWhere(
    (c) => c.userId.value == currentUserId,
    orElse: () => ProjectCollaborator.create(
      userId: UserId.fromUniqueString(currentUserId),
      role: ProjectRole.viewer,
    ),
  );
  canDownload = me.hasPermission(ProjectPermission.downloadTrack);
}

// Add download action only if user has permission
if (canDownload)
  AppBottomSheetAction(
    // ... download action code from above
  ),
```

**Update all call sites** to pass project parameter. Find usages with:

```dart
TrackActions.forTrack(context, projectId, track)
```

And change to:

```dart
TrackActions.forTrack(context, projectId, track, project)
```

**Rationale**: UI-level gate prevents unauthorized users from seeing download option at all.

---

### Success Criteria

#### Automated Verification:
- [x] Code compiles: `flutter analyze`
- [x] All TrackActions.forTrack call sites updated
- [ ] Widget tests pass: `flutter test test/features/audio_track/presentation/widgets/`

#### Manual Verification:
- [ ] Viewer role does NOT see Download action
- [ ] Editor role DOES see Download action
- [ ] Tapping Download shows "Preparing..." message
- [ ] Share sheet opens with filename like "Track_Name_v2.mp3"
- [ ] Permission denied shows red error message

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 5.

---

## Phase 5: UI Layer - Version Actions Menu

### Overview
Add download action to the version-specific actions menu, allowing users to download specific versions (not just active version).

### Changes Required

#### 1. Add Download Action to Version Menu
**File**: `lib/features/track_version/presentation/widgets/track_detail_actions_sheet.dart`
**Changes**: Add download action to version actions

**Modify static method signature** (line 12) to accept track and project:

```dart
static List<AppBottomSheetAction> forVersion(
  BuildContext context,
  AudioTrackId trackId,
  TrackVersionId versionId,
  AudioTrack track, // ← ADD THIS
  Project project,  // ← ADD THIS
)
```

**Add download action** (after "Set as Active", before "Rename Label"):

```dart
// Check download permission
final userState = context.watch<UserProfileBloc>().state;
final String? currentUserId =
    userState is UserProfileLoaded ? userState.profile.id.value : null;
bool canDownload = false;
if (currentUserId != null) {
  final me = project.collaborators.firstWhere(
    (c) => c.userId.value == currentUserId,
    orElse: () => ProjectCollaborator.create(
      userId: UserId.fromUniqueString(currentUserId),
      role: ProjectRole.viewer,
    ),
  );
  canDownload = me.hasPermission(ProjectPermission.downloadTrack);
}

// Add download action if permitted
if (canDownload)
  AppBottomSheetAction(
    icon: Icons.download,
    title: 'Download Version',
    subtitle: 'Save this version to your device',
    onTap: () async {
      final bloc = context.read<TrackCacheBloc>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      // Close bottom sheet first
      navigator.pop();

      // Request download for specific version
      bloc.add(DownloadTrackRequested(
        trackId: trackId.value,
        versionId: versionId.value, // ← Specific version
      ));

      // Listen for download result
      final subscription = bloc.stream.listen((state) {
        if (state is TrackDownloadReady && state.trackId == trackId.value) {
          // Download ready - open share sheet
          Share.shareXFiles([
            XFile(state.filePath),
          ], text: 'Download ${track.name}');
        } else if (state is TrackDownloadFailure && state.trackId == trackId.value) {
          // Download failed
          final message = state.isPermissionError
              ? 'You do not have permission to download this version'
              : state.error;

          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: state.isPermissionError ? Colors.red : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is TrackCacheOperationInProgress &&
                   state.trackId == trackId.value) {
          // Show preparing message
          messenger.showSnackBar(
            SnackBar(
              content: Text('Preparing version for download...'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });

      // Auto-cancel subscription after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        subscription.cancel();
      });
    },
  ),
```

**Update all call sites** - Find usages of `TrackDetailActions.forVersion` and add track and project parameters:

```dart
// Before
TrackDetailActions.forVersion(context, trackId, versionId)

// After
TrackDetailActions.forVersion(context, trackId, versionId, track, project)
```

**Rationale**: Provides version-specific download capability as requested.

---

### Success Criteria

#### Automated Verification:
- [x] Code compiles: `flutter analyze`
- [x] All TrackDetailActions.forVersion call sites updated
- [ ] Widget tests pass

#### Manual Verification:
- [ ] Version actions menu shows "Download Version" for Editor+
- [ ] Version actions menu does NOT show download for Viewer
- [ ] Downloaded file has correct version number in filename
- [ ] Downloading version 3 creates "Track_Name_v3.mp3"

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 6.

---

## Phase 6: Testing & Validation

### Overview
Add comprehensive tests for permission validation, filename generation, and download flow.

### Changes Required

#### 1. Create Use Case Tests
**File**: `test/features/audio_track/domain/usecases/download_track_usecase_test.dart` (NEW FILE)
**Changes**: Create comprehensive unit tests

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_track/domain/usecases/download_track_usecase.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';

@GenerateMocks([
  AudioStorageRepository,
  AudioTrackRepository,
  TrackVersionRepository,
  ProjectsRepository,
  SessionService,
])
import 'download_track_usecase_test.mocks.dart';

void main() {
  late DownloadTrackUseCase useCase;
  late MockAudioStorageRepository mockAudioStorageRepository;
  late MockAudioTrackRepository mockAudioTrackRepository;
  late MockTrackVersionRepository mockTrackVersionRepository;
  late MockProjectsRepository mockProjectsRepository;
  late MockSessionService mockSessionService;

  late AudioTrackId trackId;
  late TrackVersionId versionId;
  late UserId userId;
  late ProjectId projectId;

  setUp(() {
    mockAudioStorageRepository = MockAudioStorageRepository();
    mockAudioTrackRepository = MockAudioTrackRepository();
    mockTrackVersionRepository = MockTrackVersionRepository();
    mockProjectsRepository = MockProjectsRepository();
    mockSessionService = MockSessionService();

    useCase = DownloadTrackUseCase(
      audioStorageRepository: mockAudioStorageRepository,
      audioTrackRepository: mockAudioTrackRepository,
      trackVersionRepository: mockTrackVersionRepository,
      projectsRepository: mockProjectsRepository,
      sessionService: mockSessionService,
    );

    trackId = AudioTrackId();
    versionId = TrackVersionId();
    userId = UserId();
    projectId = ProjectId();
  });

  group('DownloadTrackUseCase', () {
    test('should return file path when user has download permission', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'My Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final version = TrackVersion(
        id: versionId,
        trackId: trackId,
        versionNumber: 2,
        label: null,
        fileLocalPath: null,
        fileRemoteUrl: 'https://example.com/audio.mp3',
        durationMs: 180000,
        status: TrackVersionStatus.ready,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project.create(
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        collaborators: [collaborator],
      );

      when(mockSessionService.getUserId()).thenAnswer((_) async => userId.value);
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => const Right('/cache/path/version123.mp3'));
      when(mockTrackVersionRepository.getVersionById(versionId))
          .thenAnswer((_) async => Right(version));

      // Act
      final result = await useCase(trackId: trackId.value, versionId: versionId.value);

      // Assert
      expect(result.isRight(), true);
      final filePath = result.getOrElse(() => '');
      expect(filePath, contains('My_Test_Track_v2.mp3'));
    });

    test('should return ProjectPermissionException when user is viewer', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final viewerCollaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.viewer, // ← Viewer role
      );

      final project = Project.create(
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: UserId(),
        collaborators: [viewerCollaborator],
      );

      when(mockSessionService.getUserId()).thenAnswer((_) async => userId.value);
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));

      // Act
      final result = await useCase(trackId: trackId.value);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ProjectPermissionException>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should sanitize filenames correctly', () async {
      // Arrange - Track name with special characters
      final track = AudioTrack(
        id: trackId,
        name: 'Track: Name/With\\Special*Chars',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final version = TrackVersion(
        id: versionId,
        trackId: trackId,
        versionNumber: 1,
        label: null,
        fileLocalPath: null,
        fileRemoteUrl: 'https://example.com/audio.mp3',
        durationMs: 180000,
        status: TrackVersionStatus.ready,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project.create(
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        collaborators: [collaborator],
      );

      when(mockSessionService.getUserId()).thenAnswer((_) async => userId.value);
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => const Right('/cache/path/version123.mp3'));
      when(mockTrackVersionRepository.getVersionById(versionId))
          .thenAnswer((_) async => Right(version));

      // Act
      final result = await useCase(trackId: trackId.value, versionId: versionId.value);

      // Assert
      expect(result.isRight(), true);
      final filePath = result.getOrElse(() => '');
      // Should remove special chars and replace spaces
      expect(filePath, contains('Track_NameWithSpecialChars_v1.mp3'));
    });

    test('should return error when track not cached', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project.create(
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        collaborators: [collaborator],
      );

      when(mockSessionService.getUserId()).thenAnswer((_) async => userId.value);
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => Left(
        StorageCacheFailure(
          message: 'File not cached',
          type: StorageFailureType.fileNotFound,
        ),
      ));

      // Act
      final result = await useCase(trackId: trackId.value);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('not cached')),
        (_) => fail('Should have returned failure'),
      );
    });
  });
}
```

**Run mock generation**:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Rationale**: Tests cover permission validation, filename sanitization, and error cases.

---

#### 2. Update Permission Tests
**File**: `test/features/projects/domain/entities/project_collaborator_test.dart`
**Changes**: Add test for downloadTrack permission

```dart
test('should grant downloadTrack permission to editor', () {
  // Arrange
  final editor = ProjectCollaborator.create(
    userId: UserId(),
    role: ProjectRole.editor,
  );

  // Act
  final hasPermission = editor.hasPermission(ProjectPermission.downloadTrack);

  // Assert
  expect(hasPermission, true);
});

test('should deny downloadTrack permission to viewer', () {
  // Arrange
  final viewer = ProjectCollaborator.create(
    userId: UserId(),
    role: ProjectRole.viewer,
  );

  // Act
  final hasPermission = viewer.hasPermission(ProjectPermission.downloadTrack);

  // Assert
  expect(hasPermission, false);
});
```

---

### Success Criteria

#### Automated Verification:
- [ ] All unit tests pass: `flutter test`
- [ ] Code coverage for use case: `flutter test --coverage`
- [ ] Mock generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Linting passes: `flutter analyze`

#### Manual Verification:
- [ ] Permission tests verify Editor can download, Viewer cannot
- [ ] Filename sanitization tests pass
- [ ] Error handling tests pass (track not cached, permission denied)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for final manual testing before considering the feature complete.

---

## Phase 7: Documentation & Cleanup

### Overview
Add inline documentation and update relevant comments to explain the download system.

### Changes Required

#### 1. Add Use Case Documentation
**File**: `lib/features/audio_track/domain/usecases/download_track_usecase.dart`
**Changes**: Ensure class and method have comprehensive doc comments (already included in Phase 1)

---

#### 2. Update CLAUDE.md
**File**: `CLAUDE.md`
**Changes**: Document the download system

Add section under "Core Systems":

```markdown
### Download System
- Permission-based download with `ProjectPermission.downloadTrack`
- Reuses cache storage - creates temporary copy with friendly filename
- Filename format: `{trackName}_v{versionNumber}.{ext}`
- Share sheet export for cross-platform support
- Dual entry points: Track actions (active version) and Version actions (specific version)
- Editor and Admin roles can download; Viewer cannot
```

---

### Success Criteria

#### Automated Verification:
- [x] Documentation builds without warnings
- [x] Code has no TODO/FIXME comments related to download

#### Manual Verification:
- [x] CLAUDE.md updated with download system documentation
- [x] Use case has clear doc comments
- [x] Code is readable and well-documented

---

## Testing Strategy

### Unit Tests

**Download Use Case Tests** (`download_track_usecase_test.dart`):
- ✅ Editor can download track
- ✅ Admin can download track
- ✅ Viewer cannot download track (returns ProjectPermissionException)
- ✅ Filename sanitization removes special characters
- ✅ Filename sanitization replaces spaces with underscores
- ✅ Error when track not cached
- ✅ Error when version not found
- ✅ Error when user not authenticated
- ✅ Active version used when versionId is null
- ✅ Specific version used when versionId provided

**Permission Tests** (`project_collaborator_test.dart`):
- ✅ Owner has downloadTrack permission
- ✅ Admin has downloadTrack permission
- ✅ Editor has downloadTrack permission
- ✅ Viewer does NOT have downloadTrack permission

### Integration Tests

**Download Flow** (manual testing):
1. Login as Editor
2. Open track actions menu
3. Verify "Download" appears
4. Tap Download
5. Verify "Preparing..." message appears
6. Verify share sheet opens with filename "Track_Name_v2.mp3"
7. Verify file can be saved

**Permission Blocking** (manual testing):
1. Login as Viewer
2. Open track actions menu
3. Verify "Download" does NOT appear
4. If somehow triggered (via API), verify permission error message

**Version Download** (manual testing):
1. Login as Editor
2. Navigate to track detail with multiple versions
3. Open version actions menu for version 3
4. Verify "Download Version" appears
5. Tap Download Version
6. Verify filename is "Track_Name_v3.mp3" (not active version)

### Manual Testing Steps

1. **Viewer Permission Test**:
   - [ ] Login as user with Viewer role
   - [ ] Open track actions menu
   - [ ] Confirm "Download" action is NOT visible
   - [ ] Try accessing via deep link (should show permission error)

2. **Editor Download Test**:
   - [ ] Login as user with Editor role
   - [ ] Open track actions menu
   - [ ] Confirm "Download" action IS visible
   - [ ] Tap Download
   - [ ] Verify preparing message shows
   - [ ] Verify share sheet opens
   - [ ] Verify filename format: "Track_Name_v2.mp3"
   - [ ] Save file to device
   - [ ] Play file to confirm it's correct audio

3. **Version-Specific Download Test**:
   - [ ] Login as Editor
   - [ ] Navigate to track with multiple versions
   - [ ] Open version 3 actions menu
   - [ ] Tap "Download Version"
   - [ ] Verify filename is "Track_Name_v3.mp3"
   - [ ] Confirm correct version downloaded (not active)

4. **Filename Sanitization Test**:
   - [ ] Create track with name: "Track: Name/With\\Special*Chars"
   - [ ] Download track
   - [ ] Verify filename: "Track_NameWithSpecialChars_v1.mp3"

5. **Cache Integration Test**:
   - [ ] Clear app cache
   - [ ] Try to download uncached track
   - [ ] Verify error message: "Track not cached yet"
   - [ ] Play track to trigger caching
   - [ ] Try download again
   - [ ] Verify success

6. **Performance Test**:
   - [ ] Download track (cached)
   - [ ] Time from tap to share sheet: < 2 seconds
   - [ ] Download large track (50MB+)
   - [ ] Verify no UI blocking

## Performance Considerations

### Memory Usage
- Temporary files created in system temp directory
- Files automatically cleaned by OS
- No long-term storage impact (reuses cache)

### Network Usage
- Zero additional network usage (reuses cached files)
- If track not cached, uses existing cache download flow
- No duplicate downloads

### Storage Impact
- Temporary copy created only during share operation
- Temp file size = cached file size (no compression/decompression)
- Temp files cleaned up by OS or on next app restart

### UI Responsiveness
- File copy operation runs on background thread (async)
- "Preparing..." message shows immediately
- Share sheet opens within 1-2 seconds for typical 10MB file

## Migration Notes

### Database Migration
**Not required** - no schema changes needed.

### Existing Data
- All existing cached files remain valid
- No re-caching needed
- Users can immediately download existing cached tracks

### Backward Compatibility
- Old "download" behavior (cache + share with UUID) is completely replaced
- No version migration needed
- All platforms supported (iOS, Android)

### Breaking Changes
**None** - this is purely additive:
- New permission added (defaults to false for Viewer)
- New use case added
- Existing cache system unchanged

## References

### Original Task Description
- File extensions & naming investigation
- Download permissions & separation of concerns
- Clean architecture integration
- Expected outcome: clear distinction between caching and downloading

### Key Files Modified
- `lib/features/projects/domain/value_objects/project_permission.dart` - Added `downloadTrack`
- `lib/features/projects/domain/entities/project_collaborator.dart` - Added permission to roles
- `lib/features/audio_track/domain/usecases/download_track_usecase.dart` - New use case
- `lib/features/audio_cache/presentation/bloc/track_cache_event.dart` - Added `DownloadTrackRequested`
- `lib/features/audio_cache/presentation/bloc/track_cache_state.dart` - Added download states
- `lib/features/audio_cache/presentation/bloc/track_cache_bloc.dart` - Added event handler
- `lib/features/audio_track/presentation/widgets/audio_track_actions.dart` - Updated download action
- `lib/features/track_version/presentation/widgets/track_detail_actions_sheet.dart` - Added version download

### Related Patterns
- Permission checking: `lib/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart:83-112`
- UI permission gates: `lib/features/project_detail/presentation/components/project_detail_collaborators_component.dart:110-132`
- Use case structure: `lib/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart:40-88`
- Filename handling: `lib/core/utils/audio_format_utils.dart:46-53`
- Cache system: `lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart`

### Architecture Decisions
- **Option A - Permission Model**: Separate `downloadTrack` permission for granular control
- **Option A - Filename Format**: `{trackName}_v{versionNumber}.{ext}` for clarity
- **Option B - Download Approach**: Share sheet with friendly filename (cross-platform)
- **Option B - Cache vs Download**: Shared storage, temporary copy for export
- **Custom - Multiple Versions**: Active version from track actions, specific version from version actions

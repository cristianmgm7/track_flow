/# Unified Cover Art Image System Implementation Plan

## Overview

This plan addresses the offline persistence issue with cover art for Projects and Audio Tracks by creating a unified image system that leverages `CachedNetworkImage` with the existing `DirectoryService` architecture. Currently, track cover arts display placeholder images offline because the `TrackCoverArt` widget uses `Image.network` instead of `CachedNetworkImage`. This plan will consolidate scattered image handling logic into the existing `ImageStorageRepository` pattern and ensure all cover art types persist offline.

## Current State Analysis

### What Works ✅
- **User avatars**: Use `CachedNetworkImage` via `UserAvatar` widget and persist offline
- **Cover art upload flow**: Correctly saves both `coverUrl` (remote) and `coverLocalPath` (local) to Isar
- **Local database**: Both fields persist correctly across app restarts
- **DirectoryService**: Well-defined directory structure for all image types
- **ImageStorageRepository**: Solid architecture for upload/download with compression

### What Doesn't Work ❌
- **Track cover art display**: Uses `Image.network` in `TrackCoverArt` widget (no offline caching)
- **Project cover art display**: UI components don't pass cover art data (commented out/set to null)
- **Audio track sync**: `AudioTrackOperationExecutor` lacks handler for `field: 'coverArt'` case
- **Fragmented utilities**: `ImageUtils` and `FileSystemUtils` duplicate functionality that exists in `ImageStorageRepository`

### Key Discoveries

**Directory Structure** (from `DirectoryService`):
```
{ApplicationDocumentsDirectory}/
├── trackflow/
│   ├── cover_art/
│   │   ├── projects/        # DirectoryType.projectCovers
│   │   └── tracks/          # DirectoryType.trackCovers
└── local_avatars/           # DirectoryType.localAvatars
```

**Field Names** (consistent across Project and AudioTrack):
- `coverUrl`: String? - Remote Firebase Storage URL
- `coverLocalPath`: String? - Local file system path for offline access

**File Naming Convention**:
- Projects: `{projectId}_cover_{timestamp}.webp`
- Tracks: `{trackId}_cover_{timestamp}.webp`

**Critical Issues Found**:
1. `TrackCoverArt` widget uses `Image.network` (lines 136-145 in [track_cover_art.dart](lib/features/ui/track/track_cover_art.dart#L136-L145))
2. Project cover arts not connected to UI ([ProjectComponent:28](lib/features/projects/presentation/components/project_component.dart#L28), [project_detail_sliver_header.dart:79](lib/features/project_detail/presentation/components/project_detail_sliver_header.dart#L79))
3. `AudioTrackOperationExecutor._executeUpdate()` missing `case 'coverArt'` handler ([audio_track_operation_executor.dart:50-87](lib/core/sync/domain/executors/audio_track_operation_executor.dart#L50-L87))

## Desired End State

### Unified Image Display System
- All cover art widgets use `CachedNetworkImage` with consistent configuration
- Single reusable `CoverArtWidget` that handles all cover art types (project/track)
- Proper fallback chain: Local path → Remote URL → Generated placeholder
- Offline persistence works for all cover art types

### Consolidated Image Storage
- Migrate `ImageUtils` functionality into `ImageStorageRepository`
- Remove duplicate file operations from `FileSystemUtils`
- Centralized image lifecycle: pick → compress → save → upload → cache → display

### Complete UI Integration
- Project cover arts displayed in all relevant components
- Track cover arts persist offline and display correctly
- Consistent visual treatment across all image types

### Fixed Sync System
- Audio track cover art updates sync correctly to Firestore
- Cover art field handler in `AudioTrackOperationExecutor`

### Verification
After implementation:
- Upload cover art → go offline → restart app → cover art displays (not placeholder)
- Project cover arts visible in project list and detail screens
- Track cover arts visible in track list and player
- All image operations use centralized utilities

## What We're NOT Doing

- **NOT** changing the dual-field architecture (`coverUrl` + `coverLocalPath`)
- **NOT** modifying the upload use cases for projects/tracks
- **NOT** changing the data models or DTOs
- **NOT** altering the Firestore sync strategy for cover art URLs
- **NOT** migrating user avatar system (working correctly)
- **NOT** implementing image cleanup/garbage collection (future enhancement)
- **NOT** adding image editing features (crop, filters, etc.)

## Implementation Approach

This plan follows a progressive enhancement strategy:
1. **Phase 1**: Fix display layer (widgets) to use `CachedNetworkImage` - immediate offline persistence
2. **Phase 2**: Integrate cover art into UI components - make existing data visible
3. **Phase 3**: Consolidate utilities into `ImageStorageRepository` - eliminate duplication
4. **Phase 4**: Fix sync executor - ensure remote updates work correctly

Each phase is independently testable and provides value. If we stop at Phase 1, cover arts persist offline. If we stop at Phase 2, UX is complete. Phases 3-4 are architectural cleanup.

---

## Phase 1: Fix Cover Art Display Widgets

### Overview
Replace `Image.network` with `CachedNetworkImage` in cover art widgets and create unified, reusable component. This immediately fixes offline persistence.

### Changes Required

#### 1. Update TrackCoverArt Widget
**File**: [lib/features/ui/track/track_cover_art.dart](lib/features/ui/track/track_cover_art.dart)

**Current implementation** (lines 136-145):
```dart
Widget _buildTrackImageCover() {
  return Container(
    child: ClipRRect(
      child: Image.network(  // ❌ No offline caching
        track!.coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingCover(context);
        },
      ),
    ),
  );
}
```

**Change to**:
```dart
import 'package:cached_network_image/cached_network_image.dart';

Widget _buildTrackImageCover() {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: borderRadius ?? AppBorders.medium,
      boxShadow: showShadow ? AppShadows.card : null,
    ),
    child: ClipRRect(
      borderRadius: borderRadius ?? AppBorders.medium,
      child: CachedNetworkImage(  // ✅ Offline caching enabled
        imageUrl: track!.coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingCover(context),
        errorWidget: (context, url, error) => _buildGeneratedCover(context),
      ),
    ),
  );
}
```

**Also update** (lines 110-119):
- `_buildImageCover()` - for explicit `imageUrl` parameter
- Import `package:cached_network_image/cached_network_image.dart` at top

#### 2. Verify ProjectCoverArt Widget
**File**: [lib/features/ui/project/project_cover_art.dart](lib/features/ui/project/project_cover_art.dart)

**Already correct** (lines 55-63) - uses `CachedNetworkImage`:
```dart
CachedNetworkImage(
  imageUrl: imageUrl!,
  width: size,
  height: size,
  fit: BoxFit.cover,
  placeholder: (context, url) => _buildLoadingCover(),
  errorWidget: (context, url, error) => _buildGeneratedCover(),
)
```

**No changes needed** - this widget is already implemented correctly.

#### 3. Update ExpandedTrackInfo Widget
**File**: [lib/features/audio_player/presentation/widgets/expanded_track_info.dart](lib/features/audio_player/presentation/widgets/expanded_track_info.dart)

**Current implementation** (lines 68-77):
```dart
child: albumArt != null
  ? ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(  // ❌ No offline caching
        albumArt,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(...),
      ),
    )
  : Icon(...)
```

**Change to**:
```dart
import 'package:cached_network_image/cached_network_image.dart';

child: albumArt != null
  ? ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(  // ✅ Offline caching enabled
        imageUrl: albumArt,
        width: albumArtSize,
        height: albumArtSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: albumArtSize,
          height: albumArtSize,
          color: AppColors.grey800,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.music_note,
          color: AppColors.primary,
          size: albumArtSize * 0.3,
        ),
      ),
    )
  : Icon(
      Icons.music_note,
      color: AppColors.primary,
      size: albumArtSize * 0.3,
    )
```

### Success Criteria

#### Automated Verification:
- [ ] No build errors after widget updates: `flutter analyze`
- [ ] All imports resolve correctly: `flutter pub get`
- [ ] No widget test failures: `flutter test test/features/ui/`

#### Manual Verification:
- [ ] Upload track cover art → image displays immediately
- [ ] Go offline → track cover art still displays (not placeholder)
- [ ] Restart app offline → track cover art loads from cache
- [ ] Project cover art (when URL provided) displays offline
- [ ] Full-screen player shows cached cover art offline
- [ ] Loading states show proper placeholders
- [ ] Error states show generated fallback images

---

## Phase 2: Integrate Cover Art into UI Components

### Overview
Connect the existing cover art data (stored in entities) to the UI components that display projects and tracks. This makes the cover art visible throughout the app.

### Changes Required

#### 1. Update ProjectComponent
**File**: [lib/features/projects/presentation/components/project_component.dart](lib/features/projects/presentation/components/project_component.dart)

**Current implementation** (lines 25-29):
```dart
return AppProjectCard(
  title: projectName,
  description: projectDescription,
  createdAt: project.createdAt,
  onTap: onTap,
  leading: ProjectCoverArtSizes.large(
    projectName: projectName,
    projectDescription: projectDescription,
    // In the future, we can add: imageUrl: project.coverArtUrl,  // ❌ COMMENTED OUT
  ),
);
```

**Change to**:
```dart
return AppProjectCard(
  title: projectName,
  description: projectDescription,
  createdAt: project.createdAt,
  onTap: onTap,
  leading: ProjectCoverArtSizes.large(
    projectName: projectName,
    projectDescription: projectDescription,
    imageUrl: project.coverUrl,  // ✅ Pass cover art URL
  ),
);
```

**Logic**: The `ProjectCoverArt` widget already has priority handling:
1. If `imageUrl` is local path → use `Image.file`
2. If `imageUrl` is remote URL → use `CachedNetworkImage`
3. If `imageUrl` is null → use generated placeholder

By passing `project.coverUrl`, the widget will automatically handle all cases.

#### 2. Update ProjectDetailSliverHeader
**File**: [lib/features/project_detail/presentation/components/project_detail_sliver_header.dart](lib/features/project_detail/presentation/components/project_detail_sliver_header.dart)

**Current implementation** (lines 76-83):
```dart
ProjectCoverArt(
  projectName: projectName,
  projectDescription: projectDescription,
  imageUrl: null,  // ❌ EXPLICITLY SET TO NULL
  size: expandedHeight,
  showShadow: false,
  borderRadius: BorderRadius.zero,
),
```

**Change to**:
```dart
ProjectCoverArt(
  projectName: projectName,
  projectDescription: projectDescription,
  imageUrl: state.project?.coverUrl,  // ✅ Use actual cover art
  size: expandedHeight,
  showShadow: false,
  borderRadius: BorderRadius.zero,
),
```

**Note**: Access `coverUrl` from the project in state. The BLoC state already includes the full project entity.

#### 3. Verify Track Components
**Files to check**:
- [lib/features/audio_track/presentation/component/track_component.dart:65](lib/features/audio_track/presentation/component/track_component.dart#L65)
- [lib/features/audio_track/presentation/widgets/track_list_item.dart:44](lib/features/audio_track/presentation/widgets/track_list_item.dart#L44)
- [lib/features/dashboard/presentation/widgets/dashboard_track_card.dart:42](lib/features/dashboard/presentation/widgets/dashboard_track_card.dart#L42)

**Current implementation** (already correct):
```dart
TrackCoverArt(track: track, size: Dimensions.avatarLarge),
```

**No changes needed** - these components already pass the entire track entity, which includes `coverUrl` and `coverLocalPath`.

#### 4. Verify MiniAudioPlayer
**File**: [lib/features/audio_player/presentation/widgets/miniplayer_components/mini_audio_player.dart:82-85](lib/features/audio_player/presentation/widgets/miniplayer_components/mini_audio_player.dart#L82-L85)

**Current implementation** (already correct):
```dart
TrackCoverArt(
  metadata: state.session.currentTrack,  // ✅ Passes metadata with coverUrl
  size: Dimensions.avatarLarge,
),
```

**No changes needed** - `AudioTrackMetadata` includes `coverUrl` field from the track.

### Success Criteria

#### Automated Verification:
- [ ] No build errors: `flutter analyze`
- [ ] Widget tests pass: `flutter test test/features/projects/presentation/`
- [ ] No type errors in component integrations: `flutter pub run build_runner build`

#### Manual Verification:
- [ ] Projects with cover art show cover in list view
- [ ] Projects with cover art show cover in detail header
- [ ] Projects without cover art show generated placeholder
- [ ] Track cover arts visible in all track lists
- [ ] Mini player shows track cover art
- [ ] Full-screen player shows track cover art
- [ ] Cover arts update immediately after upload
- [ ] Offline mode shows all cached cover arts

---

## Phase 3: Consolidate Image Utilities

### Overview
Migrate `ImageUtils` functionality into the existing `ImageStorageRepository` and remove deprecated utilities. This creates a single source of truth for all image operations.

### Changes Required

#### 1. Add Local Image Operations to ImageStorageRepository
**File**: [lib/core/storage/domain/image_storage_repository.dart](lib/core/storage/domain/image_storage_repository.dart)

**Add new methods to interface**:
```dart
abstract class ImageStorageRepository {
  // Existing methods...
  Future<Either<Failure, String>> uploadImage({...});
  Future<Either<Failure, String>> downloadImage({...});
  Future<Either<Failure, bool>> isImageCached({...});
  Future<Either<Failure, String?>> getCachedImagePath({...});
  Future<Either<Failure, Unit>> deleteImage({...});
  Future<Either<Failure, Unit>> clearCache({...});

  // NEW: Add local image operations
  /// Saves a locally picked image to permanent app storage
  /// Used before uploading to Firebase Storage
  Future<Either<Failure, String>> saveLocalImage({
    required String sourcePath,
    required DirectoryType directoryType,
    required String fileName,
  });

  /// Validates if a file path points to a valid local image
  Future<Either<Failure, bool>> isValidLocalImage(String filePath);

  /// Deletes a local image file by path
  Future<Either<Failure, Unit>> deleteLocalImage(String imagePath);
}
```

#### 2. Implement New Methods in ImageStorageRepositoryImpl
**File**: [lib/core/storage/data/image_storage_repository_impl.dart](lib/core/storage/data/image_storage_repository_impl.dart)

**Add implementations after existing methods** (after line 230):
```dart
@override
Future<Either<Failure, String>> saveLocalImage({
  required String sourcePath,
  required DirectoryType directoryType,
  required String fileName,
}) async {
  try {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return Left(StorageFailure('Source file does not exist: $sourcePath'));
    }

    // Get destination directory using DirectoryService
    final dirResult = await _directoryService.getDirectory(directoryType);

    return await dirResult.fold(
      (failure) => Left(failure),
      (directory) async {
        final destinationPath = '${directory.path}/$fileName';
        final destinationFile = File(destinationPath);

        // Ensure directory exists
        await destinationFile.parent.create(recursive: true);

        // Copy file to permanent storage
        await sourceFile.copy(destinationPath);

        AppLogger.info(
          'Local image saved: $destinationPath',
          tag: 'IMAGE_STORAGE',
        );

        return Right(destinationPath);
      },
    );
  } catch (e) {
    return Left(StorageFailure('Failed to save local image: $e'));
  }
}

@override
Future<Either<Failure, bool>> isValidLocalImage(String filePath) async {
  if (filePath.isEmpty || filePath.startsWith('http')) {
    return const Right(false);
  }

  try {
    final file = File(filePath);
    if (!await file.exists()) {
      return const Right(false);
    }

    final extension = path.extension(filePath).toLowerCase();
    const validExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.heic',
    ];

    return Right(validExtensions.contains(extension));
  } catch (e) {
    AppLogger.error('Error validating image: $e', tag: 'IMAGE_STORAGE');
    return const Right(false);
  }
}

@override
Future<Either<Failure, Unit>> deleteLocalImage(String imagePath) async {
  if (imagePath.isEmpty || imagePath.startsWith('http')) {
    return const Right(unit); // Don't delete URLs
  }

  try {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
      AppLogger.info('Local image deleted: $imagePath', tag: 'IMAGE_STORAGE');
    }
    return const Right(unit);
  } catch (e) {
    return Left(StorageFailure('Failed to delete local image: $e'));
  }
}
```

**Add import**:
```dart
import 'package:path/path.dart' as path;
```

#### 3. Migrate ImageUtils Usages to ImageStorageRepository

**File 1**: [lib/features/settings/presentation/widgets/user_image_picker.dart:32-34](lib/features/settings/presentation/widgets/user_image_picker.dart#L32-L34)

**Before**:
```dart
final permanentPath = await ImageUtils.saveLocalImage(pickedFile.path);
```

**After**:
```dart
// Add ImageStorageRepository to widget constructor
final ImageStorageRepository _imageStorageRepository;

// Update call site
final timestamp = DateTime.now().millisecondsSinceEpoch;
final fileName = 'avatar_$timestamp${path.extension(pickedFile.path)}';

final result = await _imageStorageRepository.saveLocalImage(
  sourcePath: pickedFile.path,
  directoryType: DirectoryType.localAvatars,
  fileName: fileName,
);

final permanentPath = result.fold(
  (_) => null,
  (path) => path,
);
```

**File 2**: [lib/features/user_profile/presentation/components/avatar_uploader.dart:55-56](lib/features/user_profile/presentation/components/avatar_uploader.dart#L55-L56)

**Same migration pattern as File 1**

**File 3**: [lib/features/user_profile/presentation/edit_profile_dialog.dart:74-76](lib/features/user_profile/presentation/edit_profile_dialog.dart#L74-L76)

**Same migration pattern as File 1**

**File 4**: [lib/features/user_profile/data/repositories/user_profile_repository_impl.dart:73](lib/features/user_profile/data/repositories/user_profile_repository_impl.dart#L73)

**Before**:
```dart
final cachedPath = await ImageUtils.saveLocalImage(dto.avatarUrl);
```

**After**:
```dart
final timestamp = DateTime.now().millisecondsSinceEpoch;
final fileName = 'avatar_$timestamp${path.extension(dto.avatarUrl)}';

final result = await _imageStorageRepository.saveLocalImage(
  sourcePath: dto.avatarUrl,
  directoryType: DirectoryType.localAvatars,
  fileName: fileName,
);

final cachedPath = result.fold((_) => null, (path) => path);
```

**Note**: `_imageStorageRepository` is already injected in this repository class.

#### 4. Remove Deprecated File Operations from FileSystemUtils
**File**: [lib/core/utils/file_system_utils.dart](lib/core/utils/file_system_utils.dart)

**Keep these methods** (audio-specific):
- `ensureDirectoryExists()` - used by audio recording system
- `generateUniqueFilename()` - used for temporary recordings
- `getFileSize()` - used for audio file validation
- `fileExists()` - used throughout

**Remove or deprecate**:
- `deleteFileIfExists()` - now handled by `ImageStorageRepository.deleteLocalImage()`
- `extractExtension()` - use `path.extension()` directly

**Add deprecation notice** to `deleteFileIfExists()`:
```dart
/// @deprecated Use ImageStorageRepository.deleteLocalImage() for images
/// This method is kept only for audio file operations
@Deprecated('Use ImageStorageRepository.deleteLocalImage() for image files')
static Future<bool> deleteFileIfExists(String path) async {
  // ... existing implementation
}
```

#### 5. Delete ImageUtils File
**File**: [lib/core/utils/image_utils.dart](lib/core/utils/image_utils.dart)

After all usages are migrated, delete this file entirely:
```bash
rm lib/core/utils/image_utils.dart
```

**Remove import statements** from:
- `lib/features/settings/presentation/widgets/user_image_picker.dart`
- `lib/features/user_profile/presentation/components/avatar_uploader.dart`
- `lib/features/user_profile/presentation/edit_profile_dialog.dart`
- `lib/features/user_profile/data/repositories/user_profile_repository_impl.dart`

### Success Criteria

#### Automated Verification:
- [ ] No build errors: `flutter analyze`
- [ ] All imports resolve: `flutter pub get`
- [ ] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Unit tests pass: `flutter test`
- [ ] No references to `ImageUtils` remain: `grep -r "ImageUtils" lib/`

#### Manual Verification:
- [ ] User avatar upload still works (settings screen)
- [ ] User avatar editing works (edit profile dialog)
- [ ] Avatar picker widget functions correctly
- [ ] User profile repository saves avatars to correct directory
- [ ] All image operations logged consistently
- [ ] No regression in existing image features

---

## Phase 4: Fix Audio Track Cover Art Sync

### Overview
Add the missing sync executor handler for audio track cover art updates to ensure changes propagate to Firestore correctly.

### Changes Required

#### 1. Add Cover Art Handler to AudioTrackOperationExecutor
**File**: [lib/core/sync/domain/executors/audio_track_operation_executor.dart](lib/core/sync/domain/executors/audio_track_operation_executor.dart)

**Current implementation** (lines 50-87):
```dart
Future<void> _executeUpdate(
  SyncOperationDocument operation,
  Map<String, dynamic> operationData,
) async {
  final trackId = operation.entityId;
  final field = operationData['field'] ?? '';

  switch (field) {
    case 'name':
      final projectId = operationData['projectId'] ?? '';
      final newName = operationData['newName'] ?? '';
      await _remoteDataSource.editTrackName(trackId, projectId, newName);
      break;

    case 'activeVersion':
      final activeVersionId = operationData['activeVersionId'] ?? '';
      final result = await _remoteDataSource.updateActiveVersion(
        trackId,
        activeVersionId,
      );
      result.fold(
        (failure) =>
            throw Exception(
              'Update active version failed: ${failure.message}',
            ),
        (_) {
          // Successfully updated active version
        },
      );
      break;

    // ❌ MISSING: case 'coverArt':

    default:
      throw UnsupportedError('Unknown audio track update field: $field');
  }
}
```

**Add after `case 'activeVersion'` block** (after line 75):
```dart
    case 'coverArt':
      final coverUrl = operationData['coverUrl'] as String? ?? '';
      final coverLocalPath = operationData['coverLocalPath'] as String?;

      // Update remote with cover URL only (local path is not synced)
      final result = await _remoteDataSource.updateTrackCoverUrl(
        trackId,
        coverUrl,
        null, // coverLocalPath is intentionally NOT synced to Firestore
      );

      result.fold(
        (failure) => throw Exception(
          'Update cover art failed: ${failure.message}',
        ),
        (_) {
          // Successfully updated cover art
          AppLogger.info(
            'Cover art synced for track: $trackId',
            tag: 'AudioTrackOperationExecutor',
          );
        },
      );
      break;
```

**Add import**:
```dart
import 'package:trackflow/core/utils/app_logger.dart';
```

#### 2. Verify AudioTrackRemoteDataSource Has Method
**File**: [lib/features/audio_track/data/datasources/audio_track_remote_datasource.dart:155-175](lib/features/audio_track/data/datasources/audio_track_remote_datasource.dart#L155-L175)

**Method already exists** (no changes needed):
```dart
@override
Future<Either<Failure, Unit>> updateTrackCoverUrl(
  String trackId,
  String coverUrl,
  String? coverLocalPath,  // Ignored - not sent to Firestore
) async {
  try {
    await _firestore
        .collection(AudioTrackDTO.collection)
        .doc(trackId)
        .update({
      'url': coverUrl,  // Uses 'url' key for backwards compatibility
      'lastModified': FieldValue.serverTimestamp(),
    });

    return const Right(unit);
  } catch (e) {
    return Left(ServerFailure('Error updating track cover URL: $e'));
  }
}
```

**Verified**: This method correctly updates Firestore with only the `coverUrl` (as key `'url'`), and correctly ignores `coverLocalPath` (which is local-only).

#### 3. Verify Repository Queues Correct Operation Data
**File**: [lib/features/audio_track/data/repositories/audio_track_repository_impl.dart:78-84](lib/features/audio_track/data/repositories/audio_track_repository_impl.dart#L78-L84)

**Current implementation**:
```dart
final queueResult = await _pendingOperationsManager.addUpdateOperation(
  entityType: 'audio_track',
  entityId: track.id.value,
  data: {
    'coverUrl': track.coverUrl,
    'coverLocalPath': track.coverLocalPath,
    'field': 'coverArt',  // ✅ Correct field marker
  },
  priority: SyncPriority.medium,
);
```

**Verified**: Repository correctly queues operation with `field: 'coverArt'` marker and includes both URL and local path (local path will be ignored by executor).

### Success Criteria

#### Automated Verification:
- [ ] No build errors: `flutter analyze`
- [ ] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Unit tests pass: `flutter test test/core/sync/`

#### Manual Verification:
- [ ] Upload track cover art while online → syncs to Firestore immediately
- [ ] Upload track cover art while offline → syncs when coming online
- [ ] Check Firestore console → `url` field updated correctly
- [ ] Check Firestore console → `coverLocalPath` NOT present (local-only)
- [ ] Other devices receive cover art updates via sync
- [ ] No sync errors in logs after cover art upload
- [ ] Background sync coordinator processes cover art updates

---

## Testing Strategy

### Unit Tests

#### ImageStorageRepository Tests
**File**: `test/core/storage/data/image_storage_repository_impl_test.dart` (new file)

```dart
group('Local image operations', () {
  test('saveLocalImage copies file to correct directory', () async {
    // Given: source file exists
    // When: saveLocalImage called
    // Then: file copied to DirectoryService path with correct filename
  });

  test('isValidLocalImage returns true for valid extensions', () async {
    // Given: file with .jpg, .png, .webp, etc.
    // When: isValidLocalImage called
    // Then: returns Right(true)
  });

  test('isValidLocalImage returns false for invalid extensions', () async {
    // Given: file with .txt, .pdf, etc.
    // When: isValidLocalImage called
    // Then: returns Right(false)
  });

  test('deleteLocalImage removes file if exists', () async {
    // Given: existing local image file
    // When: deleteLocalImage called
    // Then: file deleted and returns Right(unit)
  });

  test('deleteLocalImage handles non-existent files gracefully', () async {
    // Given: non-existent file path
    // When: deleteLocalImage called
    // Then: returns Right(unit) without error
  });
});
```

#### AudioTrackOperationExecutor Tests
**File**: `test/core/sync/domain/executors/audio_track_operation_executor_test.dart`

Add test case:
```dart
test('execute handles coverArt field update', () async {
  // Given: operation with field='coverArt'
  // When: execute called
  // Then: calls remoteDataSource.updateTrackCoverUrl with correct params
});
```

### Integration Tests

#### Cover Art Offline Persistence Test
**File**: `test/integration_test/cover_art_offline_test.dart` (new file)

```dart
testWidgets('Track cover art persists offline', (tester) async {
  // 1. Setup: authenticated user with project and track
  // 2. Upload track cover art
  // 3. Verify: image displays immediately
  // 4. Simulate going offline (mock network failure)
  // 5. Restart app (pump new widget tree)
  // 6. Verify: cover art still displays (not placeholder)
  // 7. Verify: uses CachedNetworkImage cache
});

testWidgets('Project cover art displays in all views', (tester) async {
  // 1. Setup: authenticated user with project
  // 2. Upload project cover art
  // 3. Navigate to project list
  // 4. Verify: cover art visible in ProjectComponent
  // 5. Navigate to project detail
  // 6. Verify: cover art visible in ProjectDetailSliverHeader
  // 7. Go offline and repeat steps 3-6
});
```

### Manual Testing Steps

#### Test Case 1: Track Cover Art Offline Persistence
1. Login to app
2. Navigate to a track detail screen
3. Upload cover art via track actions
4. Verify image appears immediately
5. Enable airplane mode on device
6. Force close and restart app
7. Navigate back to same track
8. **Expected**: Cover art displays from cache (not placeholder)
9. **Expected**: No network error messages

#### Test Case 2: Project Cover Art Display
1. Login to app
2. Navigate to projects list
3. Select project and upload cover art
4. Return to projects list
5. **Expected**: Cover art visible in project card
6. Tap project to view detail
7. **Expected**: Cover art visible in header
8. Go offline (airplane mode)
9. Navigate back to list and detail
10. **Expected**: Cover art still visible in both views

#### Test Case 3: Cover Art Sync
1. Login to app on Device A
2. Upload track cover art
3. Login to app on Device B (same account)
4. Wait for sync (or trigger manual refresh)
5. Navigate to same track on Device B
6. **Expected**: Cover art displays (synced from Firestore)
7. Check Firestore console
8. **Expected**: `url` field contains Firebase Storage URL
9. **Expected**: No `coverLocalPath` field in Firestore document

#### Test Case 4: Full-Screen Player
1. Play a track with cover art
2. Expand to full-screen player
3. **Expected**: Cover art displays at large size
4. Go offline
5. Skip to another track with cover art
6. **Expected**: Cover art loads from cache
7. Restart app offline
8. Resume playback
9. **Expected**: Cover art displays without network

## Performance Considerations

### CachedNetworkImage Default Behavior
- Uses `flutter_cache_manager` under the hood
- Default cache duration: 7 days
- Default max cache objects: 200
- Default max cache size: unlimited
- Cache location: platform-specific temp directory

### Potential Optimizations (Future Enhancement)
- Custom `CacheManager` with app-specific cache directory
- Align cache directory with `DirectoryService` paths
- Custom cache duration based on image type
- Implement cache size limits
- Add cache pruning strategy

**Not implementing now** because:
1. Default behavior is sufficient for MVP
2. Adds complexity without proven need
3. Can be added later without breaking changes

### Image Compression Impact
- Upload use cases already compress to WebP at 85% quality
- Reduces storage and bandwidth requirements
- Compression happens once before upload
- Cached images are already compressed

## Migration Notes

### Breaking Changes
**None** - All changes are additive or internal refactoring.

### Deprecation Path
1. `ImageUtils` usages migrated to `ImageStorageRepository`
2. `ImageUtils.dart` file deleted after migration
3. `FileSystemUtils.deleteFileIfExists()` marked as deprecated with migration guidance

### Data Migration
**Not required** - Existing cover art data remains valid:
- `coverUrl` and `coverLocalPath` fields unchanged
- Existing cached images remain in DirectoryService paths
- Firestore documents unchanged
- Isar documents unchanged

### Rollback Strategy
If issues arise in production:
1. **Phase 1 rollback**: Revert widget changes, restore `Image.network`
2. **Phase 2 rollback**: Remove `imageUrl` parameters from components
3. **Phase 3 rollback**: Restore `ImageUtils.dart`, revert repository usages
4. **Phase 4 rollback**: Remove `case 'coverArt'` from executor

Each phase can be rolled back independently without affecting others.

## References

### Original Context
- User reported cover art not persisting locally after upload
- Expected behavior: offline availability like user avatars
- Desired: unified image system for all image types

### Related Files
**Widgets**:
- [lib/features/ui/track/track_cover_art.dart](lib/features/ui/track/track_cover_art.dart)
- [lib/features/ui/project/project_cover_art.dart](lib/features/ui/project/project_cover_art.dart)
- [lib/core/widgets/user_avatar.dart](lib/core/widgets/user_avatar.dart)

**Upload Use Cases**:
- [lib/features/projects/domain/usecases/upload_cover_art_usecase.dart](lib/features/projects/domain/usecases/upload_cover_art_usecase.dart)
- [lib/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart](lib/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart)

**Repositories**:
- [lib/core/storage/data/image_storage_repository_impl.dart](lib/core/storage/data/image_storage_repository_impl.dart)
- [lib/features/projects/data/repositories/projects_repository_impl.dart](lib/features/projects/data/repositories/projects_repository_impl.dart)
- [lib/features/audio_track/data/repositories/audio_track_repository_impl.dart](lib/features/audio_track/data/repositories/audio_track_repository_impl.dart)

**Sync System**:
- [lib/core/sync/domain/executors/audio_track_operation_executor.dart](lib/core/sync/domain/executors/audio_track_operation_executor.dart)
- [lib/core/sync/domain/executors/project_operation_executor.dart](lib/core/sync/domain/executors/project_operation_executor.dart)

**Infrastructure**:
- [lib/core/infrastructure/domain/directory_service.dart](lib/core/infrastructure/domain/directory_service.dart)
- [lib/core/infrastructure/services/directory_service_impl.dart](lib/core/infrastructure/services/directory_service_impl.dart)

### Dependencies
- `cached_network_image: ^3.4.1` (already in pubspec.yaml)
- `path_provider: ^2.1.5` (already in pubspec.yaml)
- `path: ^1.9.0` (already in pubspec.yaml)

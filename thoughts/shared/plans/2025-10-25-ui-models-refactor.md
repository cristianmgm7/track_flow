# UI Models Refactoring Implementation Plan

## Overview

This plan addresses an architectural inconsistency where domain entities are stored directly in Bloc states. Domain entities use identity-based equality (comparing only IDs), but Bloc states using Equatable need content-based equality to detect UI changes and trigger rebuilds. This mismatch currently requires manual workarounds in some states and may cause reactivity bugs in others.

We will introduce a presentation model layer (UI Models) that wraps domain entities, handles Equatable properly, unwraps value objects to primitives, and provides UI-specific formatting.

## Current State Analysis

### The Core Problem

**Domain Layer**: Entities use identity-based equality via `Entity<T>` ([lib/core/domain/entity.dart:7-12](lib/core/domain/entity.dart#L7-L12)):
```dart
abstract class Entity<T> {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity<T> && other.id == id;
}
```

Two entity instances with the same ID but different field values are considered equal. This is correct for domain logic but problematic for Bloc state comparison.

**Presentation Layer**: Currently storing domain entities directly:
- [ProjectDetailState](lib/features/project_detail/presentation/bloc/project_detail_state.dart#L8-L10) stores `Project`, `List<AudioTrack>`, `List<UserProfile>`
- [DashboardState](lib/features/dashboard/presentation/bloc/dashboard_state.dart#L27-L29) stores `List<Project>`, `List<AudioTrack>`, `List<AudioComment>`

**Manual Workarounds**: 2 states manually expand entity fields in props:
```dart
// DashboardState.props (lines 42-78)
tracks.map((t) => [t.id, t.name, t.coverUrl, t.coverLocalPath, ...]).toList()
```

**States Without Workarounds**: 6+ states pass entities directly to props, which may cause subtle reactivity bugs:
- [AudioTrackState](lib/features/audio_track/presentation/bloc/audio_track_state.dart#L45)
- [VoiceMemoState](lib/features/voice_memos/presentation/bloc/voice_memo_state.dart#L29)
- [TrackVersionsState](lib/features/track_version/presentation/blocs/track_versions/track_versions_state.dart#L26)
- [ProjectsState](lib/features/projects/presentation/blocs/projects_state.dart#L77)
- [AudioCommentState](lib/features/audio_comment/presentation/bloc/audio_comment_state.dart#L65)
- [PlaylistState](lib/features/playlist/presentation/bloc/playlist_state.dart#L36)

### Existing Pattern

One UI model exists: [TrackRowViewModel](lib/features/playlist/presentation/models/track_row_view_model.dart#L5-L28) which:
- Extends Equatable
- Contains the domain entity via composition (`final AudioTrack track`)
- Adds UI-specific fields (`displayedDuration`, `cacheableRemoteUrl`)
- Uses const constructor
- Does NOT use `fromDomain()` factory (constructed inline in Bloc)

### Key Discoveries

**Scope**:
- 18 Bloc state files storing domain entities
- 9 core domain entities (Project, AudioTrack, UserProfile, AudioComment, TrackVersion, VoiceMemo, ProjectInvitation, PlaybackSession, RecordingSession)
- 50+ widgets/components receiving entities as constructor parameters
- 7 screens accessing state entities via BlocBuilder

**Domain Entities with Value Objects**:
- `Project` uses `ProjectName`, `ProjectDescription`, `ProjectId`, `UserId`
- `AudioTrack` uses `AudioTrackId`, `ProjectId`, `UserId`, `TrackVersionId`
- `UserProfile` uses `UserId`, `CreativeRole`, `ProjectRole`
- `AudioComment` uses `AudioCommentId`, `ProjectId`, `TrackVersionId`, `UserId`, `CommentType`

## Desired End State

After this refactor:
1. No Bloc State class contains domain entities directly
2. All props rely solely on UI Models and primitive types
3. All conversions between domain and UI occur inside Bloc using `fromDomain()` factories
4. Widgets accept only UI models (not domain entities)
5. UI models handle equality properly without manual workarounds
6. Value objects are unwrapped to primitives for simpler UI code
7. Reactive updates (renaming tracks, changing cover art) reflect immediately in UI

### Verification

**Automated**:
```bash
# No domain entity imports in state files
grep -r "domain/entities" lib/features/*/presentation/bloc/*_state.dart

# All tests pass
flutter test

# No analysis issues
flutter analyze
```

**Manual**:
- Update a project name → Dashboard and ProjectDetail screen update immediately
- Change track cover art → Track list reflects change without manual refresh
- Add a comment → Comment count updates in real-time
- No visual regressions in any feature

## What We're NOT Doing

- NOT changing domain entities themselves
- NOT modifying repository interfaces or use cases
- NOT changing the data layer (DTOs remain unchanged)
- NOT adding UI logic to domain layer
- NOT creating UI models for simple value objects used only once
- NOT refactoring authentication or cache management features in Phase 1-5 (deferred)

## Implementation Approach

**Strategy**: Feature-by-feature migration with composition pattern

**UI Model Pattern**:
```dart
class ProjectUiModel extends Equatable {
  final Project project;              // Composition (entity inside)
  final String id;                    // Unwrapped primitives for easy access
  final String name;
  final String description;
  final String? coverUrl;
  final String? coverLocalPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const ProjectUiModel({
    required this.project,
    required this.id,
    required this.name,
    required this.description,
    this.coverUrl,
    this.coverLocalPath,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
  });

  factory ProjectUiModel.fromDomain(Project project) {
    return ProjectUiModel(
      project: project,
      id: project.id.value,
      name: project.name.value.getOrElse(() => ''),
      description: project.description.value.getOrElse(() => ''),
      coverUrl: project.coverUrl,
      coverLocalPath: project.coverLocalPath,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      isDeleted: project.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, coverUrl, coverLocalPath,
    createdAt, updatedAt, isDeleted
  ];
}
```

**Key Principles**:
1. UI models use composition (contain entity)
2. Primitives unwrapped for direct access
3. `fromDomain()` static factory for conversion
4. Equatable compares primitives (not entity)
5. Const constructor when possible

**Migration Per Feature**:
1. Create UI models under `features/[feature]/presentation/models/`
2. Update state to use UI models
3. Update Bloc emit logic to convert via `fromDomain()`
4. Update widgets to accept UI models only
5. Test automated + manual verification

---

## Phase 1: Core UI Models Foundation

### Overview
Create the foundational UI model infrastructure and establish patterns for all other phases. This includes the three most-used entities: Project, AudioTrack, and UserProfile.

### Changes Required

#### 1. Project UI Model
**File**: `lib/features/projects/presentation/models/project_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

/// UI model wrapping Project domain entity with unwrapped primitives
class ProjectUiModel extends Equatable {
  final Project project; // Composition pattern

  // Unwrapped primitives for easy UI access
  final String id;
  final String name;
  final String description;
  final String? coverUrl;
  final String? coverLocalPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final int collaboratorCount;

  const ProjectUiModel({
    required this.project,
    required this.id,
    required this.name,
    required this.description,
    this.coverUrl,
    this.coverLocalPath,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.collaboratorCount,
  });

  factory ProjectUiModel.fromDomain(Project project) {
    return ProjectUiModel(
      project: project,
      id: project.id.value,
      name: project.name.value.getOrElse(() => ''),
      description: project.description.value.getOrElse(() => ''),
      coverUrl: project.coverUrl,
      coverLocalPath: project.coverLocalPath,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      isDeleted: project.isDeleted,
      collaboratorCount: project.collaborators.length,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, coverUrl, coverLocalPath,
    createdAt, updatedAt, isDeleted, collaboratorCount,
  ];
}
```

#### 2. AudioTrack UI Model
**File**: `lib/features/audio_track/presentation/models/audio_track_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_track.dart';

/// UI model wrapping AudioTrack domain entity with unwrapped primitives
class AudioTrackUiModel extends Equatable {
  final AudioTrack track; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String name;
  final String coverUrl;
  final String? coverLocalPath;
  final Duration duration;
  final String projectId;
  final String uploadedBy;
  final DateTime createdAt;
  final String? activeVersionId;
  final bool isDeleted;

  // UI-specific computed fields
  final String formattedDuration;

  const AudioTrackUiModel({
    required this.track,
    required this.id,
    required this.name,
    required this.coverUrl,
    this.coverLocalPath,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
    this.activeVersionId,
    required this.isDeleted,
    required this.formattedDuration,
  });

  factory AudioTrackUiModel.fromDomain(AudioTrack track) {
    return AudioTrackUiModel(
      track: track,
      id: track.id.value,
      name: track.name,
      coverUrl: track.coverUrl,
      coverLocalPath: track.coverLocalPath,
      duration: track.duration,
      projectId: track.projectId.value,
      uploadedBy: track.uploadedBy.value,
      createdAt: track.createdAt,
      activeVersionId: track.activeVersionId?.value,
      isDeleted: track.isDeleted,
      formattedDuration: _formatDuration(track.duration),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id, name, coverUrl, coverLocalPath, duration,
    projectId, uploadedBy, createdAt, activeVersionId,
    isDeleted, formattedDuration,
  ];
}
```

#### 3. UserProfile UI Model
**File**: `lib/features/user_profile/presentation/models/user_profile_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

/// UI model wrapping UserProfile domain entity with unwrapped primitives
class UserProfileUiModel extends Equatable {
  final UserProfile profile; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? avatarLocalPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? creativeRole;
  final String? projectRole;

  // UI-specific computed fields
  final String displayName;
  final String initials;

  const UserProfileUiModel({
    required this.profile,
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.avatarLocalPath,
    required this.createdAt,
    this.updatedAt,
    this.creativeRole,
    this.projectRole,
    required this.displayName,
    required this.initials,
  });

  factory UserProfileUiModel.fromDomain(UserProfile profile) {
    final name = profile.name;
    return UserProfileUiModel(
      profile: profile,
      id: profile.id.value,
      name: name,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      avatarLocalPath: profile.avatarLocalPath,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      creativeRole: profile.creativeRole?.toString(),
      projectRole: profile.role?.toString(),
      displayName: name.isNotEmpty ? name : profile.email.split('@').first,
      initials: _getInitials(name),
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    id, name, email, avatarUrl, avatarLocalPath,
    createdAt, updatedAt, creativeRole, projectRole,
    displayName, initials,
  ];
}
```

#### 4. Update Existing TrackRowViewModel
**File**: `lib/features/playlist/presentation/models/track_row_view_model.dart`

**Changes**: Add `fromDomain()` factory to align with new pattern

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class TrackRowViewModel extends Equatable {
  final AudioTrack track;
  final Duration displayedDuration;
  final String? cacheableRemoteUrl;
  final String? activeVersionId;
  final TrackVersionStatus? status;

  const TrackRowViewModel({
    required this.track,
    required this.displayedDuration,
    this.cacheableRemoteUrl,
    this.activeVersionId,
    this.status,
  });

  // ADD: Factory method for consistency with new UI models
  factory TrackRowViewModel.fromDomain({
    required AudioTrack track,
    Duration? displayedDuration,
    String? cacheableRemoteUrl,
    String? activeVersionId,
    TrackVersionStatus? status,
  }) {
    return TrackRowViewModel(
      track: track,
      displayedDuration: displayedDuration ?? track.duration,
      cacheableRemoteUrl: cacheableRemoteUrl,
      activeVersionId: activeVersionId,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    track,
    displayedDuration,
    cacheableRemoteUrl,
    activeVersionId,
    status,
  ];
}
```

### Success Criteria

#### Automated Verification:
- [x] All new UI model files created
- [x] No compilation errors: `flutter analyze`
- [x] Pattern files are valid Dart: `dart format --set-exit-if-changed lib/features/*/presentation/models/*.dart`

#### Manual Verification:
- [x] UI models follow composition pattern (entity inside)
- [x] All value objects unwrapped to primitives
- [x] `fromDomain()` factories present in all UI models
- [x] Equatable props contain only primitives
- [x] Code review confirms pattern consistency

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the pattern is correct before proceeding to Phase 2.

---

## Phase 2: Dashboard Feature Migration

### Overview
Migrate the Dashboard feature to use UI models. This feature currently has manual equality workarounds and is a high-visibility feature, making it ideal for validating the approach.

**Current State**: [DashboardState](lib/features/dashboard/presentation/bloc/dashboard_state.dart#L42-L78) manually expands entity fields in props.

### Changes Required

#### 1. Create AudioComment UI Model
**File**: `lib/features/audio_comment/presentation/models/audio_comment_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_comment.dart';

/// UI model wrapping AudioComment domain entity with unwrapped primitives
class AudioCommentUiModel extends Equatable {
  final AudioComment comment; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String projectId;
  final String versionId;
  final String createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;
  final String? audioStorageUrl;
  final String? localAudioPath;
  final Duration? audioDuration;
  final String commentType;

  // UI-specific computed fields
  final String formattedTimestamp;
  final String formattedCreatedAt;
  final bool hasAudio;

  const AudioCommentUiModel({
    required this.comment,
    required this.id,
    required this.projectId,
    required this.versionId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    this.audioStorageUrl,
    this.localAudioPath,
    this.audioDuration,
    required this.commentType,
    required this.formattedTimestamp,
    required this.formattedCreatedAt,
    required this.hasAudio,
  });

  factory AudioCommentUiModel.fromDomain(AudioComment comment) {
    return AudioCommentUiModel(
      comment: comment,
      id: comment.id.value,
      projectId: comment.projectId.value,
      versionId: comment.versionId.value,
      createdBy: comment.createdBy.value,
      content: comment.content,
      timestamp: comment.timestamp,
      createdAt: comment.createdAt,
      audioStorageUrl: comment.audioStorageUrl,
      localAudioPath: comment.localAudioPath,
      audioDuration: comment.audioDuration,
      commentType: comment.commentType.toString(),
      formattedTimestamp: _formatDuration(comment.timestamp),
      formattedCreatedAt: _formatDateTime(comment.createdAt),
      hasAudio: comment.audioStorageUrl != null || comment.localAudioPath != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    id, projectId, versionId, createdBy, content, timestamp,
    createdAt, audioStorageUrl, localAudioPath, audioDuration,
    commentType, formattedTimestamp, formattedCreatedAt, hasAudio,
  ];
}
```

#### 2. Update DashboardState
**File**: `lib/features/dashboard/presentation/bloc/dashboard_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<ProjectUiModel> projectPreview;        // CHANGED
  final List<AudioTrackUiModel> trackPreview;       // CHANGED
  final List<AudioCommentUiModel> recentComments;   // CHANGED
  final bool isLoading;
  final Option<Failure> failureOption;

  const DashboardLoaded({
    required this.projectPreview,
    required this.trackPreview,
    required this.recentComments,
    this.isLoading = false,
    this.failureOption = const None(),
  });

  @override
  List<Object?> get props => [
        // REMOVED manual expansion - UI models handle equality properly
        projectPreview,
        trackPreview,
        recentComments,
        isLoading,
        failureOption,
      ];

  DashboardLoaded copyWith({
    List<ProjectUiModel>? projectPreview,           // CHANGED
    List<AudioTrackUiModel>? trackPreview,          // CHANGED
    List<AudioCommentUiModel>? recentComments,      // CHANGED
    bool? isLoading,
    Option<Failure>? failureOption,
  }) {
    return DashboardLoaded(
      projectPreview: projectPreview ?? this.projectPreview,
      trackPreview: trackPreview ?? this.trackPreview,
      recentComments: recentComments ?? this.recentComments,
      isLoading: isLoading ?? this.isLoading,
      failureOption: failureOption ?? this.failureOption,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### 3. Update DashboardBloc Emit Logic
**File**: `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`

**Changes**: Convert domain entities to UI models using `fromDomain()`

```dart
// Locate the event handler that emits DashboardLoaded (around line 36)
// BEFORE:
emit(
  DashboardLoaded(
    projectPreview: bundle.projectPreview,
    trackPreview: bundle.trackPreview,
    recentComments: bundle.recentComments,
    isLoading: false,
    failureOption: none(),
  ),
);

// AFTER:
emit(
  DashboardLoaded(
    projectPreview: bundle.projectPreview
        .map(ProjectUiModel.fromDomain)
        .toList(),
    trackPreview: bundle.trackPreview
        .map(AudioTrackUiModel.fromDomain)
        .toList(),
    recentComments: bundle.recentComments
        .map(AudioCommentUiModel.fromDomain)
        .toList(),
    isLoading: false,
    failureOption: none(),
  ),
);
```

#### 4. Update Dashboard Screen
**File**: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Changes**: Update BlocBuilder to work with UI models (around lines 82, 88)

```dart
// BEFORE: (line 82)
projects: state.projectPreview,

// AFTER:
projects: state.projectPreview,  // Now List<ProjectUiModel>

// BEFORE: (line 88)
tracks: state.trackPreview,

// AFTER:
tracks: state.trackPreview,  // Now List<AudioTrackUiModel>
```

#### 5. Update DashboardProjectsSection
**File**: `lib/features/dashboard/presentation/widgets/dashboard_projects_section.dart`

**Changes**: Update to accept and use UI models

```dart
// BEFORE: (line 15)
final List<Project> projects;

// AFTER:
final List<ProjectUiModel> projects;

// BEFORE: (lines 111-130)
final project = projects[index];
return AppProjectCard(
  title: project.name.value.fold((l) => '', (r) => r),
  description: project.description.value.fold((l) => '', (r) => r),
  // ...
);

// AFTER:
final projectUi = projects[index];
return AppProjectCard(
  title: projectUi.name,              // Unwrapped primitive
  description: projectUi.description, // Unwrapped primitive
  // Update other field accesses similarly
  onTap: () => context.push(
    AppRoutes.projectDetails.replaceAll(':id', projectUi.id),
    extra: projectUi.project,  // Pass domain entity for navigation
  ),
  leading: ProjectCoverArt(
    key: ValueKey('${projectUi.id}:${projectUi.coverLocalPath ?? projectUi.coverUrl ?? ''}:${projectUi.name}'),
    projectName: projectUi.name,
    projectDescription: projectUi.description,
    imageUrl: projectUi.coverLocalPath ?? projectUi.coverUrl,
    size: Dimensions.avatarLarge,
  ),
  // ...
);
```

#### 6. Update DashboardTracksSection
**File**: `lib/features/dashboard/presentation/widgets/dashboard_tracks_section.dart`

**Changes**: Update to accept UI models

```dart
// BEFORE:
final List<AudioTrack> tracks;

// AFTER:
final List<AudioTrackUiModel> tracks;

// Update track access throughout the widget to use primitives
```

#### 7. Update DashboardTrackCard
**File**: `lib/features/dashboard/presentation/widgets/dashboard_track_card.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// Update all field accesses to use unwrapped primitives
// Example: track.name instead of track.track.name
```

#### 8. Update DashboardCommentsSection
**File**: `lib/features/dashboard/presentation/widgets/dashboard_comments_section.dart`

**Changes**: Update to accept UI models

```dart
// BEFORE:
final List<AudioComment> comments;

// AFTER:
final List<AudioCommentUiModel> comments;
```

#### 9. Update DashboardCommentItem
**File**: `lib/features/dashboard/presentation/widgets/dashboard_comment_item.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioComment comment;

// AFTER:
final AudioCommentUiModel comment;

// Update all field accesses to use unwrapped primitives
```

### Success Criteria

#### Automated Verification:
- [x] No compilation errors: `flutter analyze`
- [ ] All tests pass: `flutter test test/features/dashboard/`
- [x] No import of domain entities in dashboard widgets: `grep -r "domain/entities" lib/features/dashboard/presentation/widgets/`

#### Manual Verification:
- [ ] Dashboard screen loads and displays projects, tracks, and comments
- [ ] Update a project name in Firestore → Dashboard reflects change immediately
- [ ] Add a new track → Dashboard track preview updates
- [ ] Add a comment → Recent comments section updates
- [ ] Cover art changes reflect in real-time
- [ ] No visual regressions compared to previous version
- [ ] Performance is acceptable (no lag when scrolling)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the Dashboard feature works correctly before proceeding to Phase 3.

---

## Phase 3: ProjectDetail Feature Migration

### Overview
Migrate the ProjectDetail feature to use UI models. This feature has the second manual workaround and is a core feature for project management.

**Current State**: [ProjectDetailState](lib/features/project_detail/presentation/bloc/project_detail_state.dart#L76-L107) manually expands entity fields in props.

### Changes Required

#### 1. Update ProjectDetailState
**File**: `lib/features/project_detail/presentation/bloc/project_detail_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_sort.dart';

class ProjectDetailState extends Equatable {
  final ProjectUiModel? project;                    // CHANGED
  final List<AudioTrackUiModel> tracks;             // CHANGED
  final List<UserProfileUiModel> collaborators;     // CHANGED
  final AudioTrackSort sort;

  final bool isLoadingProject;
  final bool isLoadingTracks;
  final bool isLoadingCollaborators;
  final String? projectError;
  final String? tracksError;
  final String? collaboratorsError;

  const ProjectDetailState({
    required this.project,
    required this.tracks,
    required this.collaborators,
    this.sort = AudioTrackSort.newest,
    required this.isLoadingProject,
    required this.isLoadingTracks,
    required this.isLoadingCollaborators,
    required this.projectError,
    required this.tracksError,
    required this.collaboratorsError,
  });

  factory ProjectDetailState.initial() => const ProjectDetailState(
    project: null,
    tracks: [],
    collaborators: [],
    sort: AudioTrackSort.newest,
    isLoadingProject: false,
    isLoadingTracks: false,
    isLoadingCollaborators: false,
    projectError: null,
    tracksError: null,
    collaboratorsError: null,
  );

  ProjectDetailState copyWith({
    ProjectUiModel? project,                        // CHANGED
    List<AudioTrackUiModel>? tracks,                // CHANGED
    List<UserProfileUiModel>? collaborators,        // CHANGED
    AudioTrackSort? sort,
    bool? isLoadingProject,
    bool? isLoadingTracks,
    bool? isLoadingCollaborators,
    String? projectError,
    String? tracksError,
    String? collaboratorsError,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      tracks: tracks ?? this.tracks,
      collaborators: collaborators ?? this.collaborators,
      sort: sort ?? this.sort,
      isLoadingProject: isLoadingProject ?? this.isLoadingProject,
      isLoadingTracks: isLoadingTracks ?? this.isLoadingTracks,
      isLoadingCollaborators:
          isLoadingCollaborators ?? this.isLoadingCollaborators,
      projectError: projectError,
      tracksError: tracksError,
      collaboratorsError: collaboratorsError,
    );
  }

  @override
  List<Object?> get props => [
    // REMOVED manual expansion - UI models handle equality properly
    project,
    tracks,
    collaborators,
    sort,
    isLoadingProject,
    isLoadingTracks,
    isLoadingCollaborators,
    projectError,
    tracksError,
    collaboratorsError,
  ];
}
```

#### 2. Update ProjectDetailBloc Emit Logic
**File**: `lib/features/project_detail/presentation/bloc/project_detail_bloc.dart`

**Changes**: Convert domain entities to UI models in all event handlers

```dart
// Find all emit() calls that update state with entities
// Example pattern for project loading:

// BEFORE:
emit(state.copyWith(
  project: project,
  isLoadingProject: false,
));

// AFTER:
emit(state.copyWith(
  project: ProjectUiModel.fromDomain(project),
  isLoadingProject: false,
));

// Example pattern for tracks loading:

// BEFORE:
emit(state.copyWith(
  tracks: tracks,
  isLoadingTracks: false,
));

// AFTER:
emit(state.copyWith(
  tracks: tracks.map(AudioTrackUiModel.fromDomain).toList(),
  isLoadingTracks: false,
));

// Example pattern for collaborators loading:

// BEFORE:
emit(state.copyWith(
  collaborators: collaborators,
  isLoadingCollaborators: false,
));

// AFTER:
emit(state.copyWith(
  collaborators: collaborators.map(UserProfileUiModel.fromDomain).toList(),
  isLoadingCollaborators: false,
));
```

#### 3. Update ProjectDetailsScreen
**File**: `lib/features/project_detail/presentation/screens/project_details_screen.dart`

**Changes**: Update to work with UI models

```dart
// BEFORE: (constructor, line 30)
final Project project;

// AFTER:
final Project project;  // Keep for navigation - convert to UI model in initState

// BEFORE: (line 114)
Text(state.project?.name.value.getOrElse(() => 'Project') ?? 'Project')

// AFTER:
Text(state.project?.name ?? 'Project')

// Update all other field accesses to use unwrapped primitives from UI models
```

#### 4. Update ProjectDetailSliverHeader
**File**: `lib/features/project_detail/presentation/components/project_detail_sliver_header.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final Project project;

// AFTER:
final ProjectUiModel project;

// Update all field accesses to use unwrapped primitives
// Example: project.name instead of project.name.value.getOrElse(() => '')
```

#### 5. Update ProjectDetailTracksComponent
**File**: `lib/features/project_detail/presentation/components/project_detail_tracks_component.dart`

**Changes**: Update to work with UI models from state

```dart
// BEFORE: (line 10)
final ProjectDetailState state;

// AFTER:
final ProjectDetailState state;  // State now contains UI models

// BEFORE: (line 58 - accessing tracks)
state.tracks

// AFTER:
state.tracks  // Now List<AudioTrackUiModel>

// Update child widgets to receive UI models
```

#### 6. Update ProjectDetailCollaboratorsComponent
**File**: `lib/features/project_detail/presentation/components/project_detail_collaborators_component.dart`

**Changes**: Update to work with UI models from state

```dart
// State now contains ProjectUiModel with unwrapped collaborator data
// Update accesses to state.project and state.collaborators
```

#### 7. Update TrackListItem
**File**: `lib/features/audio_track/presentation/widgets/track_list_item.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// Update all field accesses to use unwrapped primitives
```

#### 8. Update TrackMenuButton
**File**: `lib/features/audio_track/presentation/component/track_menu_button.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// When calling use cases that need domain entity:
// Use track.track to access the wrapped domain entity
```

#### 9. Update TrackInfoSection
**File**: `lib/features/audio_track/presentation/component/track_info_section.dart`

**Changes**: Update to accept UI models

```dart
// BEFORE:
final AudioTrack track;
final UserProfile? uploader;

// AFTER:
final AudioTrackUiModel track;
final UserProfileUiModel? uploader;

// Update field accesses to use primitives
```

#### 10. Update DeleteAudioTrackAlertDialog
**File**: `lib/features/audio_track/presentation/widgets/delete_audio_track_alert_dialog.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// Access track.name directly instead of domain entity
// Use track.track when calling use cases
```

#### 11. Update RenameAudioTrackFormSheet
**File**: `lib/features/audio_track/presentation/widgets/rename_audio_track_form_sheet.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// Update field accesses and use case calls
```

#### 12. Update UploadTrackCoverArtForm
**File**: `lib/features/audio_track/presentation/widgets/upload_track_cover_art_form.dart`

**Changes**: Update to accept UI model

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;
```

### Success Criteria

#### Automated Verification:
- [x] No compilation errors: `flutter analyze`
- [ ] All tests pass: `flutter test test/features/project_detail/`
- [x] No domain entity imports in project detail widgets (forms still use domain entities which is correct)

#### Manual Verification:
- [ ] Project detail screen loads correctly
- [ ] Update project name → UI reflects change immediately
- [ ] Add/remove tracks → Track list updates
- [ ] Change track cover art → List item reflects change immediately
- [ ] Add/remove collaborators → Collaborators section updates
- [ ] Sort tracks → Order changes correctly
- [ ] Track menu actions work (rename, delete, etc.)
- [ ] Navigation to track detail screen works
- [ ] No visual regressions

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the ProjectDetail feature works correctly before proceeding to Phase 4.

---

## Phase 4: AudioTrack & AudioComment Features Migration

### Overview
Migrate the AudioTrack and AudioComment features to use UI models. These features don't currently have manual workarounds but would benefit from proper equality handling.

### Changes Required

#### 1. Update AudioTrackState
**File**: `lib/features/audio_track/presentation/bloc/audio_track_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';

abstract class AudioTrackState extends Equatable {
  const AudioTrackState();

  @override
  List<Object> get props => [];
}

class AudioTrackInitial extends AudioTrackState {}

class AudioTrackLoading extends AudioTrackState {}

class AudioTrackLoaded extends AudioTrackState {
  final List<AudioTrackUiModel> tracks;             // CHANGED
  final bool isSyncing;
  final double? syncProgress;

  const AudioTrackLoaded({
    required this.tracks,
    this.isSyncing = false,
    this.syncProgress,
  });

  @override
  List<Object> get props => [tracks, isSyncing, syncProgress ?? 0.0];
}

class AudioTrackError extends AudioTrackState {
  final String message;

  const AudioTrackError(this.message);

  @override
  List<Object> get props => [message];
}
```

#### 2. Update AudioTrackBloc Emit Logic
**File**: `lib/features/audio_track/presentation/bloc/audio_track_bloc.dart`

**Changes**: Convert entities to UI models

```dart
// BEFORE:
emit(AudioTrackLoaded(tracks: tracks));

// AFTER:
emit(AudioTrackLoaded(
  tracks: tracks.map(AudioTrackUiModel.fromDomain).toList(),
));
```

#### 3. Update AudioCommentState
**File**: `lib/features/audio_comment/presentation/bloc/audio_comment_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

abstract class AudioCommentState extends Equatable {
  const AudioCommentState();

  @override
  List<Object?> get props => [];
}

class AudioCommentInitial extends AudioCommentState {}

class AudioCommentLoading extends AudioCommentState {}

class AudioCommentsLoaded extends AudioCommentState {
  final List<AudioCommentUiModel> comments;          // CHANGED
  final List<UserProfileUiModel> collaborators;      // CHANGED
  final bool isSyncing;
  final double? syncProgress;

  const AudioCommentsLoaded({
    required this.comments,
    required this.collaborators,
    this.isSyncing = false,
    this.syncProgress,
  });

  @override
  List<Object?> get props => [comments, collaborators, isSyncing, syncProgress ?? 0.0];
}

class AudioCommentError extends AudioCommentState {
  final String message;

  const AudioCommentError(this.message);

  @override
  List<Object> get props => [message];
}
```

#### 4. Update AudioCommentBloc Emit Logic
**File**: `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart`

**Changes**: Convert entities to UI models

```dart
// BEFORE:
emit(AudioCommentsLoaded(
  comments: comments,
  collaborators: collaborators,
));

// AFTER:
emit(AudioCommentsLoaded(
  comments: comments.map(AudioCommentUiModel.fromDomain).toList(),
  collaborators: collaborators.map(UserProfileUiModel.fromDomain).toList(),
));
```

#### 5. Update Audio Comment Components

**Files to Update**:
- `lib/features/audio_comment/presentation/components/audio_comment_card.dart`
- `lib/features/audio_comment/presentation/components/audio_comment_content.dart`
- `lib/features/audio_comment/presentation/components/audio_comment_player.dart`
- `lib/features/audio_comment/presentation/components/audio_comment_avatar.dart`
- `lib/features/audio_comment/presentation/components/comment_hybrid_content.dart`
- `lib/features/audio_comment/presentation/components/comments_list_view.dart`
- `lib/features/audio_comment/presentation/components/comments_section.dart`
- `lib/features/audio_comment/presentation/components/comments_sliver_section.dart`

**Pattern for each file**:
```dart
// BEFORE:
final AudioComment comment;
final UserProfile collaborator;

// AFTER:
final AudioCommentUiModel comment;
final UserProfileUiModel collaborator;

// Update all field accesses to use unwrapped primitives
// Use comment.comment or collaborator.profile when domain entity is needed
```

#### 6. Update TrackComponent
**File**: `lib/features/audio_track/presentation/component/track_component.dart`

**Changes**: Already uses TrackRowViewModel, ensure consistency

```dart
// TrackComponent already uses TrackRowViewModel
// Ensure it accesses fields correctly via the view model
// No major changes needed if TrackRowViewModel was updated in Phase 1
```

#### 7. Update Waveform Widgets

**Files to Update**:
- `lib/features/waveform/presentation/widgets/track_detail_player.dart`
- `lib/features/waveform/presentation/widgets/enhanced_waveform_display.dart`
- `lib/features/waveform/presentation/widgets/audio_comment_controls.dart`

**Changes**: Update to accept UI models

```dart
// BEFORE:
final AudioTrack track;

// AFTER:
final AudioTrackUiModel track;

// Access track.track when domain entity is needed for use cases
```

### Success Criteria

#### Automated Verification:
- [x] No compilation errors: `flutter analyze`
- [ ] All tests pass: `flutter test test/features/audio_track/ test/features/audio_comment/`
- [x] No domain entity imports in widgets (forms use domain entities which is correct)

#### Manual Verification:
- [ ] Track list loads and displays correctly
- [ ] Comments load and display correctly
- [ ] Add a comment → Comments list updates immediately
- [ ] Edit comment → UI reflects change
- [ ] Play audio comment → Playback works
- [ ] Comment avatar displays user info correctly
- [ ] Timestamp formatting looks correct
- [ ] Track duration formatting looks correct
- [ ] No visual regressions

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the AudioTrack and AudioComment features work correctly before proceeding to Phase 5.

---

## Phase 5: Remaining Core Features Migration

### Overview
Migrate the remaining high-traffic features: Projects list, VoiceMemos, TrackVersions, and Playlist features.

### Changes Required

#### 1. Create VoiceMemo UI Model
**File**: `lib/features/voice_memos/presentation/models/voice_memo_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/voice_memo.dart';

class VoiceMemoUiModel extends Equatable {
  final VoiceMemo memo;

  final String id;
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;
  final String? convertedToTrackId;
  final String? createdBy;

  final String formattedDuration;
  final String formattedDate;
  final bool isConverted;

  const VoiceMemoUiModel({
    required this.memo,
    required this.id,
    required this.title,
    required this.fileLocalPath,
    this.fileRemoteUrl,
    required this.duration,
    required this.recordedAt,
    this.convertedToTrackId,
    this.createdBy,
    required this.formattedDuration,
    required this.formattedDate,
    required this.isConverted,
  });

  factory VoiceMemoUiModel.fromDomain(VoiceMemo memo) {
    return VoiceMemoUiModel(
      memo: memo,
      id: memo.id.value,
      title: memo.title,
      fileLocalPath: memo.fileLocalPath,
      fileRemoteUrl: memo.fileRemoteUrl,
      duration: memo.duration,
      recordedAt: memo.recordedAt,
      convertedToTrackId: memo.convertedToTrackId,
      createdBy: memo.createdBy?.value,
      formattedDuration: _formatDuration(memo.duration),
      formattedDate: _formatDate(memo.recordedAt),
      isConverted: memo.convertedToTrackId != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  List<Object?> get props => [
    id, title, fileLocalPath, fileRemoteUrl, duration,
    recordedAt, convertedToTrackId, createdBy,
    formattedDuration, formattedDate, isConverted,
  ];
}
```

#### 2. Create TrackVersion UI Model
**File**: `lib/features/track_version/presentation/models/track_version_ui_model.dart` (NEW)

**Changes**: Create new UI model class

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/track_version.dart';

class TrackVersionUiModel extends Equatable {
  final TrackVersion version;

  final String id;
  final String trackId;
  final int versionNumber;
  final String? label;
  final String? fileLocalPath;
  final String? fileRemoteUrl;
  final int? durationMs;
  final String status;
  final DateTime createdAt;
  final String createdBy;

  final String displayLabel;
  final String formattedDuration;
  final bool hasLocalFile;

  const TrackVersionUiModel({
    required this.version,
    required this.id,
    required this.trackId,
    required this.versionNumber,
    this.label,
    this.fileLocalPath,
    this.fileRemoteUrl,
    this.durationMs,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.displayLabel,
    required this.formattedDuration,
    required this.hasLocalFile,
  });

  factory TrackVersionUiModel.fromDomain(TrackVersion version) {
    return TrackVersionUiModel(
      version: version,
      id: version.id.value,
      trackId: version.trackId.value,
      versionNumber: version.versionNumber,
      label: version.label,
      fileLocalPath: version.fileLocalPath,
      fileRemoteUrl: version.fileRemoteUrl,
      durationMs: version.durationMs,
      status: version.status.toString(),
      createdAt: version.createdAt,
      createdBy: version.createdBy.value,
      displayLabel: version.label ?? 'Version ${version.versionNumber}',
      formattedDuration: version.durationMs != null
          ? _formatDuration(Duration(milliseconds: version.durationMs!))
          : '--:--',
      hasLocalFile: version.fileLocalPath != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id, trackId, versionNumber, label, fileLocalPath,
    fileRemoteUrl, durationMs, status, createdAt, createdBy,
    displayLabel, formattedDuration, hasLocalFile,
  ];
}
```

#### 3. Update ProjectsState
**File**: `lib/features/projects/presentation/blocs/projects_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';

// Update ProjectsLoaded state (around lines 49-78)
class ProjectsLoaded extends ProjectsState {
  final List<ProjectUiModel> projects;              // CHANGED
  final bool isSyncing;
  final double? syncProgress;
  final ProjectSort sort;

  const ProjectsLoaded({
    required this.projects,
    this.isSyncing = false,
    this.syncProgress,
    this.sort = ProjectSort.newest,
  });

  @override
  List<Object?> get props => [projects, isSyncing, syncProgress ?? 0.0, sort];

  ProjectsLoaded copyWith({
    List<ProjectUiModel>? projects,                 // CHANGED
    bool? isSyncing,
    double? syncProgress,
    ProjectSort? sort,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
      sort: sort ?? this.sort,
    );
  }
}

// Update other states that contain Project (ProjectCreatedSuccess, ProjectDetailsLoaded, etc.)
```

#### 4. Update VoiceMemoState
**File**: `lib/features/voice_memos/presentation/bloc/voice_memo_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:trackflow/features/voice_memos/presentation/models/voice_memo_ui_model.dart';

class VoiceMemosLoaded extends VoiceMemoState {
  final List<VoiceMemoUiModel> memos;               // CHANGED

  const VoiceMemosLoaded(this.memos);

  @override
  List<Object?> get props => [memos];
}
```

#### 5. Update TrackVersionsState
**File**: `lib/features/track_version/presentation/blocs/track_versions/track_versions_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:trackflow/features/track_version/presentation/models/track_version_ui_model.dart';

class TrackVersionsLoaded extends TrackVersionsState {
  final List<TrackVersionUiModel> versions;         // CHANGED
  final TrackVersionId? activeVersionId;

  const TrackVersionsLoaded({
    required this.versions,
    this.activeVersionId,
  });

  @override
  List<Object?> get props => [versions, activeVersionId];
}
```

#### 6. Update PlaylistState
**File**: `lib/features/playlist/presentation/bloc/playlist_state.dart`

**Changes**: Replace domain entities with UI models

```dart
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';

class PlaylistState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<AudioTrackUiModel> tracks;             // CHANGED
  final List<TrackRowViewModel> items;

  const PlaylistState({
    required this.isLoading,
    required this.error,
    required this.tracks,
    required this.items,
  });

  // Update copyWith accordingly
}
```

#### 7. Update All Blocs Emit Logic

Update emit logic in:
- `lib/features/projects/presentation/blocs/projects_bloc.dart`
- `lib/features/voice_memos/presentation/bloc/voice_memo_bloc.dart`
- `lib/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart`
- `lib/features/playlist/presentation/bloc/playlist_bloc.dart`

**Pattern**:
```dart
// BEFORE:
emit(ProjectsLoaded(projects: projects));

// AFTER:
emit(ProjectsLoaded(
  projects: projects.map(ProjectUiModel.fromDomain).toList(),
));
```

#### 8. Update All Widgets and Components

**Projects Feature**:
- `lib/features/projects/presentation/components/project_component.dart`
- `lib/features/projects/presentation/widgets/create_project_form.dart`
- `lib/features/projects/presentation/widgets/edit_project_form.dart`
- `lib/features/projects/presentation/widgets/delete_project_dialog.dart`
- `lib/features/projects/presentation/screens/project_list_screen.dart`

**VoiceMemos Feature**:
- `lib/features/voice_memos/presentation/voice_memos_screen/components/voice_memo_card.dart`
- `lib/features/voice_memos/presentation/widgets/voice_memo_rename_dialog.dart`

**TrackVersions Feature**:
- `lib/features/track_version/presentation/components/version_header_component.dart`
- `lib/features/track_version/presentation/widgets/versions_list.dart`
- `lib/features/track_version/presentation/screens/track_detail_screen.dart`

**Playlist Feature**:
- `lib/features/playlist/presentation/widgets/playlist_widget.dart`
- `lib/features/playlist/presentation/widgets/playlist_tracks_widget.dart`

**Pattern for all**:
```dart
// BEFORE:
final Project project;
final AudioTrack track;
final VoiceMemo memo;
final TrackVersion version;

// AFTER:
final ProjectUiModel project;
final AudioTrackUiModel track;
final VoiceMemoUiModel memo;
final TrackVersionUiModel version;

// Update field accesses to use unwrapped primitives
// Use .project, .track, .memo, .version to access domain entity when needed
```

### Success Criteria

#### Automated Verification:
- [x] UI Models created (VoiceMemoUiModel, TrackVersionUiModel)
- [x] States updated to use UI models
- [x] Bloc emit logic updated to convert entities to UI models
- [x] No compilation errors: `flutter analyze` - 0 errors, only pre-existing warnings
- [x] All widget updates completed (Projects, VoiceMemos, TrackVersions, Playlist)
- [ ] All tests pass: `flutter test test/features/projects/ test/features/voice_memos/ test/features/track_version/ test/features/playlist/`
- [ ] No domain entity imports in widgets: `grep -r "domain/entities" lib/features/{projects,voice_memos,track_version,playlist}/presentation/widgets/`

#### Manual Verification:
- [x] Projects list loads and displays correctly
- [x] Create/edit/delete project works
- [x] Voice memos list loads correctly
- [x] Record and playback voice memos works
- [x] Track versions list displays correctly
- [x] Version switching works
- [x] Playlist functionality works
- [x] Sort and filter operations work correctly
- [x] No visual regressions
- [x] UI now properly reacts to local database changes

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that all core features work correctly before proceeding to Phase 6.

---

## Phase 6: Final Cleanup and Documentation

### Overview
Final cleanup pass to ensure consistency, update documentation, and handle any edge cases.

### Changes Required

#### 1. Remove Manual Equality Workarounds
**Files to verify**:
- Confirm `lib/features/dashboard/presentation/bloc/dashboard_state.dart` no longer has manual expansion
- Confirm `lib/features/project_detail/presentation/bloc/project_detail_state.dart` no longer has manual expansion
- Search for any remaining manual workarounds: `grep -r "\.map((.*) => \[" lib/features/*/presentation/bloc/*_state.dart`

#### 2. Update CLAUDE.md
**File**: `CLAUDE.md`

**Changes**: Add UI Models section

```markdown
## Architecture Guidelines

### Clean Architecture + DDD Structure
- **Domain Layer**: Contains business entities, value objects, repositories contracts, and use cases
- **Data Layer**: Implements repositories, datasources (Firebase/Isar), and DTOs
- **Presentation Layer**: BLoC state management, screens, widgets, and **UI models**
- **Core**: Shared kernel with dependency injection, error handling, and utilities

### Key Architectural Rules
1. **Always use @lib/core/theme/ in any visual code** - Use the established theme system
2. **Always write in English in the code base even comments** - Maintain consistency
3. **Follow Clean Architecture dependency rules** - Domain layer must not depend on external layers
4. **Use BLoC pattern for state management** - Consistent reactive programming
5. **Use UI Models in presentation layer** - Wrap domain entities with Equatable-friendly models
6. **Implement Either<Failure, Success> for error handling** - Functional error handling
7. **Use dependency injection with get_it and injectable** - Loose coupling

### UI Models Pattern
Each feature should have UI models under `presentation/models/` that:
- Wrap domain entities using composition pattern (`final Entity entity`)
- Unwrap value objects to primitives for easy UI access
- Extend Equatable for proper state comparison
- Use `fromDomain()` static factory for conversion
- Include UI-specific computed fields (formatted strings, display names, etc.)

**Example**:
```dart
class ProjectUiModel extends Equatable {
  final Project project;              // Domain entity
  final String id;                    // Unwrapped primitives
  final String name;
  // ... other fields

  factory ProjectUiModel.fromDomain(Project project) {
    return ProjectUiModel(
      project: project,
      id: project.id.value,
      name: project.name.value.getOrElse(() => ''),
      // ...
    );
  }

  @override
  List<Object?> get props => [id, name, /* ... */];
}
```

### Feature Development Pattern
Each feature follows this structure:
```
features/[feature_name]/
├── domain/
│   ├── entities/         # Business objects
│   ├── repositories/     # Repository contracts
│   ├── usecases/        # Business logic
│   └── value_objects/   # Domain value objects
├── data/
│   ├── datasources/     # Firebase/Isar implementations
│   ├── models/          # DTOs and documents
│   └── repositories/    # Repository implementations
└── presentation/
    ├── bloc/           # State management (uses UI models)
    ├── models/         # UI models (wrap entities)
    ├── screens/        # UI screens
    └── widgets/        # Reusable components
```
```

#### 3. Create UI Models README
**File**: `lib/features/README_UI_MODELS.md` (NEW)

**Changes**: Create comprehensive guide

```markdown
# UI Models Pattern

## Overview

UI Models are presentation-layer classes that wrap domain entities to provide:
- Proper equality comparison for Equatable/BLoC states
- Unwrapped primitives for simpler widget code
- UI-specific computed fields (formatted strings, display logic)
- Clear separation between domain and presentation

## When to Create a UI Model

Create a UI model when:
- A domain entity is stored in a Bloc state
- A domain entity is passed to multiple widgets
- You need UI-specific computed fields (formatted dates, display names)
- Value objects need unwrapping for widgets

## Pattern Structure

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/your_entity.dart';

class YourEntityUiModel extends Equatable {
  // 1. Composition: contain the domain entity
  final YourEntity entity;

  // 2. Unwrapped primitives for easy access
  final String id;
  final String name;
  // ... other primitive fields

  // 3. UI-specific computed fields
  final String displayName;
  final String formattedDate;

  const YourEntityUiModel({
    required this.entity,
    required this.id,
    required this.name,
    required this.displayName,
    required this.formattedDate,
  });

  // 4. fromDomain factory for conversion
  factory YourEntityUiModel.fromDomain(YourEntity entity) {
    return YourEntityUiModel(
      entity: entity,
      id: entity.id.value,
      name: entity.name.value.getOrElse(() => ''),
      displayName: _computeDisplayName(entity),
      formattedDate: _formatDate(entity.createdAt),
    );
  }

  // 5. Equatable props - primitives only
  @override
  List<Object?> get props => [id, name, displayName, formattedDate];
}
```

## Usage in Blocs

Convert domain entities to UI models when emitting states:

```dart
// In event handler
emit(state.copyWith(
  projects: projects.map(ProjectUiModel.fromDomain).toList(),
  tracks: tracks.map(AudioTrackUiModel.fromDomain).toList(),
));
```

## Usage in Widgets

Widgets receive UI models and access primitives directly:

```dart
class ProjectCard extends StatelessWidget {
  final ProjectUiModel project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(project.name),          // Direct primitive access
          Text(project.description),
          Text(project.formattedDate),
        ],
      ),
    );
  }
}
```

## Accessing Domain Entity

When you need the wrapped domain entity (e.g., for use cases):

```dart
// UI model contains the entity
final projectUiModel = state.project;

// Access domain entity when needed
final result = await updateProjectUseCase(projectUiModel.project);
```

## Examples

See existing UI models:
- `lib/features/projects/presentation/models/project_ui_model.dart`
- `lib/features/audio_track/presentation/models/audio_track_ui_model.dart`
- `lib/features/user_profile/presentation/models/user_profile_ui_model.dart`
- `lib/features/audio_comment/presentation/models/audio_comment_ui_model.dart`
```

#### 4. Final Verification Script
**File**: `scripts/verify_ui_models.sh` (NEW)

**Changes**: Create verification script

```bash
#!/bin/bash

echo "Verifying UI Models Migration..."
echo ""

# Check for domain entities in state files
echo "1. Checking for domain entities in state files..."
if grep -r "domain/entities" lib/features/*/presentation/bloc/*_state.dart; then
  echo "❌ ERROR: Found domain entity imports in state files"
  exit 1
else
  echo "✅ No domain entities in state files"
fi

# Check for manual equality workarounds
echo ""
echo "2. Checking for manual equality workarounds..."
if grep -r "\.map((.*) => \[" lib/features/*/presentation/bloc/*_state.dart; then
  echo "⚠️  WARNING: Found potential manual equality workarounds"
else
  echo "✅ No manual equality workarounds found"
fi

# Check for domain entities in widgets
echo ""
echo "3. Checking for domain entities in widgets..."
if grep -r "domain/entities" lib/features/*/presentation/widgets/ lib/features/*/presentation/components/; then
  echo "⚠️  WARNING: Found domain entity imports in widgets"
else
  echo "✅ No domain entities in widgets"
fi

# Run Flutter analyze
echo ""
echo "4. Running Flutter analyze..."
if flutter analyze; then
  echo "✅ Flutter analyze passed"
else
  echo "❌ Flutter analyze failed"
  exit 1
fi

echo ""
echo "✅ All verifications passed!"
```

#### 5. Update Tests

**Pattern for updating tests**:
```dart
// BEFORE:
test('should emit state with project', () {
  final project = Project(...);
  expect(state.project, project);
});

// AFTER:
test('should emit state with project UI model', () {
  final project = Project(...);
  final projectUi = ProjectUiModel.fromDomain(project);
  expect(state.project, projectUi);
});
```

Update tests in:
- `test/features/dashboard/presentation/bloc/`
- `test/features/project_detail/presentation/bloc/`
- `test/features/audio_track/presentation/bloc/`
- `test/features/audio_comment/presentation/bloc/`
- `test/features/projects/presentation/blocs/`
- All other feature test directories

### Success Criteria

#### Automated Verification:
- [x] Verification script created: `scripts/verify_ui_models.sh`
- [x] Flutter analyze passes: 0 errors (only pre-existing warnings)
- [x] All UI models have fromDomain() factories
- [x] All UI models extend Equatable
- [x] Manual equality workarounds removed
- [ ] Deferred features (auth, audio_player, cache_management, etc.) - will be migrated in future phases
- [ ] All tests pass: `flutter test`

#### Manual Verification:
- [x] Full app smoke test - all features work correctly
- [x] No visual regressions anywhere
- [x] Real-time updates work correctly (rename, cover art changes, etc.)
- [x] Performance is acceptable
- [x] UI properly reacts to local database changes
- [x] Code review confirms pattern consistency
- [x] Documentation is clear and accurate (CLAUDE.md + README_UI_MODELS.md)

**Implementation Note**: After completing this phase and all verification passes, the UI Models refactoring is complete!

---

## Testing Strategy

### Unit Tests
For each UI model:
- Test `fromDomain()` factory correctly unwraps all fields
- Test Equatable equality works correctly
- Test computed fields return expected values
- Test edge cases (null values, empty strings, etc.)

Example:
```dart
test('ProjectUiModel.fromDomain should unwrap all fields', () {
  final project = Project(
    id: ProjectId(),
    name: ProjectName.create('Test Project').getOrElse(() => throw Error()),
    // ... other fields
  );

  final uiModel = ProjectUiModel.fromDomain(project);

  expect(uiModel.id, project.id.value);
  expect(uiModel.name, 'Test Project');
  expect(uiModel.project, project);
});

test('ProjectUiModel equality should work with same values', () {
  final project = Project(...);
  final uiModel1 = ProjectUiModel.fromDomain(project);
  final uiModel2 = ProjectUiModel.fromDomain(project);

  expect(uiModel1, uiModel2);
});
```

### Integration Tests
- Test that state changes trigger UI rebuilds correctly
- Test that manual updates (rename, cover change) reflect immediately
- Test sort and filter operations work correctly

### Manual Testing Steps
After each phase:
1. Open the affected feature screen
2. Verify all data displays correctly
3. Perform CRUD operations (create, read, update, delete)
4. Verify real-time updates work
5. Check for any visual regressions
6. Test edge cases (empty lists, null values, errors)

## Performance Considerations

**Conversion Overhead**:
- `fromDomain()` creates new UI model instances
- Acceptable overhead for typical list sizes (< 1000 items)
- Consider caching for very large lists if needed

**Memory Usage**:
- UI models contain both primitives and domain entity
- Small overhead per entity (a few extra strings/primitives)
- Negligible for typical app usage

**Optimization Opportunities**:
- Use const constructors where possible
- Consider memoization for expensive computed fields
- Profile if performance issues arise

## Migration Notes

### Handling Navigation
When navigating with entities:
```dart
// Option 1: Pass UI model, extract entity in target screen
context.push(route, extra: projectUi.project);

// Option 2: Pass entity directly, convert in target screen
context.push(route, extra: project);
```

### Handling Use Cases
Use cases still expect domain entities:
```dart
// Extract domain entity from UI model
final result = await updateProjectUseCase(
  projectUi.project.copyWith(name: newName),
);
```

### Handling Forms
Forms can work with either:
```dart
// Option 1: Pass UI model, extract entity when submitting
class EditForm extends StatelessWidget {
  final ProjectUiModel project;

  void _submit() {
    updateProjectUseCase(project.project.copyWith(...));
  }
}

// Option 2: Pass entity directly
class EditForm extends StatelessWidget {
  final Project project;
}
```

## References

- Original issue: Architectural inconsistency with domain entities in presentation
- Existing pattern: [TrackRowViewModel](lib/features/playlist/presentation/models/track_row_view_model.dart)
- Domain entity equality: [Entity<T>](lib/core/domain/entity.dart#L7-L12)
- Manual workarounds: [DashboardState](lib/features/dashboard/presentation/bloc/dashboard_state.dart#L43-L78), [ProjectDetailState](lib/features/project_detail/presentation/bloc/project_detail_state.dart#L76-L107)

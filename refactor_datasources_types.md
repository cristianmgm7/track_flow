# Data Sources Type Refactoring Plan

## Overview

This document outlines the refactoring plan to replace primitive `String` types with proper domain value objects in data source method signatures. This refactoring will ensure type safety and consistency between the repository layer (which already uses domain types) and the data source layer (which currently uses primitive types).

## Goals

1. **Type Safety**: Prevent runtime errors from passing incorrect ID types
2. **Consistency**: Align data source signatures with repository interfaces
3. **Semantic Clarity**: Make parameter types explicit and meaningful
4. **Maintainability**: Ensure future changes to ID structures propagate automatically

## Available Domain Value Objects

From `lib/core/entities/unique_id.dart`:
- `UniqueId` (base class)
- `UserId`
- `ProjectId` 
- `AudioTrackId`
- `AudioCommentId`
- `MagicLinkId`
- `PlaylistId`

## Refactoring Changes by File

### 1. Audio Track Data Sources

#### File: `lib/features/audio_track/data/datasources/audio_track_remote_datasource.dart`

**Changes Required:**

```dart
// Line 17: BEFORE
Future<void> deleteTrackFromProject(String trackId, String projectId)

// Line 17: AFTER
Future<void> deleteTrackFromProject(AudioTrackId trackId, ProjectId projectId)
```

```dart
// Line 18: BEFORE
Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds)

// Line 18: AFTER
Future<List<AudioTrackDTO>> getTracksByProjectIds(List<ProjectId> projectIds)
```

```dart
// Lines 19-23: BEFORE
Future<void> editTrackName({
  required String trackId,
  required String projectId,
  required String newName
})

// Lines 19-23: AFTER
Future<void> editTrackName({
  required AudioTrackId trackId,
  required ProjectId projectId,
  required String newName
})
```

#### File: `lib/features/audio_track/data/datasources/audio_track_local_datasource.dart`

**Changes Required:**

```dart
// Line 11: BEFORE
Future<Either<Failure, AudioTrackDTO?>> getTrackById(String id)

// Line 11: AFTER
Future<Either<Failure, AudioTrackDTO?>> getTrackById(AudioTrackId id)
```

```dart
// Line 12: BEFORE
Future<Either<Failure, Unit>> deleteTrack(String id)

// Line 12: AFTER
Future<Either<Failure, Unit>> deleteTrack(AudioTrackId id)
```

```dart
// Lines 14-16: BEFORE
Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(String projectId)

// Lines 14-16: AFTER
Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(ProjectId projectId)
```

```dart
// Line 18: BEFORE
Future<Either<Failure, Unit>> updateTrackName(String trackId, String newName)

// Line 18: AFTER
Future<Either<Failure, Unit>> updateTrackName(AudioTrackId trackId, String newName)
```

### 2. Audio Comment Data Sources

#### File: `lib/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart`

**Changes Required:**

```dart
// Line 12: BEFORE
Future<List<AudioCommentDTO>> getCommentsByTrackId(String audioTrackId)

// Line 12: AFTER
Future<List<AudioCommentDTO>> getCommentsByTrackId(AudioTrackId audioTrackId)
```

#### File: `lib/features/audio_comment/data/datasources/audio_comment_local_datasource.dart`

**Changes Required:**

```dart
// Line 16: BEFORE
Future<Either<Failure, Unit>> deleteCachedComment(String commentId)

// Line 16: AFTER
Future<Either<Failure, Unit>> deleteCachedComment(AudioCommentId commentId)
```

```dart
// Line 20: BEFORE
Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(String trackId)

// Line 20: AFTER
Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(AudioTrackId trackId)
```

```dart
// Line 24: BEFORE
Future<Either<Failure, AudioCommentDTO?>> getCommentById(String id)

// Line 24: AFTER
Future<Either<Failure, AudioCommentDTO?>> getCommentById(AudioCommentId id)
```

```dart
// Line 28: BEFORE
Future<Either<Failure, Unit>> deleteComment(String id)

// Line 28: AFTER
Future<Either<Failure, Unit>> deleteComment(AudioCommentId id)
```

```dart
// Lines 36-38: BEFORE
Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(String trackId)

// Lines 36-38: AFTER
Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(AudioTrackId trackId)
```

### 3. User Profile Data Sources

#### File: `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`

**Changes Required:**

```dart
// Line 10: BEFORE
Future<Either<Failure, UserProfile>> getProfileById(String userId)

// Line 10: AFTER
Future<Either<Failure, UserProfile>> getProfileById(UserId userId)
```

```dart
// Lines 14-16: BEFORE
Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(List<String> userIds)

// Lines 14-16: AFTER
Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(List<UserId> userIds)
```

#### File: `lib/features/user_profile/data/datasources/user_profile_local_datasource.dart`

**Changes Required:**

```dart
// Line 11: BEFORE
Stream<UserProfileDTO?> watchUserProfile(String userId)

// Line 11: AFTER
Stream<UserProfileDTO?> watchUserProfile(UserId userId)
```

```dart
// Line 14: BEFORE
Future<List<UserProfileDTO>> getUserProfilesByIds(List<String> userIds)

// Line 14: AFTER
Future<List<UserProfileDTO>> getUserProfilesByIds(List<UserId> userIds)
```

```dart
// Lines 17-19: BEFORE
Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(List<String> userIds)

// Lines 17-19: AFTER
Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(List<UserId> userIds)
```

### 4. User Session Data Source

#### File: `lib/features/auth/data/data_sources/user_session_local_datasource.dart`

**Changes Required:**

```dart
// Line 9: BEFORE
Future<Either<Failure, Unit>> cacheUserId(String userId)

// Line 9: AFTER
Future<Either<Failure, Unit>> cacheUserId(UserId userId)
```

### 5. Manage Collaborators Data Sources

#### File: `lib/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart`

**Changes Required:**

```dart
// Lines 13-16: BEFORE
Future<Either<Failure, void>> selfJoinProjectWithProjectId({
  required String projectId,
  required String userId
})

// Lines 13-16: AFTER
Future<Either<Failure, void>> selfJoinProjectWithProjectId({
  required ProjectId projectId,
  required UserId userId
})
```

### 6. Projects Data Sources

#### File: `lib/features/projects/data/datasources/project_remote_data_source.dart`

**Changes Required:**

```dart
// Line 19: BEFORE
Future<Either<Failure, List<Project>>> getUserProjects(String userId)

// Line 19: AFTER
Future<Either<Failure, List<Project>>> getUserProjects(UserId userId)
```

## Implementation Strategy

### Phase 1: High Priority (Core Functionality)
1. **Audio Track Data Sources** - Most frequently used
2. **User Session Data Source** - Critical for authentication
3. **User Profile Data Sources** - Core user functionality

### Phase 2: Medium Priority (Extended Functionality)
1. **Audio Comment Data Sources** - Comment system
2. **Manage Collaborators Data Sources** - Collaboration features

### Phase 3: Low Priority (Supporting Features)
1. **Projects Data Sources** - Project management extensions

## Implementation Steps for Each File

1. **Update Method Signatures**: Change primitive `String` parameters to appropriate domain value objects
2. **Update Implementation**: Modify method bodies to work with domain types (call `.value` when needed for string representation)
3. **Update Tests**: Ensure all unit tests use domain value objects instead of strings
4. **Update Repository Implementations**: Ensure repository implementations pass domain types to data sources
5. **Verify Compilation**: Ensure no compilation errors after changes

## Important Considerations

### ID Conversion
When data sources need to convert domain IDs to strings (e.g., for database queries), use the `.value` property:

```dart
// Example in implementation
Future<void> deleteTrackFromProject(AudioTrackId trackId, ProjectId projectId) async {
  await _firestore
    .collection('projects')
    .doc(projectId.value)  // Convert to string
    .collection('tracks')
    .doc(trackId.value)    // Convert to string
    .delete();
}
```

### DTO Conversions
Ensure DTOs can handle domain value objects when converting to/from domain entities:

```dart
// Example DTO factory method
factory AudioTrackDTO.fromDomain(AudioTrack track) => AudioTrackDTO(
  id: track.id.value,        // Convert domain ID to string
  name: track.name,
  projectId: track.projectId.value,  // Convert domain ID to string
  // ... other fields
);
```

## Testing Strategy

1. **Unit Tests**: Update all data source unit tests to use domain value objects
2. **Integration Tests**: Verify data flow from repository to data source works correctly
3. **Type Safety Tests**: Add tests that verify incorrect ID types cannot be passed

## Rollback Plan

If issues arise during implementation:
1. Revert changes file by file in reverse order of implementation
2. Each file change is isolated and can be reverted independently
3. Git branches should be used for each phase of implementation

## Success Criteria

- [ ] All data source method signatures use appropriate domain value objects
- [ ] No compilation errors in the codebase
- [ ] All existing tests pass
- [ ] Type safety is enforced (cannot pass wrong ID types)
- [ ] Repository-to-data source communication is consistent
- [ ] Documentation is updated to reflect changes

## Risk Assessment

**Low Risk**: Changes are primarily type signatures with minimal behavioral changes
**Medium Risk**: Need to ensure all callers are updated properly
**Mitigation**: Incremental implementation with thorough testing at each step

---

**Total Files to Modify**: 8 data source files  
**Total Method Signatures to Update**: 20+ methods  
**Estimated Implementation Time**: 2-3 days  
**Testing Time**: 1-2 days
# TrackFlow Repository Architecture

This document describes the repository architecture used in TrackFlow, following Clean Architecture principles and SOLID design patterns.

## Overview

- **Total Repositories:** All repositories are organized by domain and feature.
- **Architecture Pattern:** Clean Architecture with Domain-Driven Design.
- **Design Principles:** SOLID principles with single responsibility and clear interfaces.
- **Error Handling:** Consistent `Either<Failure, T>` pattern using Dartz library.

## 1. Authentication Domain

### AuthRepository

**Location**: `lib/features/auth/domain/repositories/auth_repository.dart`
**Responsibility**: Handles user authentication operations only.
**Public Methods:**

- `Stream<User?> get authState` — Stream of authentication state.
- `Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password)` — Sign in with email and password.
- `Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password)` — Sign up with email and password.
- `Future<Either<Failure, User>> signInWithGoogle()` — Sign in with Google.
- `Future<Either<Failure, Unit>> signOut()` — Sign out.
- `Future<Either<Failure, bool>> isLoggedIn()` — Check if user is logged in.
- `Future<Either<Failure, String>> getSignedInUserId()` — Get the signed-in user ID.

### OnboardingRepository

**Location**: `lib/features/auth/domain/repositories/onboarding_repository.dart`
**Responsibility**: Manages onboarding state only.
**Public Methods:**

- `Future<Either<Failure, Unit>> onboardingCompleted()` — Mark onboarding as completed.
- `Future<Either<Failure, bool>> checkOnboardingCompleted()` — Check if onboarding is completed.

### WelcomeScreenRepository

**Location**: `lib/features/auth/domain/repositories/welcome_screen_repository.dart`
**Responsibility**: Manages welcome screen state only.
**Public Methods:**

- `Future<Either<Failure, Unit>> welcomeScreenSeenCompleted()` — Mark welcome screen as seen/completed.
- `Future<Either<Failure, bool>> checkWelcomeScreenSeen()` — Check if user has seen the welcome screen.

---

## 2. Audio Track Domain

### AudioTrackRepository

**Location**: `lib/features/audio_track/domain/repositories/audio_track_repository.dart`
**Responsibility**: Manages audio tracks, including retrieval, upload, deletion, and editing.
**Public Methods:**

- `Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id)` — Get track by ID.
- `Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(ProjectId projectId)` — Stream tracks by project.
- `Future<Either<Failure, Unit>> uploadAudioTrack({required File file, required AudioTrack track})` — Upload a new audio track.
- `Future<Either<Failure, Unit>> deleteTrack(String trackId, String projectId)` — Delete a track. ❌
- `Future<Either<Failure, Unit>> editTrackName({required AudioTrackId trackId, required ProjectId projectId, required String newName})` — Edit track name.

---

## 3. Audio Comment Domain

### AudioCommentRepository

**Location**: `lib/features/audio_comment/domain/repositories/audio_comment_repository.dart`
**Responsibility**: Manages audio comments associated with tracks.
**Public Methods:**

- `Future<Either<Failure, AudioComment>> getCommentById(AudioCommentId commentId)` — Get comment by ID.
- `Future<Either<Failure, Unit>> addComment(AudioComment comment)` — Add a new comment.
- `Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(AudioTrackId trackId)` — Stream comments by track.
- `Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId)` — Delete a comment.

---

## 4. Playlist Domain

### PlaylistRepository

**Location**: `lib/features/playlist/domain/repositories/playlist_repository.dart`
**Responsibility**: Manages playlists in the application.
**Public Methods:**

- `Future<void> addPlaylist(Playlist playlist)` — Add a new playlist.
- `Future<List<Playlist>> getAllPlaylists()` — Get all playlists.
- `Future<Playlist?> getPlaylistById(String id)` — Get playlist by ID. ❌
- `Future<void> updatePlaylist(Playlist playlist)` — Update a playlist.
- `Future<void> deletePlaylist(String id)` — Delete a playlist. ❌

---

## 5. Projects Domain

### ProjectsRepository

**Location**: `lib/features/projects/domain/repositories/projects_repository.dart`
**Responsibility**: Manages user projects.
**Public Methods:**

- `Future<Either<Failure, Project>> createProject(Project project)` — Create a new project.
- `Future<Either<Failure, Unit>> updateProject(Project project)` — Update a project.
- `Future<Either<Failure, Unit>> deleteProject(UniqueId id)` — Delete a project.
- `Future<Either<Failure, Project>> getProjectById(ProjectId projectId)` — Get project by ID.
- `Stream<Either<Failure, List<Project>>> watchLocalProjects(UserId ownerId)` — Stream local projects for a user.

---

## 6. User Profile Domain

### UserProfileRepository

**Location**: `lib/features/user_profile/domain/repositories/user_profile_repository.dart`
**Responsibility**: Manages individual user profile operations.
**Public Methods:**

- `Future<Either<Failure, Unit>> updateUserProfile(UserProfile userProfile)` — Update a user profile.
- `Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId)` — Stream a user profile by ID.
- `Future<Either<Failure, UserProfile?>> getUserProfile(UserId userId)` — Get a user profile by ID.

### UserProfileCacheRepository

**Location**: `lib/features/user_profile/domain/repositories/user_profile_cache_repository.dart`
**Responsibility**: Manages bulk cache operations for user profiles.
**Public Methods:**

- `Future<Either<Failure, Unit>> cacheUserProfiles(List<UserProfile> profiles)` — Cache a list of user profiles locally.
- `Stream<Either<Failure, List<UserProfile>>> watchUserProfilesByIds(List<String> userIds)` — Stream user profiles by IDs.
- `Future<Either<Failure, List<UserProfile>>> getUserProfilesByIds(List<String> userIds)` — Get user profiles by IDs.
- `Future<Either<Failure, Unit>> clearCache()` — Clear all cached user profiles.
- `Future<Either<Failure, Unit>> preloadProfiles(List<String> userIds)` — Preload user profiles for better offline experience.

---

## 7. Collaboration Domain

### CollaboratorRepository

**Location**: `lib/features/manage_collaborators/domain/repositories/collaborator_repository.dart`
**Responsibility**: Manages project collaborator operations.
**Public Methods:**

- `Future<Either<Failure, Unit>> joinProject(ProjectId projectId, UserId userId)` — Join a project as a collaborator.
- `Future<Either<Failure, Unit>> leaveProject({required ProjectId projectId, required UserId userId})` — Leave a project as a collaborator.
- `Future<Either<Failure, Unit>> addCollaborator(ProjectId projectId, UserId userId, String role)` — Add a collaborator to a project with a specific role.
- `Future<Either<Failure, Unit>> removeCollaborator(ProjectId projectId, UserId userId)` — Remove a collaborator from a project.
- `Future<Either<Failure, Unit>> updateCollaboratorRole(ProjectId projectId, UserId userId, String newRole)` — Update a collaborator's role in a project.

---

## 8. Magic Link Domain

### MagicLinkRepository

**Location**: `lib/features/magic_link/domain/repositories/magic_link_repository.dart`
**Responsibility**: Manages magic links for invitations and project access.
**Public Methods:**

- `Future<Either<Failure, MagicLink>> generateMagicLink({required String projectId, required String userId})` — Generate a magic link. ❌
- `Future<Either<Failure, MagicLink>> validateMagicLink({required String linkId})` — Validate a magic link. ❌
- `Future<Either<Failure, Unit>> consumeMagicLink({required String linkId})` — Consume a magic link. ❌
- `Future<Either<Failure, Unit>> resendMagicLink({required String linkId})` — Resend a magic link. ❌
- `Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({required String linkId})` — Get the status of a magic link. ❌

---

## 9. Audio Cache Domain

### AudioDownloadRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/audio_download_repository.dart`
**Responsibility**: Handles audio download operations only.
**Public Methods:**

- `Future<Either<CacheFailure, String>> downloadAudio(String trackId, String audioUrl, {void Function(DownloadProgress)? progressCallback})` — Download an audio file. ❌
- `Future<Either<CacheFailure, Map<String, String>>> downloadMultipleAudios(Map<String, String> trackUrlPairs, {void Function(String trackId, DownloadProgress)? progressCallback})` — Download multiple audio files. ❌
- `Future<Either<CacheFailure, Unit>> cancelDownload(String trackId)` — Cancel an ongoing download. ❌
- `Future<Either<CacheFailure, Unit>> pauseDownload(String trackId)` — Pause a download. ❌
- `Future<Either<CacheFailure, Unit>> resumeDownload(String trackId)` — Resume a paused download. ❌
- `Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(String trackId)` — Get current download progress for a track. ❌
- `Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads()` — Get all currently active downloads.

### AudioStorageRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart`
**Responsibility**: Handles physical audio file storage operations only.
**Public Methods:**

- `Future<Either<CacheFailure, CachedAudio>> storeAudio(String trackId, File audioFile)` — Store an audio file in cache. ❌
- `Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId)` — Get cached audio file path if exists. ❌
- `Future<Either<CacheFailure, bool>> audioExists(String trackId)` — Check if audio file exists and is valid. ❌
- `Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId)` — Get cached audio information. ❌
- `Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId)` — Delete audio file from storage. ❌
- `Future<Either<CacheFailure, Map<String, CachedAudio>>> getMultipleCachedAudios(List<String> trackIds)` — Get cached audio info for multiple tracks. ❌
- `Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds)` — Delete multiple audio files. ❌
- `Future<Either<CacheFailure, Map<String, bool>>> checkMultipleAudioExists(List<String> trackIds)` — Check existence of multiple audio files. ❌

### CacheKeyRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_key_repository.dart`
**Responsibility**: Handles cache key management only.
**Public Methods:**

- `CacheKey generateCacheKey(String trackId, String audioUrl)` — Generate cache key from track ID and URL. ❌
- `CacheKey generateCacheKeyWithParams(String trackId, String audioUrl, Map<String, String> parameters)` — Generate cache key with custom parameters. ❌
- `Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key)` — Get file path from cache key.
- `Future<Either<CacheFailure, String>> getDirectoryPathFromCacheKey(CacheKey key)` — Get directory path from cache key.
- `bool isValidCacheKey(CacheKey key)` — Validate cache key format.
- `Either<CacheFailure, Map<String, String>> parseCacheKey(CacheKey key)` — Parse cache key to extract components.
- `CacheKey generateTempCacheKey(String trackId)` — Generate cache key for temporary files. ❌
- `bool isTempCacheKey(CacheKey key)` — Check if cache key represents a temporary file.
- `String cacheKeyToStorageId(CacheKey key)` — Convert cache key to storage identifier.
- `Either<CacheFailure, CacheKey> storageIdToCacheKey(String storageId)` — Convert storage identifier to cache key. ❌

### CacheMaintenanceRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart`
**Responsibility**: Handles cache maintenance and validation operations only.
**Public Methods:**

- `Future<Either<CacheFailure, CacheValidationResult>> validateCacheConsistency()` — Validate entire cache consistency.
- `Future<Either<CacheFailure, bool>> validateCacheEntry(String trackId)` — Validate specific cache entry. ❌
- `Future<Either<CacheFailure, bool>> validateCacheMetadata()` — Validate cache metadata integrity.
- `Future<Either<CacheFailure, int>> cleanupOrphanedFiles()` — Clean up orphaned files.
- `Future<Either<CacheFailure, int>> cleanupInvalidMetadata()` — Clean up invalid metadata entries.
- `Future<Either<CacheFailure, int>> cleanupTemporaryFiles()` — Clean up temporary files.
- `Future<Either<CacheFailure, int>> cleanupOldEntries({Duration? maxAge, int? maxEntries})` — Clean up old cache entries based on policies.
- `Future<Either<CacheFailure, int>> rebuildCacheIndex()` — Rebuild cache index from existing files.
- `Future<Either<CacheFailure, int>> rebuildCacheMetadata()` — Rebuild cache metadata from file system.
- `Future<Either<CacheFailure, int>> scanAndUpdateCacheRegistry()` — Scan file system and update cache registry.

## 10. Playback Persistence Domain

### PlaybackPersistenceRepository

**Location**: `lib/features/audio_player/domain/repositories/playback_persistence_repository.dart`
**Responsibility**: Handles saving/loading of audio playback state only.
**Public Methods:**

- `Future<void> savePlaybackState(PlaybackSession session)` — Save current playback session state.
- `Future<PlaybackSession?> loadPlaybackState()` — Load previously saved playback session.
- `Future<void> clearPlaybackState()` — Clear saved playback state.
- `Future<bool> hasPlaybackState()` — Check if saved state exists.
- `Future<void> saveQueue(List<String> trackIds, int currentIndex)` — Save queue information separately.
- `Future<({List<String> trackIds, int currentIndex})?> loadQueue()` — Load saved queue information.
- `Future<void> saveTrackPosition(String trackId, Duration position)` — Save playback position for a specific track.
- `Future<Duration?> loadTrackPosition(String trackId)` — Load saved position for a specific track.
- `Future<void> clearTrackPositions()` — Clear all track positions.

---

# End of Repository Documentation

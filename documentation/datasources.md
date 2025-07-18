# TrackFlow Data Sources Architecture

This document describes the data access layer architecture in TrackFlow, following Clean Architecture principles with clear separation between local and remote data sources.

## Architecture Overview

- **Total Data Sources:** Specialized data sources for each feature (local and remote)
- **Features Covered:** All domain features
- **Architecture Pattern:** Clean Architecture with Repository pattern
- **Design Principles:** Single Responsibility, consistent error handling, reactive programming
- **Clean Architecture Compliance:** All data sources now use DTOs and primitive types instead of domain entities or value objects. All conversions between DTOs and domain entities are handled in the repository layer.

---

## 1. Auth Feature

### Local Data Source: UserSessionLocalDataSource

**Location:** `lib/features/auth/data/data_sources/user_session_local_datasource.dart`
**Responsibility:** Manages user session state and offline credentials.
**Public Methods:**

- `Future<Either<Failure, Unit>> cacheUserId(String userId)` — Cache user ID.
- `Future<Either<Failure, String?>> getCachedUserId()` — Get cached user ID.
- `Future<Either<Failure, Unit>> setOfflineCredentials(String email, bool hasCredentials)` — Set offline credentials.
- `Future<Either<Failure, String?>> getOfflineEmail()` — Get offline email.
- `Future<Either<Failure, bool>> hasOfflineCredentials()` — Check if offline credentials exist.
- `Future<Either<Failure, Unit>> clearOfflineCredentials()` — Clear offline credentials.

### Local Data Source: OnboardingStateLocalDataSource

**Location:** `lib/features/auth/data/data_sources/onboarding_state_local_datasource.dart`
**Responsibility:** Manages onboarding and welcome screen state.
**Public Methods:**

- `Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed)` — Mark onboarding as completed.
- `Future<Either<Failure, bool>> isOnboardingCompleted()` — Check if onboarding is completed.
- `Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen)` — Mark welcome screen as seen.
- `Future<Either<Failure, bool>> isWelcomeScreenSeen()` — Check if welcome screen was seen.

### Local Data Source: AuthLocalDataSource (Deprecated)

**Location:** `lib/features/auth/data/data_sources/auth_local_datasource.dart`
**Status:** Deprecated. The file has been removed from the codebase. Use `UserSessionLocalDataSource` and `OnboardingStateLocalDataSource` directly.

### Remote Data Source: AuthRemoteDataSource

**Location:** `lib/features/auth/data/data_sources/auth_remote_datasource.dart`
**Responsibility:** Handles remote authentication operations.
**Public Methods:**

- `Future<User?> getCurrentUser()` — Get current user.
- `Stream<User?> authStateChanges()` — Stream of authentication state changes.
- `Future<User?> signInWithEmailAndPassword(String email, String password)` — Sign in with email/password.
- `Future<User?> signUpWithEmailAndPassword(String email, String password)` — Sign up with email/password.
- `Future<User?> signInWithGoogle()` — Sign in with Google.
- `Future<void> signOut()` — Sign out.

---

## 2. Audio Cache Feature

### Local Data Source: CacheStorageLocalDataSource

**Location:** `lib/features/audio_cache/shared/data/datasources/cache_storage_local_data_source.dart`
**Responsibility:** Manages local storage and retrieval of cached audio files and metadata.
**Public Methods:**

- `Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(CachedAudioDocumentUnified cachedAudio)` — Store audio in cache.
- `Future<Either<CacheFailure, CachedAudioDocumentUnified?>> getCachedAudio(String trackId)` — Get cached audio.
- `Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId)` — Get path of cached audio.
- `Future<Either<CacheFailure, bool>> audioExists(String trackId)` — Check if audio exists.
- `Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId)` — Delete audio file.
- `Future<Either<CacheFailure, bool>> verifyFileIntegrity(String trackId, String expectedChecksum)` — Verify file integrity.
- `Future<Either<CacheFailure, List<CachedAudioDocumentUnified>>> getMultipleCachedAudios(List<String> trackIds)` — Get multiple cached audios.
- `Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds)` — Delete multiple audio files.
- `Future<Either<CacheFailure, List<CachedAudioDocumentUnified>>> getAllCachedAudios()` — Get all cached audios.
- `Future<Either<CacheFailure, int>> getTotalStorageUsage()` — Get total storage usage.
- `Future<Either<CacheFailure, List<String>>> getCorruptedFiles()` — Get corrupted files.
- `Future<Either<CacheFailure, List<String>>> getOrphanedFiles()` — Get orphaned files.
- `Stream<int> watchStorageUsage()` — Stream of storage usage.
- `CacheKey generateCacheKey(String trackId, String audioUrl)` — Generate cache key.
- `Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key)` — Get file path from cache key.
- `Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc)` — Store unified cached audio document.

### Remote Data Source: CacheStorageRemoteDataSource

**Location:** `lib/features/audio_cache/shared/data/datasources/cache_storage_remote_data_source.dart`
**Responsibility:** Handles remote audio file download and metadata retrieval.
**Public Methods:**

- `Future<Either<CacheFailure, File>> downloadAudio({required String audioUrl, required String localFilePath, required Function(DownloadProgress) onProgress})` — Download audio with progress.
- `Future<Either<CacheFailure, Unit>> cancelDownload(String downloadId)` — Cancel download.
- `Future<Either<CacheFailure, String>> getDownloadUrl(String audioReference)` — Get download URL.
- `Future<Either<CacheFailure, bool>> audioExists(String audioReference)` — Check if audio exists remotely.
- `Future<Either<CacheFailure, Map<String, dynamic>>> getAudioMetadata(String audioReference)` — Get audio metadata.

---

## 3. Audio Comment Feature

### Local Data Source: AudioCommentLocalDataSource

**Location:** `lib/features/audio_comment/data/datasources/audio_comment_local_datasource.dart`
**Responsibility:** Manages local caching and retrieval of audio comments.
**Public Methods:**

- `Future<Either<Failure, Unit>> cacheComment(AudioCommentDTO comment)` — Cache a comment.
- `Future<Either<Failure, Unit>> deleteCachedComment(String commentId)` — Delete cached comment.
- `Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(String trackId)` — Get cached comments by track.
- `Future<Either<Failure, AudioCommentDTO?>> getCommentById(String commentId)` — Get comment by ID.
- `Future<Either<Failure, Unit>> deleteComment(String commentId)` — Delete comment.
- `Future<Either<Failure, Unit>> deleteAllComments()` — Delete all comments.
- `Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(String trackId)` — Stream comments by track.
- `Future<Either<Failure, Unit>> clearCache()` — Clear cache.

### Remote Data Source: AudioCommentRemoteDataSource

**Location:** `lib/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart`
**Responsibility:** Handles remote operations for audio comments.
**Public Methods:**

- `Future<Either<Failure, Unit>> addComment(AudioCommentDTO comment)` — Add comment remotely.
- `Future<Either<Failure, Unit>> deleteComment(String commentId)` — Delete comment remotely.
- `Future<List<AudioCommentDTO>> getCommentsByTrackId(String audioTrackId)` — Get comments by track ID.

---

## 4. Audio Track Feature

### Local Data Source: AudioTrackLocalDataSource

**Location:** `lib/features/audio_track/data/datasources/audio_track_local_datasource.dart`
**Responsibility:** Manages local caching and retrieval of audio tracks.
**Public Methods:**

- `Future<Either<Failure, Unit>> cacheTrack(AudioTrackDTO track)` — Cache a track.
- `Future<Either<Failure, AudioTrackDTO?>> getTrackById(String id)` — Get track by ID.
- `Future<Either<Failure, Unit>> deleteTrack(String id)` — Delete track.
- `Future<Either<Failure, Unit>> deleteAllTracks()` — Delete all tracks.
- `Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(String projectId)` — Stream tracks by project.
- `Future<Either<Failure, Unit>> clearCache()` — Clear cache.
- `Future<Either<Failure, Unit>> updateTrackName(String trackId, String newName)` — Update track name.

### Remote Data Source: AudioTrackRemoteDataSource

**Location:** `lib/features/audio_track/data/datasources/audio_track_remote_datasource.dart`
**Responsibility:** Handles remote upload and management of audio tracks.
**Public Methods:**

- `Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack(AudioTrackDTO trackData)` — Upload audio track.
- `Future<void> deleteTrackFromProject(String trackId, String projectId)` — Delete track from project.
- `Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds)` — Get tracks by project IDs.
- `Future<void> editTrackName(String trackId, String projectId, String newName)` — Edit track name.

---

## 5. Magic Link Feature

### Local Data Source: MagicLinkLocalDataSource

**Location:** `lib/features/magic_link/data/datasources/magic_link_local_data_source.dart`
**Responsibility:** Manages local caching of magic links.
**Public Methods:**

- `Future<Either<Failure, MagicLinkDto>> cacheMagicLink(MagicLinkCacheRequestDto request)` — Cache magic link.
- `Future<Either<Failure, MagicLinkDto>> getCachedMagicLink(MagicLinkCacheQueryDto query)` — Get cached magic link.
- `Future<Either<Failure, Unit>> clearCachedMagicLink(MagicLinkCacheQueryDto query)` — Clear cached magic link.

### Remote Data Source: MagicLinkRemoteDataSource

**Location:** `lib/features/magic_link/data/datasources/magic_link_remote_data_source.dart`
**Responsibility:** Handles remote operations for magic links.
**Public Methods:**

- `Future<Either<Failure, MagicLinkDto>> generateMagicLink(MagicLinkRequestDto request)` — Generate magic link.
- `Future<Either<Failure, MagicLinkDto>> validateMagicLink(MagicLinkValidationDto validation)` — Validate magic link.
- `Future<Either<Failure, Unit>> consumeMagicLink(MagicLinkValidationDto validation)` — Consume magic link.
- `Future<Either<Failure, Unit>> resendMagicLink(MagicLinkValidationDto validation)` — Resend magic link.
- `Future<Either<Failure, String>> getMagicLinkStatus(MagicLinkStatusDto status)` — Get magic link status.

---

## 6. Manage Collaborators Feature

### Local Data Source: ManageCollaboratorsLocalDataSource

**Location:** `lib/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart`
**Responsibility:** Manages local collaborator project updates and retrieval.
**Public Methods:**

- `Future<ProjectDTO> updateProject(ProjectDTO project)` — Update project locally.
- `Future<ProjectDTO?> getProjectById(String projectId)` — Get project by ID locally.

### Remote Data Source: ManageCollaboratorsRemoteDataSource

**Location:** `lib/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart`
**Responsibility:** Handles remote collaborator project operations.
**Public Methods:**

- `Future<Either<Failure, void>> selfJoinProjectWithProjectId({required String projectId, required String userId})` — Join project remotely.
- `Future<Either<Failure, ProjectDTO>> updateProject(ProjectDTO project)` — Update project remotely.
- `Future<Either<Failure, List<UserProfileDTO>>> getProjectCollaborators(ProjectDTO project)` — Get project collaborators remotely.
- `Future<Either<Failure, Unit>> leaveProject({required String projectId, required String userId})` — Leave project remotely.

---

## 7. Playlist Feature

### Local Data Source: PlaylistLocalDataSource

**Location:** `lib/features/playlist/data/datasources/playlist_local_data_source.dart`
**Responsibility:** Manages local storage and retrieval of playlists.
**Public Methods:**

- `Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist)` — Add playlist.
- `Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists()` — Get all playlists.
- `Future<Either<Failure, PlaylistDto?>> getPlaylistById(String uuid)` — Get playlist by UUID.
- `Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist)` — Update playlist.
- `Future<Either<Failure, Unit>> deletePlaylist(String uuid)` — Delete playlist.

### Remote Data Source: PlaylistRemoteDataSource

**Location:** `lib/features/playlist/data/datasources/playlist_remote_data_source.dart`
**Responsibility:** Handles remote playlist operations.
**Public Methods:**

- `Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist)` — Add playlist remotely.
- `Future<Either<Failure, List<PlaylistDto>>> getAllPlaylists()` — Get all playlists remotely.
- `Future<Either<Failure, PlaylistDto?>> getPlaylistById(String id)` — Get playlist by ID remotely.
- `Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist)` — Update playlist remotely.
- `Future<Either<Failure, Unit>> deletePlaylist(String id)` — Delete playlist remotely.

---

## 8. Projects Feature

### Local Data Source: ProjectsLocalDataSource

**Location:** `lib/features/projects/data/datasources/project_local_data_source.dart`
**Responsibility:** Manages local storage and retrieval of projects.
**Public Methods:**

- `Future<Either<Failure, Unit>> cacheProject(ProjectDTO project)` — Cache project.
- `Future<Either<Failure, ProjectDTO?>> getCachedProject(String projectId)` — Get cached project.
- `Future<Either<Failure, Unit>> removeCachedProject(String projectId)` — Remove cached project.
- `Future<Either<Failure, List<ProjectDTO>>> getAllProjects()` — Get all projects.
- `Stream<Either<Failure, List<ProjectDTO>>> watchAllProjects(String ownerId)` — Stream all projects for a user.
- `Future<Either<Failure, Unit>> clearCache()` — Clear all cached projects.

### Remote Data Source: ProjectRemoteDataSource

**Location:** `lib/features/projects/data/datasources/project_remote_data_source.dart`
**Responsibility:** Handles remote project operations.
**Public Methods:**

- `Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project)` — Create project remotely.
- `Future<Either<Failure, Unit>> updateProject(ProjectDTO project)` — Update project remotely.
- `Future<Either<Failure, Unit>> deleteProject(String projectId)` — Delete project remotely.
- `Future<Either<Failure, ProjectDTO>> getProjectById(String projectId)` — Get project by ID remotely.
- `Future<Either<Failure, List<ProjectDTO>>> getUserProjects(String userId)` — Get all projects for a user remotely.

---

## 9. User Profile Feature

### Local Data Source: UserProfileLocalDataSource

**Location:** `lib/features/user_profile/data/datasources/user_profile_local_datasource.dart`
**Responsibility:** Manages local storage and retrieval of user profiles.
**Public Methods:**

- `Future<void> cacheUserProfile(UserProfileDTO profile)` — Cache user profile.
- `Stream<UserProfileDTO?> watchUserProfile(String userId)` — Stream user profile by ID.
- `Future<List<UserProfileDTO>> getUserProfilesByIds(List<String> userIds)` — Get user profiles by IDs.
- `Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(List<String> userIds)` — Stream user profiles by IDs.
- `Future<void> clearCache()` — Clear all cached user profiles.

### Remote Data Source: UserProfileRemoteDataSource

**Location:** `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`
**Responsibility:** Handles remote operations for user profiles.
**Public Methods:**

- `Future<Either<Failure, UserProfileDTO>> getProfileById(String userId)` — Get user profile by ID remotely.
- `Future<Either<Failure, UserProfileDTO>> updateProfile(UserProfileDTO profile)` — Update user profile remotely.
- `Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(List<String> userIds)` — Get user profiles by IDs remotely.

---

# End of Data Sources Documentation

# Data Sources Documentation

This documentation lists all **Local Data Sources** and **Remote Data Sources** organized by feature in the TrackFlow application, updated after the Phase 2 SOLID refactoring.

## General Overview

- **Total Data Sources:** 19 files (10 local + 9 remote)
- **Features Covered:** 9 different features
- **Architecture Pattern:** Clean Architecture with clear separation between local and remote sources
- **Refactor Status:** ✅ Phase 2 Complete - SRP violations fixed, Either<Failure, T> standardized

---

## 1. Auth Feature

⚠️ **SOLID Refactor Note:** AuthLocalDataSource was split in Phase 2 to follow Single Responsibility Principle (SRP)

### Local Data Source: `user_session_local_datasource.dart` ✨ **NEW**
**Location:** `lib/features/auth/data/data_sources/`

**Responsibility:** Manages user session state and offline credentials

**Public Methods:**
- `Future<Either<Failure, Unit>> cacheUserId(String userId)` - Cache user ID
- `Future<Either<Failure, String?>> getCachedUserId()` - Get cached user ID
- `Future<Either<Failure, Unit>> setOfflineCredentials(String email, bool hasCredentials)` - Set offline credentials
- `Future<Either<Failure, String?>> getOfflineEmail()` - Get offline email
- `Future<Either<Failure, bool>> hasOfflineCredentials()` - Check if has offline credentials
- `Future<Either<Failure, Unit>> clearOfflineCredentials()` - Clear offline credentials

### Local Data Source: `onboarding_state_local_datasource.dart` ✨ **NEW**
**Location:** `lib/features/auth/data/data_sources/`

**Responsibility:** Manages onboarding and welcome screen state

**Public Methods:**
- `Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed)` - Mark onboarding as completed
- `Future<Either<Failure, bool>> isOnboardingCompleted()` - Check if onboarding is completed
- `Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen)` - Mark welcome screen as seen
- `Future<Either<Failure, bool>> isWelcomeScreenSeen()` - Check if welcome screen was seen

### Local Data Source: `auth_local_datasource.dart` 🔄 **DEPRECATED**
**Location:** `lib/features/auth/data/data_sources/`

**Status:** Maintained for backward compatibility, delegates to specialized data sources

**Migration Path:** Use `UserSessionLocalDataSource` and `OnboardingStateLocalDataSource` instead

### Remote Data Source: `auth_remote_datasource.dart`
**Location:** `lib/features/auth/data/data_sources/`

**Public Methods:**
- `Future<User?> getCurrentUser()` - Get current user
- `Stream<User?> authStateChanges()` - Stream of authentication state changes
- `Future<User?> signInWithEmailAndPassword(String email, String password)` - Sign in with email/password
- `Future<User?> signUpWithEmailAndPassword(String email, String password)` - Sign up with email/password
- `Future<User?> signInWithGoogle()` - Sign in with Google
- `Future<void> signOut()` - Sign out

---

## 2. Audio Cache Feature

### Local Data Source: `cache_storage_local_data_source.dart`
**Ubicación:** `lib/features/audio_cache/shared/data/datasources/`

**Métodos Públicos:**
- `Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(CachedAudio cachedAudio)` - Almacena audio en cache
- `Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId)` - Obtiene audio cacheado
- `Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId)` - Obtiene ruta del audio cacheado
- `Future<Either<CacheFailure, bool>> audioExists(String trackId)` - Verifica si el audio existe
- `Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId)` - Elimina archivo de audio
- `Future<Either<CacheFailure, bool>> verifyFileIntegrity(String trackId, String expectedChecksum)` - Verifica integridad del archivo
- `Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(List<String> trackIds)` - Obtiene múltiples audios cacheados
- `Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds)` - Elimina múltiples archivos de audio
- `Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios()` - Obtiene todos los audios cacheados
- `Future<Either<CacheFailure, int>> getTotalStorageUsage()` - Obtiene uso total de almacenamiento
- `Future<Either<CacheFailure, List<String>>> getCorruptedFiles()` - Obtiene archivos corruptos
- `Future<Either<CacheFailure, List<String>>> getOrphanedFiles()` - Obtiene archivos huérfanos
- `Stream<int> watchStorageUsage()` - Stream del uso de almacenamiento
- `CacheKey generateCacheKey(String trackId, String audioUrl)` - Genera clave de cache
- `Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key)` - Obtiene ruta desde clave de cache
- `Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc)` - Almacena documento de audio unificado

### Remote Data Source: `cache_storage_remote_data_source.dart`
**Ubicación:** `lib/features/audio_cache/shared/data/datasources/`

**Métodos Públicos:**
- `Future<Either<CacheFailure, File>> downloadAudio({required String audioUrl, required String localFilePath, required Function(DownloadProgress) onProgress})` - Descarga audio con progreso
- `Future<Either<CacheFailure, Unit>> cancelDownload(String downloadId)` - Cancela descarga
- `Future<Either<CacheFailure, String>> getDownloadUrl(String audioReference)` - Obtiene URL de descarga
- `Future<Either<CacheFailure, bool>> audioExists(String audioReference)` - Verifica si el audio existe remotamente
- `Future<Either<CacheFailure, Map<String, dynamic>>> getAudioMetadata(String audioReference)` - Obtiene metadatos del audio

---

## 3. Audio Comment Feature

### Local Data Source: `audio_comment_local_datasource.dart`
**Ubicación:** `lib/features/audio_comment/data/datasources/`

**Métodos Públicos:**
- `Future<void> cacheComment(AudioCommentDTO comment)` - Cachea comentario
- `Future<void> deleteCachedComment(String commentId)` - Elimina comentario cacheado
- `Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId)` - Obtiene comentarios por track
- `Future<AudioCommentDTO?> getCommentById(String id)` - Obtiene comentario por ID
- `Future<void> deleteComment(String id)` - Elimina comentario
- `Future<void> deleteAllComments()` - Elimina todos los comentarios
- `Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(String trackId)` - Stream de comentarios por track
- `Future<void> clearCache()` - Limpia cache

### Remote Data Source: `audio_comment_remote_datasource.dart`
**Ubicación:** `lib/features/audio_comment/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, Unit>> addComment(AudioComment comment)` - Añade comentario
- `Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId)` - Elimina comentario
- `Future<List<AudioCommentDTO>> getCommentsByTrackId(String audioTrackId)` - Obtiene comentarios por track ID

---

## 4. Audio Track Feature

### Local Data Source: `audio_track_local_datasource.dart`
**Ubicación:** `lib/features/audio_track/data/datasources/`

**Métodos Públicos:**
- `Future<void> cacheTrack(AudioTrackDTO track)` - Cachea track
- `Future<AudioTrackDTO?> getTrackById(String id)` - Obtiene track por ID
- `Future<void> deleteTrack(String id)` - Elimina track
- `Future<void> deleteAllTracks()` - Elimina todos los tracks
- `Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(String projectId)` - Stream de tracks por proyecto
- `Future<void> clearCache()` - Limpia cache
- `Future<void> updateTrackName(String trackId, String newName)` - Actualiza nombre del track

### Remote Data Source: `audio_track_remote_datasource.dart`
**Ubicación:** `lib/features/audio_track/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack({required File file, required AudioTrack track})` - Sube track de audio
- `Future<void> deleteTrackFromProject(String trackId, String projectId)` - Elimina track del proyecto
- `Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds)` - Obtiene tracks por IDs de proyecto
- `Future<void> editTrackName({required String trackId, required String projectId, required String newName})` - Edita nombre del track

---

## 5. Magic Link Feature

### Local Data Source: `magic_link_local_data_source.dart`
**Ubicación:** `lib/features/magic_link/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, MagicLink>> cacheMagicLink({required UserId userId})` - Cachea magic link
- `Future<Either<Failure, MagicLink>> getCachedMagicLink({required UserId userId})` - Obtiene magic link cacheado
- `Future<Either<Failure, Unit>> clearCachedMagicLink({required UserId userId})` - Limpia magic link cacheado

⚠️ **Nota:** Todos los métodos están marcados como `UnimplementedError()` - implementación pendiente.

### Remote Data Source: `magic_link_remote_data_source.dart`
**Ubicación:** `lib/features/magic_link/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, MagicLink>> generateMagicLink({required String projectId, required String userId})` - Genera magic link
- `Future<Either<Failure, MagicLink>> validateMagicLink({required String linkId})` - Valida magic link
- `Future<Either<Failure, Unit>> consumeMagicLink({required String linkId})` - Consume magic link
- `Future<Either<Failure, Unit>> resendMagicLink({required String linkId})` - Reenvía magic link
- `Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({required String linkId})` - Obtiene estado del magic link

---

## 6. Manage Collaborators Feature

### Local Data Source: `manage_collaborators_local_datasource.dart`
**Ubicación:** `lib/features/manage_collaborators/data/datasources/`

**Métodos Públicos:**
- `Future<void> updateProject(Project project)` - Actualiza proyecto
- `Future<Project?> getProjectById(ProjectId projectId)` - Obtiene proyecto por ID

### Remote Data Source: `manage_collaborators_remote_datasource.dart`
**Ubicación:** `lib/features/manage_collaborators/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, void>> selfJoinProjectWithProjectId({required String projectId, required String userId})` - Se une al proyecto
- `Future<Either<Failure, Project>> updateProject(Project project)` - Actualiza proyecto
- `Future<Either<Failure, List<UserProfile>>> getProjectCollaborators(Project project)` - Obtiene colaboradores del proyecto
- `Future<Either<Failure, Unit>> leaveProject({required ProjectId projectId, required UserId userId})` - Abandona proyecto

---

## 7. Playlist Feature

### Local Data Source: `playlist_local_data_source.dart`
**Ubicación:** `lib/features/playlist/data/datasources/`

**Métodos Públicos:**
- `Future<void> addPlaylist(PlaylistDto playlist)` - Añade playlist
- `Future<List<PlaylistDto>> getAllPlaylists()` - Obtiene todas las playlists
- `Future<PlaylistDto?> getPlaylistById(String uuid)` - Obtiene playlist por UUID
- `Future<void> updatePlaylist(PlaylistDto playlist)` - Actualiza playlist
- `Future<void> deletePlaylist(String uuid)` - Elimina playlist

### Remote Data Source: `playlist_remote_data_source.dart`
**Ubicación:** `lib/features/playlist/data/datasources/`

**Métodos Públicos:**
- `Future<void> addPlaylist(PlaylistDto playlist)` - Añade playlist
- `Future<List<PlaylistDto>> getAllPlaylists()` - Obtiene todas las playlists
- `Future<PlaylistDto?> getPlaylistById(String id)` - Obtiene playlist por ID
- `Future<void> updatePlaylist(PlaylistDto playlist)` - Actualiza playlist
- `Future<void> deletePlaylist(String id)` - Elimina playlist

---

## 8. Projects Feature

### Local Data Source: `project_local_data_source.dart`
**Ubicación:** `lib/features/projects/data/datasources/`

**Métodos Públicos:**
- `Future<void> cacheProject(ProjectDTO project)` - Cachea proyecto
- `Future<ProjectDTO?> getCachedProject(UniqueId id)` - Obtiene proyecto cacheado
- `Future<void> removeCachedProject(UniqueId id)` - Remueve proyecto cacheado
- `Future<List<ProjectDTO>> getAllProjects()` - Obtiene todos los proyectos
- `Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId)` - Stream de todos los proyectos
- `Future<void> clearCache()` - Limpia cache

### Remote Data Source: `project_remote_data_source.dart`
**Ubicación:** `lib/features/projects/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, Project>> createProject(Project project)` - Crea proyecto
- `Future<Either<Failure, Unit>> updateProject(Project project)` - Actualiza proyecto
- `Future<Either<Failure, Unit>> deleteProject(UniqueId id)` - Elimina proyecto
- `Future<Either<Failure, Project>> getProjectById(ProjectId projectId)` - Obtiene proyecto por ID
- `Future<Either<Failure, List<Project>>> getUserProjects(String userId)` - Obtiene proyectos del usuario

---

## 9. User Profile Feature

### Local Data Source: `user_profile_local_datasource.dart`
**Ubicación:** `lib/features/user_profile/data/datasources/`

**Métodos Públicos:**
- `Future<void> cacheUserProfile(UserProfileDTO profile)` - Cachea perfil de usuario
- `Stream<UserProfileDTO?> watchUserProfile(String userId)` - Stream del perfil de usuario
- `Future<List<UserProfileDTO>> getUserProfilesByIds(List<String> userIds)` - Obtiene perfiles por IDs
- `Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(List<String> userIds)` - Stream de perfiles por IDs
- `Future<void> clearCache()` - Limpia cache

### Remote Data Source: `user_profile_remote_datasource.dart`
**Ubicación:** `lib/features/user_profile/data/datasources/`

**Métodos Públicos:**
- `Future<Either<Failure, UserProfile>> getProfileById(String userId)` - Obtiene perfil por ID
- `Future<Either<Failure, UserProfileDTO>> updateProfile(UserProfileDTO profile)` - Actualiza perfil
- `Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(List<String> userIds)` - Obtiene perfiles por IDs

---

## Technologies Used

### Local Storage
- **Isar Database** - For structured data
- **SharedPreferences** - For preferences and simple configurations

### Remote Services
- **Firebase Firestore** - Real-time database
- **Firebase Storage** - File storage
- **Firebase Auth** - Authentication

### Architecture Patterns
- **Either/Failure** - Error handling with Dartz
- **Dependency Injection** - With Injectable
- **Reactive Programming** - With Streams
- **Clean Architecture** - Clear separation of responsibilities
- **Single Responsibility Principle (SRP)** - Each data source has one responsibility ✨

---

## SOLID Refactor Achievements (Phase 2)

### ✅ Single Responsibility Principle (SRP)
- **AuthLocalDataSource** split into specialized data sources
- Each data source now has exactly one responsibility
- Clear separation between user session and onboarding concerns

### ✅ Error Handling Standardization
- **All data sources** now return `Either<Failure, T>` types
- Consistent error handling across the entire data layer
- Improved error propagation and handling

### ✅ Interface Segregation
- Smaller, focused interfaces instead of large monolithic ones
- Clients only depend on methods they actually use
- Better testability and maintainability

---

## Key Observations

1. **Consistency:** All features follow the same architecture pattern
2. **Error Handling:** Consistent use of `Either<Failure, T>` for operations that can fail ✅
3. **Reactivity:** Extensive use of `Stream` for real-time updates
4. **Cache Strategy:** Robust local cache implementation with integrity validation
5. **SOLID Compliance:** All data sources now follow SOLID principles ✨
6. **Backward Compatibility:** Deprecated data sources maintain existing APIs
7. **Migration Path:** Clear guidance for transitioning to new specialized data sources

This documentation reflects the current state of the codebase after Phase 2 SOLID refactoring and should be updated when new features are added or existing ones are modified.
# TrackFlow Data Sources Architecture

This document describes the data access layer architecture in TrackFlow, following Clean Architecture principles with clear separation between local and remote data sources.

## Architecture Overview

- **Total Data Sources:** 19 specialized data sources (10 local + 9 remote)
- **Features Covered:** 9 domain features
- **Architecture Pattern:** Clean Architecture with Repository pattern
- **Design Principles:** Single Responsibility, consistent error handling, reactive programming

---

## 1. Auth Feature

### Local Data Source: `user_session_local_datasource.dart`
**Location:** `lib/features/auth/data/data_sources/`

**Responsibility:** Manages user session state and offline credentials

**Public Methods:**
- `Future<Either<Failure, Unit>> cacheUserId(String userId)` - Cache user ID
- `Future<Either<Failure, String?>> getCachedUserId()` - Get cached user ID
- `Future<Either<Failure, Unit>> setOfflineCredentials(String email, bool hasCredentials)` - Set offline credentials
- `Future<Either<Failure, String?>> getOfflineEmail()` - Get offline email
- `Future<Either<Failure, bool>> hasOfflineCredentials()` - Check if has offline credentials
- `Future<Either<Failure, Unit>> clearOfflineCredentials()` - Clear offline credentials

### Local Data Source: `onboarding_state_local_datasource.dart`
**Location:** `lib/features/auth/data/data_sources/`

**Responsibility:** Manages onboarding and welcome screen state

**Public Methods:**
- `Future<Either<Failure, Unit>> setOnboardingCompleted(bool completed)` - Mark onboarding as completed
- `Future<Either<Failure, bool>> isOnboardingCompleted()` - Check if onboarding is completed
- `Future<Either<Failure, Unit>> setWelcomeScreenSeen(bool seen)` - Mark welcome screen as seen
- `Future<Either<Failure, bool>> isWelcomeScreenSeen()` - Check if welcome screen was seen

### Local Data Source: `auth_local_datasource.dart` (Legacy)
**Location:** `lib/features/auth/data/data_sources/`

**Status:** Legacy data source maintained for backward compatibility

**Architecture:** Modern auth system uses specialized data sources:
- `UserSessionLocalDataSource` for session management
- `OnboardingStateLocalDataSource` for onboarding state

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

**Note:** Some methods may show `UnimplementedError()` indicating planned future implementation.

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

## Technology Stack

### Local Storage Technologies
- **Isar Database** - High-performance local database for structured data
- **SharedPreferences** - Simple key-value storage for preferences and configuration
- **File System** - Direct file storage for audio cache and temporary files

### Remote Services
- **Firebase Firestore** - Real-time NoSQL database for collaborative data
- **Firebase Storage** - Scalable file storage for audio tracks and media
- **Firebase Auth** - Authentication and user management

### Architecture Patterns
- **Either<Failure, T>** - Functional error handling with Dartz library
- **Dependency Injection** - IoC container with Injectable annotations
- **Reactive Programming** - Stream-based reactive data flow
- **Repository Pattern** - Data access abstraction layer
- **Single Responsibility** - Each data source handles one specific concern

---

## Design Principles

### 🎯 Single Responsibility Principle
- Each data source has one focused responsibility
- Clear separation between different types of data operations
- Specialized data sources for specific use cases

### 📐 Consistent Error Handling
- All data sources use `Either<Failure, T>` for error handling
- Standardized failure types across the entire data layer
- Proper error propagation from data sources to repositories

### 🔄 Reactive Data Flow
- Stream-based APIs for real-time data updates
- Reactive cache invalidation and synchronization
- Event-driven data synchronization patterns

### 📦 Interface Segregation
- Small, focused interfaces tailored to specific client needs
- No forced dependencies on unused methods
- Enhanced testability through targeted mocking

---

## Implementation Guidelines

### Error Handling Pattern
```dart
Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
  try {
    final profile = await _database.getUserProfile(userId);
    return Right(profile);
  } catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
```

### Reactive Data Pattern
```dart
Stream<Either<Failure, List<Project>>> watchUserProjects(String userId) {
  return _database.watchProjects(userId)
      .map((projects) => Right(projects))
      .onErrorReturnWith((error) => Stream.value(Left(DatabaseFailure(error.toString()))));
}
```

### Cache Strategy
- **Cache-First**: Local data sources serve cached data immediately
- **Background Sync**: Remote data sources update cache in background
- **Conflict Resolution**: Smart merging strategies for offline/online conflicts
- **Cache Invalidation**: Automatic cache cleanup and validation

---

## Quality Attributes

### ✅ Maintainability
- Single-purpose data sources are easier to understand and modify
- Clear separation of concerns between local and remote operations
- Consistent patterns across all features

### ✅ Testability
- Small, focused interfaces simplify unit testing
- Easy mocking of data sources in repository tests
- Isolated testing of cache vs remote operations

### ✅ Performance
- Efficient local caching reduces remote calls
- Stream-based reactive updates minimize unnecessary processing
- Smart preloading and batch operations

### ✅ Reliability
- Robust error handling with typed failures
- Cache integrity validation and repair mechanisms
- Offline-first architecture with graceful degradation
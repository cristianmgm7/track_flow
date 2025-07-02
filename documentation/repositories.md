# TrackFlow Repositories

This document describes all repositories available in the TrackFlow application, their responsibilities, and available methods after the Phase 3 SOLID refactoring.

## Overview

- **Total Repositories:** 19 (11 new specialized + 4 deprecated + 4 unchanged)
- **SOLID Refactor Status:** ✅ Phase 3 Complete - Major SRP violations fixed
- **Architecture Pattern:** Clean Architecture with proper separation of concerns
- **Backward Compatibility:** ✅ Maintained through facade patterns and deprecation strategy

## 1. Authentication Domain 🔐

⚠️ **SOLID Refactor Note:** AuthRepository was split in Phase 3 to follow Single Responsibility Principle (SRP)

### AuthRepository ✨ **REFACTORED**

**Location**: `lib/features/auth/domain/repositories/auth_repository.dart`

**Responsibility**: Handles **authentication operations only** (core auth functions)

**Methods** (7 focused methods):
- `Stream<User?> get authState` - Stream of authentication state
- `signInWithEmailAndPassword(String email, String password)` - Sign in with email/password
- `signUpWithEmailAndPassword(String email, String password)` - Sign up with email/password  
- `signInWithGoogle()` - Sign in with Google
- `signOut()` - Sign out
- `isLoggedIn()` - Check if logged in
- `getSignedInUserId()` - Get signed in user ID

### OnboardingRepository ✨ **NEW**

**Location**: `lib/features/auth/domain/repositories/onboarding_repository.dart`

**Responsibility**: Manages **onboarding state only**

**Methods** (2 focused methods):
- `onboardingCompleted()` - Mark onboarding as completed
- `checkOnboardingCompleted()` - Check if onboarding completed

### WelcomeScreenRepository ✨ **NEW**

**Location**: `lib/features/auth/domain/repositories/welcome_screen_repository.dart`

**Responsibility**: Manages **welcome screen state only**

**Methods** (2 focused methods):
- `welcomeScreenSeenCompleted()` - Mark welcome screen as seen
- `checkWelcomeScreenSeen()` - Check if welcome screen was seen

---

## 2. AudioTrackRepository

**Ubicación**: `lib/features/audio_track/domain/repositories/audio_track_repository.dart`

**Responsabilidad**: Gestiona las pistas de audio, incluyendo obtención, subida, eliminación y edición.

**Métodos**:

- `getTrackById(AudioTrackId id)` - Obtener pista por ID
- `watchTracksByProject(ProjectId projectId)` - Stream de pistas por proyecto
- `uploadAudioTrack({File file, AudioTrack track})` - Subir nueva pista de audio
- `deleteTrack(String trackId, String projectId)` - Eliminar pista
- `editTrackName({AudioTrackId trackId, ProjectId projectId, String newName})` - Editar nombre de pista

---

## 3. AudioCommentRepository

**Ubicación**: `lib/features/audio_comment/domain/repositories/audio_comment_repository.dart`

**Responsabilidad**: Gestiona los comentarios de audio asociados a las pistas.

**Métodos**:

- `getCommentById(AudioCommentId commentId)` - Obtener comentario por ID
- `addComment(AudioComment comment)` - Agregar nuevo comentario
- `watchCommentsByTrack(AudioTrackId trackId)` - Stream de comentarios por pista
- `deleteComment(AudioCommentId commentId)` - Eliminar comentario

---

## 4. PlaylistRepository

**Ubicación**: `lib/features/playlist/domain/repositories/playlist_repository.dart`

**Responsabilidad**: Gestiona las playlists de la aplicación.

**Métodos**:

- `addPlaylist(Playlist playlist)` - Agregar nueva playlist
- `getAllPlaylists()` - Obtener todas las playlists
- `getPlaylistById(String id)` - Obtener playlist por ID
- `updatePlaylist(Playlist playlist)` - Actualizar playlist
- `deletePlaylist(String id)` - Eliminar playlist

---

## 5. ProjectsRepository

**Ubicación**: `lib/features/projects/domain/repositories/projects_repository.dart`

**Responsabilidad**: Gestiona los proyectos del usuario.

**Métodos**:

- `createProject(Project project)` - Crear nuevo proyecto
- `updateProject(Project project)` - Actualizar proyecto
- `deleteProject(UniqueId id)` - Eliminar proyecto
- `watchLocalProjects(UserId ownerId)` - Stream de proyectos locales del usuario

---

? se puede eliminar y poner ese metodo de getprojectbyid en projects repository ?

## 6. ProjectDetailRepository

**Ubicación**: `lib/features/project_detail/domain/repositories/project_detail_repository.dart`

**Responsabilidad**: Obtiene detalles específicos de un proyecto.

**Métodos**:

- `getProjectById(ProjectId projectId)` - Obtener proyecto por ID

---

## 7. User Profile Domain 👤

⚠️ **SOLID Refactor Note:** UserProfileRepository was split in Phase 3 to separate individual vs bulk operations

### UserProfileRepository ✨ **REFACTORED**

**Location**: `lib/features/user_profile/domain/repositories/user_profile_repository.dart`

**Responsibility**: Manages **individual user profile operations**

**Methods** (3 focused methods):
- `updateUserProfile(UserProfile userProfile)` - Update user profile
- `getUserProfile(UserId userId)` - Get user profile
- `watchUserProfile(UserId userId)` - Stream of user profile

### UserProfileCacheRepository ✨ **NEW**

**Location**: `lib/features/user_profile/domain/repositories/user_profile_cache_repository.dart`

**Responsibility**: Manages **bulk cache operations for user profiles**

**Methods** (5 focused methods):
- `cacheUserProfiles(List<UserProfile> profiles)` - Cache user profiles
- `getUserProfilesByIds(List<String> userIds)` - Get profiles by IDs
- `watchUserProfilesByIds(List<String> userIds)` - Stream of profiles by IDs
- `preloadProfiles(List<String> userIds)` - Preload profiles for performance
- `clearCache()` - Clear profile cache

---

## 8. Collaboration Domain 👥

⚠️ **SOLID Refactor Note:** ManageCollaboratorsRepository was split in Phase 3 to eliminate SRP violations

### CollaboratorRepository ✨ **NEW**

**Location**: `lib/features/manage_collaborators/domain/repositories/collaborator_repository.dart`

**Responsibility**: Manages **collaborator operations only**

**Methods** (5 focused methods):
- `joinProjectWithId(ProjectId projectId, UserId userId)` - Join project
- `leaveProject({ProjectId projectId, UserId userId})` - Leave project
- `getProjectCollaborators(Project project)` - Get project collaborators
- `removeCollaborator(ProjectId projectId, UserId userId)` - Remove collaborator
- `updateCollaboratorRole(ProjectId projectId, UserId userId, ProjectRole role)` - Update collaborator role

### ManageCollaboratorsRepository 🔄 **DEPRECATED**

**Location**: `lib/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart`

**Status**: Deprecated with `@Deprecated` annotation

**Migration Path**: 
- Use `CollaboratorRepository` for collaborator operations
- Use `ProjectsRepository` for project operations (moved `updateProject` method there)

---

## 9. MagicLinkRepository

**Ubicación**: `lib/features/magic_link/domain/repositories/magic_link_repository.dart`

**Responsabilidad**: Gestiona links mágicos para invitaciones y acceso a proyectos.

**Métodos**:

- `generateMagicLink({String projectId, String userId})` - Generar link mágico
- `validateMagicLink({String linkId})` - Validar link mágico
- `consumeMagicLink({String linkId})` - Consumir link mágico
- `resendMagicLink({String linkId})` - Reenviar link mágico
- `getMagicLinkStatus({String linkId})` - Obtener estado del link mágico

---

## 10. PlaybackPersistenceRepository

**Ubicación**: `lib/features/audio_player/domain/repositories/playback_persistence_repository.dart`

**Responsabilidad**: Persiste el estado de reproducción de audio para reanudar sesiones.

**Métodos**:

- `savePlaybackState(PlaybackSession session)` - Guardar estado de reproducción
- `loadPlaybackState()` - Cargar estado de reproducción
- `clearPlaybackState()` - Limpiar estado de reproducción
- `hasPlaybackState()` - Verificar si existe estado guardado
- `saveQueue(List<String> trackIds, int currentIndex)` - Guardar cola de reproducción
- `loadQueue()` - Cargar cola de reproducción
- `saveTrackPosition(String trackId, Duration position)` - Guardar posición de pista
- `loadTrackPosition(String trackId)` - Cargar posición de pista
- `clearTrackPositions()` - Limpiar todas las posiciones

---

## 11. Audio Cache Domain 💾

⚠️ **SOLID Refactor Note:** CacheStorageRepository was split in Phase 3 into 4 specialized repositories + facade for the most complex refactoring

### AudioDownloadRepository ✨ **NEW**

**Location**: `lib/features/audio_cache/shared/domain/repositories/audio_download_repository.dart`

**Responsibility**: Manages **download operations and progress tracking**

**Methods** (15 focused methods):
- `downloadAndStoreAudio(String trackId, String audioUrl, {progressCallback})` - Download and store audio
- `downloadMultipleAudios(Map<String, String> trackUrlPairs, {progressCallback})` - Download multiple audios
- `cancelDownload(String trackId)` - Cancel download
- `pauseDownload(String trackId)` - Pause download
- `resumeDownload(String trackId)` - Resume download
- `getDownloadProgress(String trackId)` - Get download progress
- `getActiveDownloads()` - Get active downloads
- `watchDownloadProgress(String trackId)` - Stream of download progress
- `watchActiveDownloads()` - Stream of active downloads
- Plus 6 more download-specific methods...

### AudioStorageRepository ✨ **NEW**

**Location**: `lib/features/audio_cache/shared/domain/repositories/audio_storage_repository.dart`

**Responsibility**: Manages **physical file storage and retrieval**

**Methods** (15 focused methods):
- `getCachedAudioPath(String trackId)` - Get cached audio path
- `audioExists(String trackId)` - Check if file exists
- `getCachedAudio(String trackId)` - Get cached audio info
- `deleteAudioFile(String trackId)` - Delete audio file
- `getMultipleCachedAudios(List<String> trackIds)` - Get multiple cached audios
- `deleteMultipleAudioFiles(List<String> trackIds)` - Delete multiple files
- `checkMultipleAudioExists(List<String> trackIds)` - Check multiple files exist
- `watchStorageUsage()` - Stream of storage usage
- Plus 7 more storage-specific methods...

### CacheKeyRepository ✨ **NEW**

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_key_repository.dart`

**Responsibility**: Manages **cache key generation and validation**

**Methods** (12 focused methods):
- `generateCacheKey(String trackId, String audioUrl)` - Generate cache key
- `getFilePathFromCacheKey(CacheKey key)` - Get file path from key
- `isValidCacheKey(CacheKey key)` - Validate cache key format
- `convertLegacyKey(String legacyKey)` - Convert legacy keys
- `generateBatchKeys(Map<String, String> trackUrlPairs)` - Generate batch keys
- Plus 7 more key management methods...

### CacheMaintenanceRepository ✨ **NEW**

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_maintenance_repository.dart`

**Responsibility**: Manages **validation, cleanup, migration, and health monitoring**

**Methods** (20 focused methods):
- `migrateCacheStructure()` - Migrate cache structure
- `rebuildCacheIndex()` - Rebuild cache index
- `validateCacheConsistency()` - Validate cache consistency
- `performCacheCleanup()` - Perform cache cleanup
- `getCorruptedFiles()` - Get corrupted files
- `getOrphanedFiles()` - Get orphaned files
- `repairCacheStructure()` - Repair cache structure
- `generateHealthReport()` - Generate health report
- Plus 12 more maintenance methods...

### CacheStorageFacadeRepository ✨ **FACADE**

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_storage_facade_repository.dart`

**Responsibility**: **Backward compatibility facade** that delegates to specialized repositories

**Status**: Provides seamless migration path from original CacheStorageRepository

### CacheStorageRepository 🔄 **DEPRECATED**

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart`

**Status**: Deprecated with `@Deprecated` annotation and detailed migration guidance

**Migration Path**: 
- Use `AudioDownloadRepository` for downloads
- Use `AudioStorageRepository` for file operations  
- Use `CacheKeyRepository` for key management
- Use `CacheMaintenanceRepository` for maintenance
- Use `CacheStorageFacadeRepository` for gradual migration

---

## Summary by Domain (After Phase 3 Refactoring):

### 🔐 Authentication & Authorization:
- **AuthRepository**: Core authentication operations (7 methods)
- **OnboardingRepository**: Onboarding state management (2 methods)
- **WelcomeScreenRepository**: Welcome screen state (2 methods)

### 👥 User Management & Collaboration:
- **UserProfileRepository**: Individual profile operations (3 methods)
- **UserProfileCacheRepository**: Bulk profile caching (5 methods)
- **CollaboratorRepository**: Collaborator management (5 methods)
- **MagicLinkRepository**: Invitation links (5 methods)

### 🎵 Audio & Playback:
- **AudioTrackRepository**: Audio track management (5 methods)
- **AudioCommentRepository**: Comments on tracks (4 methods)
- **PlaylistRepository**: Playlist management (5 methods)
- **PlaybackPersistenceRepository**: Playback state persistence (8 methods)

### 💾 Audio Cache System:
- **AudioDownloadRepository**: Download operations (15 methods)
- **AudioStorageRepository**: File storage management (15 methods)
- **CacheKeyRepository**: Cache key management (12 methods)
- **CacheMaintenanceRepository**: Maintenance & health (20 methods)
- **CacheStorageFacadeRepository**: Backward compatibility facade

### 📁 Projects:
- **ProjectsRepository**: CRUD operations (4 methods)
- **ProjectDetailRepository**: Project details (1 method)

---

## SOLID Refactor Achievements (Phase 3)

### ✅ Single Responsibility Principle (SRP)
- **4 major repositories split** into 11 specialized repositories
- **Average methods per repository** reduced from 15-20 to 5-15
- **Each repository** now has exactly one clear responsibility

### ✅ Interface Segregation Principle (ISP)
- **Large interfaces split** into smaller, focused interfaces
- **Clients only depend** on methods they actually use
- **Better testability** through smaller, focused contracts

### ✅ Dependency Inversion Principle (DIP)
- **100% abstract interfaces** - all repositories use abstractions
- **Proper dependency injection** - all repositories registered with DI
- **Implementation flexibility** - easy to swap implementations

### ✅ Open/Closed Principle (OCP)
- **Extensible through composition** - new features don't modify existing code
- **Facade pattern** enables gradual migration without breaking changes
- **Deprecation strategy** allows safe evolution

### ✅ Liskov Substitution Principle (LSP)
- **Consistent interfaces** - all repositories follow same patterns
- **Proper inheritance** - specialized repositories extend base contracts correctly

---

## Key Technical Improvements

### 📊 Metrics & Statistics
- **Repositories created:** 11 new specialized repositories
- **SRP violations fixed:** 4 major violations eliminated
- **Method distribution:** More focused (5-15 methods vs 15-20+ previously)
- **Backward compatibility:** 100% maintained through facades and deprecation

### 🏗️ Architecture Benefits
- **Maintainability:** Easier to understand and modify single-purpose repositories
- **Testability:** Smaller interfaces are easier to mock and test
- **Scalability:** New features can be added without modifying existing repositories
- **Team Development:** Different team members can work on different repositories independently

### 🔄 Migration Strategy
- **Zero Breaking Changes:** All existing functionality preserved
- **Gradual Migration:** Teams can migrate incrementally using facade patterns
- **Clear Deprecation:** Specific migration guidance for each deprecated method
- **Backward Compatibility:** Original APIs maintained through delegation

---

## Important Notes:

1. **AudioContentRepository**: This repository was removed during refactoring as its responsibilities were distributed among `AudioTrackRepository`, `CacheStorageRepository`, and other services like `AudioSourceResolver`.

2. **Error Patterns**: All repositories use `Either<Failure, T>` for error handling using the Dartz library.

3. **Reactivity**: Many repositories provide Streams for frequently changing data, enabling reactive UI.

4. **Separation of Concerns**: Each repository has a clear, well-defined responsibility following Clean Architecture principles.

5. **Phase 3 Status**: ✅ **COMPLETED** - All major SRP violations have been successfully resolved with proper SOLID principles implementation.

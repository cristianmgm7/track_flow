# TrackFlow Repository Architecture

This document describes the repository architecture used in TrackFlow, following Clean Architecture principles and SOLID design patterns.

## Overview

- **Total Repositories:** 19 specialized repositories organized by domain
- **Architecture Pattern:** Clean Architecture with Domain-Driven Design
- **Design Principles:** SOLID principles with single responsibility and clear interfaces
- **Error Handling:** Consistent `Either<Failure, T>` pattern using Dartz library

## 1. Authentication Domain 🔐

### AuthRepository

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

### OnboardingRepository

**Location**: `lib/features/auth/domain/repositories/onboarding_repository.dart`

**Responsibility**: Manages **onboarding state only**

**Methods** (2 focused methods):
- `onboardingCompleted()` - Mark onboarding as completed
- `checkOnboardingCompleted()` - Check if onboarding completed

### WelcomeScreenRepository

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

### UserProfileRepository

**Location**: `lib/features/user_profile/domain/repositories/user_profile_repository.dart`

**Responsibility**: Manages **individual user profile operations**

**Methods** (3 focused methods):
- `updateUserProfile(UserProfile userProfile)` - Update user profile
- `getUserProfile(UserId userId)` - Get user profile
- `watchUserProfile(UserId userId)` - Stream of user profile

### UserProfileCacheRepository

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

### CollaboratorRepository

**Location**: `lib/features/manage_collaborators/domain/repositories/collaborator_repository.dart`

**Responsibility**: Manages **collaborator operations only**

**Methods** (5 focused methods):
- `joinProjectWithId(ProjectId projectId, UserId userId)` - Join project
- `leaveProject({ProjectId projectId, UserId userId})` - Leave project
- `getProjectCollaborators(Project project)` - Get project collaborators
- `removeCollaborator(ProjectId projectId, UserId userId)` - Remove collaborator
- `updateCollaboratorRole(ProjectId projectId, UserId userId, ProjectRole role)` - Update collaborator role

### ManageCollaboratorsRepository (Legacy)

**Location**: `lib/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart`

**Status**: Legacy repository maintained for backward compatibility

**Recommended Usage**: 
- Use `CollaboratorRepository` for new collaborator operations
- Use `ProjectsRepository` for project-specific operations

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

### AudioDownloadRepository

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

### AudioStorageRepository

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

### CacheKeyRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_key_repository.dart`

**Responsibility**: Manages **cache key generation and validation**

**Methods** (12 focused methods):
- `generateCacheKey(String trackId, String audioUrl)` - Generate cache key
- `getFilePathFromCacheKey(CacheKey key)` - Get file path from key
- `isValidCacheKey(CacheKey key)` - Validate cache key format
- `convertLegacyKey(String legacyKey)` - Convert legacy keys
- `generateBatchKeys(Map<String, String> trackUrlPairs)` - Generate batch keys
- Plus 7 more key management methods...

### CacheMaintenanceRepository

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

### CacheStorageFacadeRepository

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_storage_facade_repository.dart`

**Responsibility**: **Backward compatibility facade** that delegates to specialized repositories

**Status**: Provides seamless migration path from original CacheStorageRepository

### CacheStorageRepository (Legacy)

**Location**: `lib/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart`

**Status**: Legacy repository maintained for backward compatibility

**Architecture**: Modern cache system uses specialized repositories:
- `AudioDownloadRepository` for download operations
- `AudioStorageRepository` for file management  
- `CacheKeyRepository` for key operations
- `CacheMaintenanceRepository` for maintenance tasks
- `CacheStorageFacadeRepository` provides unified interface

---

## Repository Organization by Domain:

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

## Architecture Principles

### 🎯 Single Responsibility Principle (SRP)
- Each repository has one clear, focused responsibility
- Specialized repositories handle specific domain concerns
- Average 5-15 methods per repository for focused interfaces

### 🔌 Interface Segregation Principle (ISP)
- Small, focused interfaces that clients actually need
- No forced dependencies on unused methods
- Enhanced testability through targeted mocking

### 🔀 Dependency Inversion Principle (DIP)
- All repositories use abstract interfaces
- Implementations are injected via dependency injection
- Easy to swap implementations for testing or different environments

### 📐 Open/Closed Principle (OCP)
- Extensible through composition and new repositories
- Existing repositories don't need modification for new features
- Facade patterns enable seamless evolution

### 🔄 Liskov Substitution Principle (LSP)
- Consistent interfaces across all repositories
- Proper inheritance hierarchies where applicable

---

## Architecture Benefits

### 🏗️ Design Quality
- **Maintainability**: Single-purpose repositories are easier to understand and modify
- **Testability**: Focused interfaces simplify unit testing and mocking
- **Scalability**: New features extend the system without modifying existing code
- **Team Collaboration**: Different developers can work on different repositories independently

### 🔧 Technical Excellence
- **Type Safety**: Strong typing with Either<Failure, T> error handling
- **Reactive Programming**: Stream-based APIs for real-time data
- **Clean Boundaries**: Clear separation between domain logic and infrastructure
- **Dependency Injection**: Proper IoC container integration

---

## Implementation Guidelines

### Error Handling
All repositories use `Either<Failure, T>` pattern for consistent error handling:
```dart
Future<Either<Failure, User>> getUserProfile(UserId userId);
```

### Reactive Patterns
Streams are provided for frequently changing data:
```dart
Stream<List<Project>> watchLocalProjects(UserId ownerId);
```

### Dependency Injection
Repositories are registered with the DI container using `@injectable`:
```dart
@Injectable(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  // Implementation
}
```

### Repository Naming
- Interface: `{Domain}Repository` (e.g., `UserProfileRepository`)
- Implementation: `{Domain}RepositoryImpl` (e.g., `UserProfileRepositoryImpl`)
- Location: `lib/features/{feature}/domain/repositories/`

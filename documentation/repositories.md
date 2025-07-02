# Repositorios de TrackFlow

Este documento describe todos los repositorios disponibles en la aplicación TrackFlow, sus responsabilidades y métodos disponibles.

## 1. AuthRepository
**Ubicación**: `lib/features/auth/domain/repositories/auth_repository.dart`

**Responsabilidad**: Gestiona la autenticación de usuarios, estados de sesión y onboarding.

**Métodos**:
- `Stream<User?> get authState` - Stream del estado de autenticación
- `signInWithEmailAndPassword(String email, String password)` - Iniciar sesión con email/password
- `signUpWithEmailAndPassword(String email, String password)` - Registrar usuario con email/password
- `signInWithGoogle()` - Iniciar sesión con Google
- `signOut()` - Cerrar sesión
- `isLoggedIn()` - Verificar si está logueado
- `onboardingCompleted()` - Marcar onboarding como completado
- `welcomeScreenSeenCompleted()` - Marcar pantalla de bienvenida como vista
- `checkWelcomeScreenSeen()` - Verificar si vio pantalla de bienvenida
- `checkOnboardingCompleted()` - Verificar si completó onboarding
- `getSignedInUserId()` - Obtener ID del usuario logueado

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
- `getProjectById(ProjectId projectId)` - Obtener proyecto por ID
- `watchLocalProjects(UserId ownerId)` - Stream de proyectos locales del usuario

---

## 6. UserProfileRepository
**Ubicación**: `lib/features/user_profile/domain/repositories/user_profile_repository.dart`

**Responsabilidad**: Gestiona los perfiles de usuario y cache de colaboradores.

**Métodos**:
- `updateUserProfile(UserProfile userProfile)` - Actualizar perfil de usuario
- `watchUserProfile(UserId userId)` - Stream del perfil de usuario
- `cacheUserProfiles(List<UserProfile> profiles)` - Cachear perfiles de usuario
- `watchUserProfilesByIds(List<String> userIds)` - Stream de perfiles por IDs
- `getUserProfilesByIds(List<String> userIds)` - Obtener perfiles por IDs

---

## 7. ManageCollaboratorsRepository
**Ubicación**: `lib/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart`

**Responsabilidad**: Gestiona colaboradores en proyectos.

**Métodos**:
- `joinProjectWithId(ProjectId projectId, UserId userId)` - Unirse a proyecto
- `updateProject(Project project)` - Actualizar proyecto
- `leaveProject({ProjectId projectId, UserId userId})` - Abandonar proyecto

---

## 8. MagicLinkRepository
**Ubicación**: `lib/features/magic_link/domain/repositories/magic_link_repository.dart`

**Responsabilidad**: Gestiona links mágicos para invitaciones y acceso a proyectos.

**Métodos**:
- `generateMagicLink({String projectId, String userId})` - Generar link mágico
- `validateMagicLink({String linkId})` - Validar link mágico
- `consumeMagicLink({String linkId})` - Consumir link mágico
- `resendMagicLink({String linkId})` - Reenviar link mágico
- `getMagicLinkStatus({String linkId})` - Obtener estado del link mágico

---

## 9. PlaybackPersistenceRepository
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

## 10. CacheStorageRepository
**Ubicación**: `lib/features/audio_cache/shared/domain/repositories/cache_storage_repository.dart`

**Responsabilidad**: Gestiona el almacenamiento físico de archivos de audio en cache, incluyendo descargas, validación y operaciones de batch.

### Operaciones CRUD Básicas:
- `downloadAndStoreAudio(String trackId, String audioUrl, {progressCallback})` - Descargar y almacenar archivo de audio
- `getCachedAudioPath(String trackId)` - Obtener ruta del archivo cacheado
- `audioExists(String trackId)` - Verificar si existe el archivo
- `getCachedAudio(String trackId)` - Obtener información del audio cacheado
- `deleteAudioFile(String trackId)` - Eliminar archivo de audio

### Operaciones en Lote:
- `downloadMultipleAudios(Map<String, String> trackUrlPairs, {progressCallback})` - Descargar múltiples audios
- `getMultipleCachedAudios(List<String> trackIds)` - Obtener info de múltiples audios cacheados
- `deleteMultipleAudioFiles(List<String> trackIds)` - Eliminar múltiples archivos
- `checkMultipleAudioExists(List<String> trackIds)` - Verificar existencia de múltiples archivos

### Gestión de Descargas:
- `cancelDownload(String trackId)` - Cancelar descarga
- `pauseDownload(String trackId)` - Pausar descarga
- `resumeDownload(String trackId)` - Reanudar descarga
- `getDownloadProgress(String trackId)` - Obtener progreso de descarga
- `getActiveDownloads()` - Obtener descargas activas

### Streams Reactivos:
- `watchDownloadProgress(String trackId)` - Stream del progreso de descarga
- `watchActiveDownloads()` - Stream de descargas activas
- `watchStorageUsage()` - Stream del uso de almacenamiento

### Gestión de Cache Keys:
- `generateCacheKey(String trackId, String audioUrl)` - Generar clave de cache
- `getFilePathFromCacheKey(CacheKey key)` - Obtener ruta desde clave
- `isValidCacheKey(CacheKey key)` - Validar formato de clave

### Migración y Mantenimiento:
- `migrateCacheStructure()` - Migrar estructura de cache
- `rebuildCacheIndex()` - Reconstruir índice de cache
- `validateCacheConsistency()` - Validar consistencia del cache

---

## Resumen de Responsabilidades por Dominio:

### 🎵 Audio y Reproducción:
- **AudioTrackRepository**: Gestión de pistas de audio
- **AudioCommentRepository**: Comentarios en pistas
- **PlaylistRepository**: Gestión de playlists
- **PlaybackPersistenceRepository**: Persistencia de estado de reproducción
- **CacheStorageRepository**: Almacenamiento físico de archivos de audio

### 👥 Usuarios y Colaboración:
- **AuthRepository**: Autenticación y sesiones
- **UserProfileRepository**: Perfiles de usuario
- **ManageCollaboratorsRepository**: Gestión de colaboradores
- **MagicLinkRepository**: Links de invitación

### 📁 Proyectos:
- **ProjectsRepository**: CRUD de proyectos y obtención de detalles

---

## Notas Importantes:

1. **AudioContentRepository**: Este repositorio fue eliminado durante el refactor ya que sus responsabilidades fueron distribuidas entre `AudioTrackRepository`, `CacheStorageRepository` y otros servicios como `AudioSourceResolver`.

2. **ProjectDetailRepository**: Este repositorio fue eliminado ya que su única responsabilidad (`getProjectById`) fue movida al `ProjectsRepository` para simplificar la arquitectura.

3. **Patrones de Error**: Todos los repositorios usan `Either<Failure, T>` para manejo de errores usando la librería Dartz.

4. **Reactividad**: Muchos repositorios proporcionan Streams para datos que cambian frecuentemente, permitiendo UI reactiva.

5. **Separación de Responsabilidades**: Cada repositorio tiene una responsabilidad clara y bien definida siguiendo principios de Clean Architecture.
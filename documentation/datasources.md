# Data Sources Documentation

Esta documentación lista todos los **Local Data Sources** y **Remote Data Sources** organizados por feature en la aplicación TrackFlow.

## Resumen General

- **Total de Data Sources:** 18 archivos (9 local + 9 remote)
- **Features Cubiertas:** 9 diferentes features
- **Patrón de Arquitectura:** Clean Architecture con separación clara entre fuentes locales y remotas

---

## 1. Auth Feature

### Local Data Source: `auth_local_datasource.dart`
**Ubicación:** `lib/features/auth/data/data_sources/`

**Métodos Públicos:**
- `Future<void> cacheUserId(String userId)` - Cachea el ID del usuario
- `Future<String?> getCachedUserId()` - Obtiene el ID del usuario cacheado
- `Future<void> setOnboardingCompleted(bool completed)` - Marca el onboarding como completado
- `Future<bool> isOnboardingCompleted()` - Verifica si el onboarding está completado
- `Future<void> setWelcomeScreenSeen(bool seen)` - Marca la pantalla de bienvenida como vista
- `Future<bool> isWelcomeScreenSeen()` - Verifica si la pantalla de bienvenida fue vista
- `Future<void> setOfflineCredentials(String email, bool hasCredentials)` - Establece credenciales offline
- `Future<String?> getOfflineEmail()` - Obtiene el email offline
- `Future<bool> hasOfflineCredentials()` - Verifica si tiene credenciales offline
- `Future<void> clearOfflineCredentials()` - Limpia las credenciales offline

### Remote Data Source: `auth_remote_datasource.dart`
**Ubicación:** `lib/features/auth/data/data_sources/`

**Métodos Públicos:**
- `Future<User?> getCurrentUser()` - Obtiene el usuario actual
- `Stream<User?> authStateChanges()` - Stream de cambios en el estado de autenticación
- `Future<User?> signInWithEmailAndPassword(String email, String password)` - Inicia sesión con email y contraseña
- `Future<User?> signUpWithEmailAndPassword(String email, String password)` - Registra usuario con email y contraseña
- `Future<User?> signInWithGoogle()` - Inicia sesión con Google
- `Future<void> signOut()` - Cierra sesión

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

## Tecnologías Utilizadas

### Almacenamiento Local
- **Isar Database** - Para datos estructurados
- **SharedPreferences** - Para preferencias y configuraciones simples

### Servicios Remotos
- **Firebase Firestore** - Base de datos en tiempo real
- **Firebase Storage** - Almacenamiento de archivos
- **Firebase Auth** - Autenticación

### Patrones de Arquitectura
- **Either/Failure** - Manejo de errores con Dartz
- **Dependency Injection** - Con Injectable
- **Reactive Programming** - Con Streams
- **Clean Architecture** - Separación clara de responsabilidades

---

## Observaciones

1. **Consistencia:** Todas las features siguen el mismo patrón de arquitectura
2. **Manejo de Errores:** Uso consistente de `Either<Failure, T>` para operaciones que pueden fallar
3. **Reactividad:** Amplio uso de `Stream` para actualizaciones en tiempo real
4. **Cache Strategy:** Implementación robusta de cache local con validación de integridad
5. **Pending Work:** Magic Link local data source requiere implementación

Esta documentación refleja el estado actual del codebase y debe actualizarse cuando se añadan nuevas features o se modifiquen las existentes.
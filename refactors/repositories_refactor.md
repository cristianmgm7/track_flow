# Refactoring de Repositorios - Análisis SOLID

## Violaciones de Principios SOLID Identificadas

### 1. **AuthRepository** - Violación del Principio de Responsabilidad Única (SRP)

**Problema**: El AuthRepository tiene múltiples responsabilidades que no están relacionadas con la autenticación:

- Autenticación (signIn, signUp, signOut)
- Gestión de estado de onboarding
- Gestión de pantalla de bienvenida
- Gestión de estado de sesión

**Refactoring Propuesto**:

```dart
// Separar en repositorios especializados
interface AuthRepository {
  Stream<User?> get authState;
  signInWithEmailAndPassword(String email, String password);
  signUpWithEmailAndPassword(String email, String password);
  signInWithGoogle();
  signOut();
  isLoggedIn();
  getSignedInUserId();
}

interface OnboardingRepository {
  onboardingCompleted();
  checkOnboardingCompleted();
}

interface WelcomeScreenRepository {
  welcomeScreenSeenCompleted();
  checkWelcomeScreenSeen();
}
```

### 2. **ManageCollaboratorsRepository** - Violación del SRP

**Problema**: Gestiona tanto colaboradores como proyectos:

- `joinProjectWithId()` - relacionado con colaboradores
- `updateProject()` - relacionado con proyectos
- `leaveProject()` - relacionado con colaboradores

**Refactoring Propuesto**:

```dart
interface CollaboratorRepository {
  joinProject(ProjectId projectId, UserId userId);
  leaveProject(ProjectId projectId, UserId userId);
  addCollaborator(ProjectId projectId, UserId userId, Role role);
  removeCollaborator(ProjectId projectId, UserId userId);
  updateCollaboratorRole(ProjectId projectId, UserId userId, Role role);
}

// updateProject() debería moverse a ProjectsRepository
```

### 3. **UserProfileRepository** - Violación del SRP

**Problema**: Mezcla gestión de perfiles individuales con cache de múltiples perfiles:

- Operaciones de perfil individual
- Operaciones de cache masivo
- Gestión de perfiles por IDs

**Refactoring Propuesto**:

```dart
interface UserProfileRepository {
  updateUserProfile(UserProfile userProfile);
  watchUserProfile(UserId userId);
  getUserProfile(UserId userId);
}

interface UserProfileCacheRepository {
  cacheUserProfiles(List<UserProfile> profiles);
  watchUserProfilesByIds(List<String> userIds);
  getUserProfilesByIds(List<String> userIds);
  clearCache();
  preloadProfiles(List<String> userIds);
}
```

### 4. **CacheStorageRepository** - Violación del SRP y Principio Abierto/Cerrado (OCP)

**Problema**: Tiene demasiadas responsabilidades:

- Descarga de archivos
- Almacenamiento físico
- Gestión de progreso
- Validación de cache
- Migración de datos
- Gestión de claves

**Refactoring Propuesto**:

```dart
interface AudioDownloadRepository {
  downloadAudio(String trackId, String audioUrl, {progressCallback});
  downloadMultipleAudios(Map<String, String> trackUrlPairs, {progressCallback});
  cancelDownload(String trackId);
  pauseDownload(String trackId);
  resumeDownload(String trackId);
  getDownloadProgress(String trackId);
  getActiveDownloads();
  watchDownloadProgress(String trackId);
  watchActiveDownloads();
}

interface AudioStorageRepository {
  storeAudio(String trackId, File audioFile);
  getCachedAudioPath(String trackId);
  audioExists(String trackId);
  getCachedAudio(String trackId);
  deleteAudioFile(String trackId);
  deleteMultipleAudioFiles(List<String> trackIds);
  watchStorageUsage();
}

interface CacheKeyRepository {
  generateCacheKey(String trackId, String audioUrl);
  getFilePathFromCacheKey(CacheKey key);
  isValidCacheKey(CacheKey key);
}

interface CacheMaintenanceRepository {
  migrateCacheStructure();
  rebuildCacheIndex();
  validateCacheConsistency();
}
```

### 5. **PlaybackPersistenceRepository** - Posible violación del SRP

**Problema**: Gestiona múltiples tipos de persistencia:

- Estado de sesión de reproducción
- Cola de reproducción
- Posiciones individuales de pistas

**Refactoring Propuesto**:

```dart
interface PlaybackSessionRepository {
  savePlaybackState(PlaybackSession session);
  loadPlaybackState();
  clearPlaybackState();
  hasPlaybackState();
}

interface PlaybackQueueRepository {
  saveQueue(List<String> trackIds, int currentIndex);
  loadQueue();
  clearQueue();
}

interface TrackPositionRepository {
  saveTrackPosition(String trackId, Duration position);
  loadTrackPosition(String trackId);
  clearTrackPositions();
  clearTrackPosition(String trackId);
}
```

## Violaciones del Principio de Inversión de Dependencias (DIP)

### Problema General

Los repositorios no están claramente separados de sus implementaciones concretas en la documentación, lo que puede indicar acoplamiento fuerte.

**Solución**:

- Asegurar que todos los repositorios sean interfaces/abstracciones
- Las implementaciones concretas deben estar en la capa de infraestructura
- Usar inyección de dependencias para desacoplar

## Mejoras Adicionales Propuestas

### 1. **Implementar Repository Pattern más puro**

```dart
interface Repository<T, ID> {
  Future<Either<Failure, T>> findById(ID id);
  Future<Either<Failure, List<T>>> findAll();
  Future<Either<Failure, T>> save(T entity);
  Future<Either<Failure, void>> delete(ID id);
}

// Extender para casos específicos
interface AudioTrackRepository extends Repository<AudioTrack, AudioTrackId> {
  Stream<List<AudioTrack>> watchTracksByProject(ProjectId projectId);
  Future<Either<Failure, void>> uploadTrack(File file, AudioTrack track);
}
```

### 2. **Separar Queries de Commands (CQRS)**

```dart
interface AudioTrackQueryRepository {
  getTrackById(AudioTrackId id);
  watchTracksByProject(ProjectId projectId);
}

interface AudioTrackCommandRepository {
  uploadAudioTrack(File file, AudioTrack track);
  deleteTrack(String trackId, String projectId);
  editTrackName(AudioTrackId trackId, ProjectId projectId, String newName);
}
```

### 3. **Implementar Specification Pattern**

```dart
interface ProjectSpecification {
  bool isSatisfiedBy(Project project);
}

interface ProjectsRepository {
  Future<List<Project>> findBySpecification(ProjectSpecification spec);
}
```

## Plan de Implementación

### Fase 1: Separación de Responsabilidades

1. Dividir AuthRepository en 3 repositorios
2. Separar ManageCollaboratorsRepository
3. Dividir UserProfileRepository

### Fase 2: Refactoring de Cache

1. Separar CacheStorageRepository en 4 repositorios especializados
2. Implementar interfaces claras para cada responsabilidad

### Fase 3: Optimización de Playback

1. Dividir PlaybackPersistenceRepository en 3 repositorios
2. Implementar patrón Observer para cambios de estado

### Fase 4: Estandarización

1. Implementar Repository base genérico
2. Aplicar CQRS donde sea beneficioso
3. Implementar Specification Pattern para queries complejas

## Beneficios del Refactoring

1. **Mantenibilidad**: Cada repositorio tiene una sola responsabilidad
2. **Testabilidad**: Más fácil de mockear y testear
3. **Escalabilidad**: Fácil agregar nuevas funcionalidades
4. **Flexibilidad**: Implementaciones intercambiables
5. **Cohesión**: Código más organizado y legible

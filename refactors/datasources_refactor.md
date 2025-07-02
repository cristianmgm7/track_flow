# Data Sources Refactor Plan

## Resumen Ejecutivo

Este documento detalla los cambios necesarios para mejorar la arquitectura de los data sources en TrackFlow, abordando violaciones SOLID, redundancias y inconsistencias identificadas en el análisis.

---

## 1. Refactorización Auth Feature (Violación SRP)

### Problema Actual
`auth_local_datasource.dart` maneja múltiples responsabilidades no relacionadas.

### Solución: Dividir en Data Sources Especializados

#### 1.1 Crear `user_session_local_datasource.dart`
```dart
abstract class UserSessionLocalDataSource {
  Future<void> cacheUserId(String userId);
  Future<String?> getCachedUserId();
  Future<void> setOfflineCredentials(String email, bool hasCredentials);
  Future<String?> getOfflineEmail();
  Future<bool> hasOfflineCredentials();
  Future<void> clearOfflineCredentials();
}
```

#### 1.2 Crear `onboarding_local_datasource.dart`
```dart
abstract class OnboardingLocalDataSource {
  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> isOnboardingCompleted();
  Future<void> setWelcomeScreenSeen(bool seen);
  Future<bool> isWelcomeScreenSeen();
}
```

#### 1.3 Actualizar Dependencias
- Modificar `auth_repository_impl.dart` para usar ambos data sources
- Actualizar injection configuration
- Migrar tests existentes

---

## 2. Refactorización Cache Storage (Violación ISP)

### Problema Actual
`cache_storage_local_data_source.dart` tiene interfaz muy amplia (15 métodos).

### Solución: Segregar Interfaces

#### 2.1 Crear `basic_cache_local_datasource.dart`
```dart
abstract class BasicCacheLocalDataSource {
  Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(CachedAudio cachedAudio);
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);
  Future<Either<CacheFailure, bool>> audioExists(String trackId);
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);
}
```

#### 2.2 Crear `cache_management_local_datasource.dart`
```dart
abstract class CacheManagementLocalDataSource {
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();
  Future<Either<CacheFailure, int>> getTotalStorageUsage();
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();
  Stream<int> watchStorageUsage();
}
```

#### 2.3 Crear `cache_integrity_local_datasource.dart`
```dart
abstract class CacheIntegrityLocalDataSource {
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(String trackId, String expectedChecksum);
  CacheKey generateCacheKey(String trackId, String audioUrl);
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);
}
```

#### 2.4 Crear `batch_cache_local_datasource.dart`
```dart
abstract class BatchCacheLocalDataSource {
  Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(List<String> trackIds);
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds);
}
```

---

## 3. Eliminación de Redundancias

### 3.1 Playlist Feature - Consolidar Métodos Duplicados

#### Problema
Local y remote data sources tienen métodos idénticos.

#### Solución
Refactorizar `playlist_repository_impl.dart` para eliminar duplicación:

```dart
// Antes: Métodos duplicados en local y remote
// Después: Repository maneja la lógica de coordinación

class PlaylistRepositoryImpl implements PlaylistRepository {
  // Usar local como cache, remote como source of truth
  // Implementar sync strategy clara
}
```

#### Tareas Específicas:
1. Revisar `playlist_repository_impl.dart` líneas donde se duplican llamadas
2. Implementar cache-first strategy para lecturas
3. Implementar remote-first strategy para escrituras
4. Añadir sync mechanism para mantener consistencia

### 3.2 User Profile Feature - Eliminar `getUserProfilesByIds` Duplicado

#### Cambios en `user_profile_repository_impl.dart`
```dart
@override
Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(List<String> userIds) async {
  // 1. Intentar obtener desde local cache
  final cachedProfiles = await _localDataSource.getUserProfilesByIds(userIds);
  
  // 2. Identificar IDs faltantes
  final missingIds = _findMissingIds(userIds, cachedProfiles);
  
  // 3. Obtener faltantes desde remote
  if (missingIds.isNotEmpty) {
    final remoteResult = await _remoteDataSource.getUserProfilesByIds(missingIds);
    // 4. Cachear nuevos perfiles
    // 5. Combinar resultados
  }
  
  return Right(combinedProfiles);
}
```

### 3.3 Manage Collaborators Feature - Consolidar `getProjectById`

#### Problema
Métodos similares en local y remote con diferentes firmas.

#### Solución
Estandarizar firma en repository:
```dart
Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
  // Cache-first approach
  final localResult = await _localDataSource.getProjectById(projectId);
  if (localResult != null) {
    return Right(localResult.toDomain());
  }
  
  // Fallback to remote
  return await _remoteDataSource.getProjectById(projectId);
}
```

---

## 4. Implementación Magic Link Local Data Source

### 4.1 Implementar Métodos Faltantes

```dart
class MagicLinkLocalDataSourceImpl implements MagicLinkLocalDataSource {
  final IsarDatabase _database;
  
  @override
  Future<Either<Failure, MagicLink>> cacheMagicLink({required UserId userId}) async {
    try {
      // Implementar usando Isar
      final magicLinkDoc = MagicLinkDocument()
        ..userId = userId.getOrCrash()
        ..cachedAt = DateTime.now();
      
      await _database.magicLinks.put(magicLinkDoc);
      return Right(magicLinkDoc.toDomain());
    } catch (e) {
      return Left(CacheFailure.unexpected());
    }
  }
  
  // Implementar métodos restantes...
}
```

### 4.2 Crear Modelo Isar

```dart
@collection
class MagicLinkDocument {
  Id id = Isar.autoIncrement;
  late String userId;
  late String linkId;
  late DateTime cachedAt;
  late DateTime expiresAt;
  
  MagicLink toDomain() {
    return MagicLink(
      linkId: LinkId(linkId),
      userId: UserId(userId),
      expiresAt: expiresAt,
    );
  }
}
```

---

## 5. Estandarización de Tipos de Retorno

### 5.1 Objetivo
Todos los data sources deben usar `Either<Failure, T>` para consistencia.

### 5.2 Data Sources a Modificar

#### Audio Track Local Data Source
```dart
// Cambiar de:
Future<void> cacheTrack(AudioTrackDTO track)
Future<AudioTrackDTO?> getTrackById(String id)
Future<void> deleteTrack(String id)

// A:
Future<Either<Failure, Unit>> cacheTrack(AudioTrackDTO track)
Future<Either<Failure, AudioTrackDTO?>> getTrackById(String id)
Future<Either<Failure, Unit>> deleteTrack(String id)
```

#### Audio Comment Local Data Source
```dart
// Cambiar de:
Future<void> cacheComment(AudioCommentDTO comment)
Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId)

// A:
Future<Either<Failure, Unit>> cacheComment(AudioCommentDTO comment)
Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(String trackId)
```

#### Playlist Data Sources
```dart
// Ambos local y remote cambiar de:
Future<void> addPlaylist(PlaylistDto playlist)
Future<void> updatePlaylist(PlaylistDto playlist)
Future<void> deletePlaylist(String id)

// A:
Future<Either<Failure, Unit>> addPlaylist(PlaylistDto playlist)
Future<Either<Failure, Unit>> updatePlaylist(PlaylistDto playlist)
Future<Either<Failure, Unit>> deletePlaylist(String id)
```

---

## 6. Plan de Ejecución

### Fase 1: Preparación (1-2 días)
1. Crear branch `feature/datasources-refactor`
2. Backup de archivos existentes
3. Crear nuevas interfaces segregadas

### Fase 2: Auth Refactor (2-3 días)
1. Implementar `UserSessionLocalDataSource`
2. Implementar `OnboardingLocalDataSource`
3. Migrar `AuthRepositoryImpl`
4. Actualizar injection configuration
5. Migrar tests

### Fase 3: Cache Storage Refactor (3-4 días)
1. Implementar interfaces segregadas
2. Crear implementaciones específicas
3. Migrar dependencias existentes
4. Actualizar repositories que dependan de cache

### Fase 4: Eliminar Redundancias (2-3 días)
1. Refactorizar Playlist Repository
2. Refactorizar User Profile Repository
3. Refactorizar Manage Collaborators Repository

### Fase 5: Magic Link Implementation (1-2 días)
1. Crear modelo Isar
2. Implementar métodos faltantes
3. Añadir tests

### Fase 6: Estandarización (2-3 días)
1. Migrar tipos de retorno a `Either<Failure, T>`
2. Actualizar todas las dependencias
3. Migrar tests existentes

### Fase 7: Testing y Validación (2-3 días)
1. Ejecutar test suite completo
2. Verificar que no hay regresiones
3. Validar que todas las features funcionan correctamente

---

## 7. Consideraciones de Migración

### 7.1 Compatibilidad Hacia Atrás
- Mantener interfaces originales como deprecated durante período de transición
- Crear adaptadores temporales si es necesario

### 7.2 Testing Strategy
- Mantener tests existentes funcionando
- Añadir tests para nuevas interfaces
- Verificar cobertura de código no disminuya

### 7.3 Performance Impact
- Monitorear que la segregación no afecte rendimiento
- Optimizar inyección de dependencias si es necesario

---

## 8. Métricas de Éxito

### Pre-Refactor
- **Violaciones SRP**: 1 (Auth Local Data Source)
- **Violaciones ISP**: 1 (Cache Storage Local Data Source)  
- **Métodos Duplicados**: 8 métodos en 3 features
- **Clases Sin Implementar**: 1 (Magic Link Local)
- **Inconsistencias de Tipos**: 12 métodos sin `Either<Failure, T>`

### Post-Refactor (Objetivos)
- **Violaciones SRP**: 0
- **Violaciones ISP**: 0
- **Métodos Duplicados**: 0
- **Clases Sin Implementar**: 0
- **Inconsistencias de Tipos**: 0
- **Nuevas Interfaces**: 6 interfaces especializadas
- **Cobertura de Tests**: Mantener >80%

---

## 9. Riesgos y Mitigaciones

### Riesgo: Breaking Changes
**Mitigación**: Implementar refactor incremental con período de deprecación

### Riesgo: Complejidad de DI
**Mitigación**: Documentar claramente nuevas dependencias y crear factory methods

### Riesgo: Performance Degradation
**Mitigación**: Benchmarking antes y después del refactor

---

Este refactor mejorará significativamente la mantenibilidad, testabilidad y adherencia a principios SOLID del proyecto TrackFlow.
# 🏗️ Architecture Status & Sync Implementation Plan - TrackFlow

## 📊 **Estado Actual de la Arquitectura (Enero 2025)**

### **✅ LO QUE YA ESTÁ IMPLEMENTADO**

#### **🏗️ Estructura Core Existente**

```
lib/core/
├── session/                    # ✅ IMPLEMENTADO
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_session.dart         # ✅ Entidad completa
│   │   ├── repositories/                  # ✅ Abstracciones definidas
│   │   └── usecases/                     # ✅ Use cases básicos
│   └── data/
│       └── repositories/                  # ✅ Implementación básica
│
├── sync/                       # 🟡 PARCIALMENTE IMPLEMENTADO
│   ├── domain/
│   │   ├── entities/                     # ✅ Entidades base definidas
│   │   ├── repositories/                 # ✅ Interfaces definidas
│   │   ├── services/
│   │   │   └── pending_operations_manager.dart  # ✅ Interface completa
│   │   └── usecases/                     # 🚨 PROBLEMA: Full sync únicamente
│   ├── data/
│   │   ├── models/
│   │   │   └── sync_operation_document.dart     # ✅ Modelo completo
│   │   ├── repositories/                 # ✅ Implementaciones base
│   │   └── services/
│   │       └── pending_operations_manager_impl.dart # 🚨 Executors incompletos
│   └── background_sync_coordinator.dart  # 🚨 Implementación placeholder
│
└── network/
    └── network_state_manager.dart        # ✅ Manejo de conectividad
```

#### **🎯 Repositorios Migrados a Offline-First**

```
✅ ProjectsRepositoryImpl          # Completamente migrado
✅ AudioTrackRepositoryImpl        # Completamente migrado
✅ AudioCommentRepositoryImpl      # Completamente migrado
🟡 PlaylistRepositoryImpl          # Necesita migración
🟡 UserProfileRepositoryImpl       # Necesita migración
❌ AuthRepositoryImpl              # No requiere offline-first
❌ MagicLinkRepositoryImpl         # No requiere offline-first
```

---

## 🚨 **PROBLEMAS CRÍTICOS IDENTIFICADOS**

### **1. Downstream Sync Ineficiente (Remote → Local)**

#### **🔥 Problema: Full Sync en cada sincronización**

```dart
// ❌ ACTUAL: SyncProjectsUseCase hace FULL SYNC
Future<void> call() async {
  final failureOrProjects = await remote.getUserProjects(userId);

  // 🚨 BORRA TODO el cache local
  await local.clearCache();

  // 🚨 Descarga TODO de nuevo
  for (final project in projects) {
    await local.cacheProject(project);
  }
}
```

#### **💔 Impacto:**

- **Ancho de banda desperdiciado**: Descarga datos que no han cambiado
- **Latencia alta**: Operaciones lentas e innecesarias
- **Batería**: Consumo excesivo en móviles
- **Experiencia**: UI que se congela durante sync

### **2. Upstream Sync Incompleto (Local → Remote)**

#### **🔥 Operation Executors sin implementar**

```dart
// ❌ ACTUAL: Métodos placeholder en PendingOperationsManagerImpl
Future<Either<Failure, Unit>> _executeCreate(SyncOperationDocument operation) async {
  // TODO: Implement create operation execution
  return Right(unit);
}

Future<Either<Failure, Unit>> _executeUpdate(SyncOperationDocument operation) async {
  // TODO: Implement update operation execution
  return Right(unit);
}
```

#### **💔 Impacto:**

- **Operaciones perdidas**: Cambios locales nunca llegan al servidor
- **Inconsistencia**: Estados diferentes entre local y remoto
- **Frustración**: Usuarios que pierden trabajo

### **3. Metadatos de Sincronización Ausentes**

#### **🔥 Sin timestamps de sincronización**

```dart
// ❌ FALTA: lastUpdatedAt en entidades
class Project {
  // NO HAY lastUpdatedAt
  // NO HAY syncVersion
  // NO HAY conflictResolution
}
```

---

## 🎯 **PLAN DE IMPLEMENTACIÓN COMPLETA**

### **FASE 1: Metadatos de Sincronización (Semana 1-2)**

#### **1.1 Agregar Sync Metadata a Entidades**

```dart
// ✅ IMPLEMENTAR: lib/core/sync/domain/entities/sync_metadata.dart
class SyncMetadata {
  final DateTime lastUpdatedAt;
  final DateTime? lastSyncedAt;
  final int syncVersion;
  final String? etag;
  final SyncStatus syncStatus;
  final List<String> pendingOperations;
}

// ✅ IMPLEMENTAR: Actualizar entidades principales
class Project {
  // ... campos existentes ...
  final SyncMetadata syncMetadata;
}
```

#### **1.2 Database Schema Migration**

```dart
// ✅ IMPLEMENTAR: Migrations para Isar
@collection
class ProjectDocument {
  // ... campos existentes ...

  // Nuevos campos de sync
  late DateTime lastUpdatedAt;
  DateTime? lastSyncedAt;
  late int syncVersion;
  String? etag;
  @enumerated
  late SyncStatus syncStatus;
  late List<String> pendingOperations;
}
```

### **FASE 2: Incremental Sync Implementation (Semana 3-4)**

#### **2.1 Remote API Endpoints para Incremental Sync**

```dart
// ✅ IMPLEMENTAR: Endpoints que soporten lastModified
abstract class ProjectRemoteDataSource {
  // Sync incremental por timestamp
  Future<Either<Failure, List<ProjectDTO>>> getProjectsModifiedSince({
    required String userId,
    required DateTime lastSyncDate,
  });

  // Sync por lotes con ETags
  Future<Either<Failure, SyncBatchResponse<ProjectDTO>>> syncProjectsBatch({
    required String userId,
    required List<SyncBatchRequest> requests,
  });
}
```

#### **2.2 Incremental Sync Use Cases**

```dart
// ✅ IMPLEMENTAR: lib/core/sync/domain/usecases/incremental_sync_usecase.dart
@injectable
class IncrementalSyncUseCase {
  Future<Either<Failure, SyncResult>> call({
    required String entityType,
    required String userId,
  }) async {
    // 1. Obtener último timestamp de sync
    final lastSync = await _syncMetadataRepository.getLastSync(entityType, userId);

    // 2. Fetch solo datos modificados
    final modifiedData = await _remoteSource.getModifiedSince(lastSync);

    // 3. Merge inteligente con resolución de conflictos
    final mergeResult = await _conflictResolver.merge(localData, modifiedData);

    // 4. Actualizar timestamps
    await _syncMetadataRepository.updateLastSync(entityType, DateTime.now());

    return Right(mergeResult);
  }
}
```

### **FASE 3: Conflict Resolution System (Semana 5)**

#### **3.1 Conflict Detection & Resolution**

```dart
// ✅ IMPLEMENTAR: lib/core/sync/domain/services/conflict_resolver.dart
@injectable
class ConflictResolver {
  Future<Either<Failure, MergeResult<T>>> resolveConflicts<T>({
    required T localEntity,
    required T remoteEntity,
    required ConflictResolutionStrategy strategy,
  }) async {
    // Strategies: LastWriteWins, ManualResolution, FieldLevel
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _resolveByTimestamp(localEntity, remoteEntity);
      case ConflictResolutionStrategy.fieldLevel:
        return _resolveFieldByField(localEntity, remoteEntity);
      case ConflictResolutionStrategy.manual:
        return _queueForManualResolution(localEntity, remoteEntity);
    }
  }
}
```

### **FASE 4: Operation Executors Completos (Semana 6-7)**

#### **4.1 Implementar Operation Executors**

```dart
// ✅ IMPLEMENTAR: Executors completos por entity type
class ProjectOperationExecutor implements OperationExecutor {
  @override
  Future<Either<Failure, Unit>> executeCreate(Map<String, dynamic> data) async {
    try {
      final projectDto = ProjectDTO.fromMap(data);
      final result = await _remoteDataSource.createProject(projectDto);

      return result.fold(
        (failure) => Left(failure),
        (createdProject) async {
          // Actualizar local con ID del servidor
          await _localDataSource.updateProjectId(
            localId: data['localId'],
            serverId: createdProject.id,
          );
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(OperationExecutionFailure('Create failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> executeUpdate(Map<String, dynamic> data) async {
    // Implementación completa para updates
  }

  @override
  Future<Either<Failure, Unit>> executeDelete(Map<String, dynamic> data) async {
    // Implementación completa para deletes
  }
}
```

#### **4.2 Operation Executor Registry**

```dart
// ✅ IMPLEMENTAR: Registry para mapear entity types a executors
@lazySingleton
class OperationExecutorRegistry {
  final Map<String, OperationExecutor> _executors = {
    'project': GetIt.instance<ProjectOperationExecutor>(),
    'audio_track': GetIt.instance<AudioTrackOperationExecutor>(),
    'audio_comment': GetIt.instance<AudioCommentOperationExecutor>(),
    'playlist': GetIt.instance<PlaylistOperationExecutor>(),
  };

  OperationExecutor? getExecutor(String entityType) => _executors[entityType];
}
```

### **FASE 5: Background Sync Profesional (Semana 8)**

#### **5.1 Background Sync Coordinator Completo**

```dart
// ✅ IMPLEMENTAR: Coordinator robusto con retry logic
@lazySingleton
class BackgroundSyncCoordinator {
  Future<Either<Failure, SyncResult>> triggerBackgroundSync({
    String? syncKey,
    SyncPriority priority = SyncPriority.normal,
  }) async {
    if (!await _networkStateManager.isConnected) {
      return Right(SyncResult.skipped('No network connection'));
    }

    try {
      // 1. Process pending operations (upstream)
      final upstreamResult = await _processPendingOperations();

      // 2. Incremental sync (downstream)
      final downstreamResult = await _performIncrementalSync();

      // 3. Conflict resolution if needed
      if (upstreamResult.hasConflicts || downstreamResult.hasConflicts) {
        await _resolveConflicts();
      }

      return Right(SyncResult.success());
    } catch (e) {
      return Left(SyncFailure('Background sync failed: $e'));
    }
  }
}
```

### **FASE 6: Performance & Monitoring (Semana 9)**

#### **6.1 Sync Analytics & Monitoring**

```dart
// ✅ IMPLEMENTAR: Analytics para optimización
@injectable
class SyncAnalytics {
  void trackSyncPerformance({
    required String operation,
    required Duration duration,
    required int itemsProcessed,
    required bool success,
  });

  void trackConflictResolution({
    required String entityType,
    required ConflictResolutionStrategy strategy,
    required bool resolved,
  });

  Future<SyncHealthReport> generateHealthReport() async {
    // Métricas de rendimiento, errores, etc.
  }
}
```

---

## 📋 **CHECKLIST DE IMPLEMENTACIÓN**

### **🔥 CRÍTICO - Inmediato (Esta semana)**

- [ ] **Implementar Operation Executors completos**
  - [ ] `ProjectOperationExecutor`
  - [ ] `AudioTrackOperationExecutor`
  - [ ] `AudioCommentOperationExecutor`
- [ ] **Agregar sync metadata a entidades principales**
  - [ ] `Project` con `lastUpdatedAt`, `syncVersion`
  - [ ] `AudioTrack` con sync metadata
  - [ ] `AudioComment` con sync metadata

### **⚡ ALTA PRIORIDAD - Próximas 2 semanas**

- [ ] **Endpoints de incremental sync**
  - [ ] Projects: `getProjectsModifiedSince()`
  - [ ] AudioTracks: `getTracksModifiedSince()`
  - [ ] AudioComments: `getCommentsModifiedSince()`
- [ ] **IncrementalSyncUseCase por feature**
- [ ] **Conflict Resolution básico (LastWriteWins)**

### **📈 MEDIANA PRIORIDAD - Mes 1**

- [ ] **Migrar repositorios restantes**
  - [ ] `PlaylistRepositoryImpl`
  - [ ] `UserProfileRepositoryImpl`
- [ ] **Background Sync robusto con retry**
- [ ] **Sync health monitoring**

### **🎯 OPTIMIZACIÓN - Mes 2**

- [ ] **Field-level conflict resolution**
- [ ] **Sync performance analytics**
- [ ] **Batch sync para operaciones masivas**
- [ ] **Delta sync para archivos grandes**

---

## 🎯 **MÉTRICAS DE ÉXITO POST-IMPLEMENTACIÓN**

### **📊 Performance**

- **Tiempo de sync inicial**: < 5 segundos para 100 projects
- **Sync incremental**: < 2 segundos para cambios típicos
- **Ancho de banda**: 80% reducción vs full sync
- **Operaciones perdidas**: 0%

### **🔧 Reliability**

- **Conflict resolution**: 95% automática
- **Network failures**: Retry automático 3x
- **Data consistency**: 99.9% entre local/remote

### **👥 User Experience**

- **Tiempo de respuesta UI**: < 300ms para operaciones locales
- **Sync status**: Feedback visual en tiempo real
- **Offline capability**: 100% funcional sin conexión

---

## 🚀 **PRÓXIMOS PASOS INMEDIATOS**

1. **Implementar Operation Executors** (Este sprint)
2. **Agregar sync metadata a entidades** (Este sprint)
3. **Crear endpoints de incremental sync** (Próximo sprint)
4. **Implementar conflict resolution básico** (Próximo sprint)

¿Comenzamos con los **Operation Executors** para que el upstream sync funcione correctamente?

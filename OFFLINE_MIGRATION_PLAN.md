# 🚀 TrackFlow Offline-First Migration Plan

## 📋 Executive Summary

**Objetivo**: Migrar todas las funcionalidades de TrackFlow a la arquitectura offline-first completa, eliminando bloqueos por conectividad y garantizando 100% de funcionalidad offline.

**Estado actual**: **Projects** y **AudioTrack** están completamente migrados a offline-first con NetworkStateManager. AudioComment, UserProfile y Auth mantienen patrones legacy.

**Impacto esperado**: 
- ✅ 0% de bloqueos por red
- ✅ 100% funcionalidad offline
- ✅ UX fluida e inmediata
- ✅ Sincronización inteligente en background

---

## 🎯 Fases de Migración

### **FASE 1: Infraestructura Crítica** 🔥 (1-2 semanas)
> Resolver bloqueos inmediatos por conectividad

#### **1.1 Audio Track Repository Migration**
**Prioridad**: 🔥 **CRÍTICA**  
**Problema**: Operaciones bloquean completamente cuando no hay red  
**Archivos afectados**:
- `lib/features/audio_track/data/models/audio_track_document.dart`
- `lib/features/audio_track/data/repositories/audio_track_repository_impl.dart`

**Tasks**: ✅ **COMPLETED**
- [x] **1.1.1** ✅ Agregar `SyncMetadataDocument` a `AudioTrackDocument`
  ```dart
  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;
  ```
- [x] **1.1.2** ✅ Eliminar `return Left(ServerFailure('No network connection'))`
- [x] **1.1.3** ✅ Implementar patrón cache-aside en `watchTracksByProject()`
  ```dart
  return localDataSource.watchTracksByProject(projectId.value)
    .asyncMap((localResult) async {
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_${projectId.value}',
        );
      }
      return localResult.fold(...);
    });
  ```
- [x] **1.1.4** ✅ Convertir operaciones CUD a offline-queue pattern
  - `uploadAudioTrack()` → Cache local + PendingOperationsManager queue  
  - `editTrackName()` → Update local + queue sync
  - `deleteTrack()` → Soft delete local + queue sync
- [x] **1.1.5** ✅ Integrar `BackgroundSyncCoordinator` para sync no-bloqueante
- [x] **1.1.6** ✅ **BONUS**: Migración completa de NetworkInfo → NetworkStateManager

#### **1.2 BLoC Integration con SyncAwareMixin**
**Problema**: No hay feedback de estado de sync en la UI  
**Archivos afectados**:
- `lib/features/audio_track/presentation/bloc/audio_track_bloc.dart`
- `lib/features/projects/presentation/blocs/projects_bloc.dart`
- `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart`

**Tasks**:
- [ ] **1.2.1** Integrar `SyncAwareMixin` en AudioTrackBloc
  ```dart
  class AudioTrackBloc extends Bloc<AudioTrackEvent, AudioTrackState> 
      with SyncAwareMixin {
  ```
- [ ] **1.2.2** Agregar estados de sync en AudioTrackState
- [ ] **1.2.3** Mostrar indicadores de sync en la UI
- [ ] **1.2.4** Aplicar patrón a ProjectsBloc y AudioCommentBloc

---

### **FASE 2: Funcionalidades Core** ⚠️ (1-2 semanas)
> Migración completa de funcionalidades principales

#### **2.1 Audio Comment Repository Migration**
**Prioridad**: ⚠️ **ALTA**  
**Problema**: Falta integración completa con arquitectura sync  
**Archivos afectados**:
- `lib/features/audio_comment/data/models/audio_comment_document.dart`
- `lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart`

**Tasks**:
- [ ] **2.1.1** Agregar `SyncMetadataDocument` a `AudioCommentDocument`
- [ ] **2.1.2** Implementar cache-aside pattern en `watchComments()`
- [ ] **2.1.3** Integrar `BackgroundSyncCoordinator`
- [ ] **2.1.4** Crear `AudioCommentConflictResolutionService`
  ```dart
  @injectable
  class AudioCommentConflictResolutionService 
      extends ConflictResolutionService<AudioCommentDocument> {
    
    @override
    Future<AudioCommentDocument> resolveConflict(
      AudioCommentDocument local,
      AudioCommentDocument remote,
    ) async {
      // Lógica específica para comentarios
      // Combinar comentarios, mantener orden temporal
    }
  }
  ```
- [ ] **2.1.5** Convertir operaciones a offline-queue
- [ ] **2.1.6** Manejar conflictos en comentarios simultáneos

#### **2.2 User Profile Repository Migration**  
**Prioridad**: ⚠️ **MEDIA**  
**Problema**: Falta sync metadata y background sync  
**Archivos afectados**:
- `lib/features/user_profile/data/models/user_profile_document.dart`
- `lib/features/user_profile/data/repositories/user_profile_repository_impl.dart`

**Tasks**:
- [ ] **2.2.1** Agregar `SyncMetadataDocument` a `UserProfileDocument`
- [ ] **2.2.2** Integrar `BackgroundSyncCoordinator`
- [ ] **2.2.3** Crear `UserProfileConflictResolutionService`
- [ ] **2.2.4** Implementar cache-aside pattern
- [ ] **2.2.5** Manejar updates offline de perfil
- [ ] **2.2.6** Sync inteligente de avatares y archivos

---

### **FASE 3: Funcionalidades Secundarias** 🔄 (1 semana)
> Completar migración de funcionalidades restantes

#### **3.1 Playlist Repository Migration**
**Prioridad**: 🔄 **BAJA**  
**Problema**: Arquitectura completa requiere migración  
**Archivos afectados**:
- `lib/features/playlist/data/models/playlist_document.dart`
- `lib/features/playlist/data/repositories/playlist_repository_impl.dart`

**Tasks**:
- [ ] **3.1.1** Agregar `SyncMetadataDocument` a `PlaylistDocument`
- [ ] **3.1.2** Implementar patrón cache-aside completo
- [ ] **3.1.3** Integrar `BackgroundSyncCoordinator`
- [ ] **3.1.4** Crear `PlaylistConflictResolutionService`
- [ ] **3.1.5** Manejar reordenamiento offline de tracks
- [ ] **3.1.6** Sync inteligente de cambios en playlist

---

### **FASE 4: Optimización y Refinamiento** ✨ (1 semana)
> Mejoras avanzadas y optimizaciones

#### **4.1 Cross-Feature Conflict Resolution**
**Tasks**:
- [ ] **4.1.1** Resolver conflictos entre Projects y AudioTracks
- [ ] **4.1.2** Manejar eliminación cascada offline
- [ ] **4.1.3** Sincronizar colaboradores cross-feature
- [ ] **4.1.4** Validación de integridad referencial

#### **4.2 Advanced UI Feedback**
**Tasks**:
- [ ] **4.2.1** Indicadores granulares de sync por entidad
- [ ] **4.2.2** Progress indicators para uploads grandes
- [ ] **4.2.3** Notificaciones de conflictos resueltos
- [ ] **4.2.4** Dashboard de estado offline

---

## 🔧 Arquitectura de Referencia

### **Patrón Cache-Aside (Projects + AudioTrack implementados)**
```dart
// ✅ CORRECTO - Patrón implementado en AudioTrackRepository
@override
Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
  ProjectId projectId,
) {
  return localDataSource.watchTracksByProject(projectId.value)
    .asyncMap((localResult) async {
      // Trigger background sync if connected (non-blocking)
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_${projectId.value}',
        );
      }
      
      // Return local data immediately
      return localResult.fold(
        (failure) => Left(failure),
        (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
      );
    });
}
```

### **Operaciones Offline-First**
```dart
// ✅ CORRECTO - Implementado en AudioTrackRepository
@override
Future<Either<Failure, Unit>> uploadAudioTrack({
  required File file,
  required AudioTrack track,
}) async {
  try {
    // 1. OFFLINE-FIRST: Save locally IMMEDIATELY
    final dto = AudioTrackDTO.fromDomain(track, extension: file.path.split('.').last);
    final localResult = await localDataSource.cacheTrack(dto);
    
    // 2. Queue for background sync
    await _pendingOperationsManager.addOperation(
      entityType: 'audio_track',
      entityId: track.id.value,
      operationType: 'upload',
      priority: SyncPriority.high,
      data: {'filePath': file.path},
    );
    
    // 3. Trigger background sync if connected
    if (await _networkStateManager.isConnected) {
      _backgroundSyncCoordinator.triggerBackgroundSync(
        syncKey: 'audio_tracks_upload',
      );
    }
    
    return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
  } catch (e) {
    return Left(DatabaseFailure('Failed to prepare track upload: $e'));
  }
}
```

### **Document Model con Sync Metadata**
```dart
// ✅ IMPLEMENTADO - AudioTrackDocument con sync metadata
@collection  
class AudioTrackDocument {
  Id id = Isar.autoIncrement;
  String? trackId;
  String? name;
  String? filePath;
  String? projectId;
  String? userId;
  
  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;
  
  // Factory methods implementados
  factory AudioTrackDocument.fromRemoteDTO(AudioTrackDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return AudioTrackDocument()
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? DateTime.now(),
      );
  }
  
  factory AudioTrackDocument.forLocalCreation() {
    return AudioTrackDocument()
      ..syncMetadata = SyncMetadataDocument.forLocalCreation();
  }
}
```

---

## 📊 Tracking de Progreso

### **Métricas de Éxito**
- [ ] **0%** operaciones que bloquean por red
- [ ] **100%** funcionalidad disponible offline  
- [ ] **< 2s** tiempo respuesta para operaciones locales
- [ ] **95%+** éxito rate en resolución de conflictos
- [ ] **24/7** disponibilidad de funciones core sin red

### **Testing Strategy**  
Para cada funcionalidad migrada:
- [ ] **Unit Tests**: Repository cache-aside patterns
- [ ] **Integration Tests**: Background sync flows
- [ ] **Offline Tests**: Airplane mode scenario testing  
- [ ] **Conflict Tests**: Concurrent modification scenarios
- [ ] **Performance Tests**: Large dataset sync performance

---

## 🚨 Riesgos y Mitigaciones

### **Riesgo 1**: Migración rompe funcionalidad existente
**Mitigación**: 
- Feature flags para rollback inmediato
- Tests exhaustivos antes de merge  
- Migración incremental por repository

### **Riesgo 2**: Conflictos de data durante migración
**Mitigación**:
- Backup automático antes de cambios schema
- Migración de datos en background
- Validación de integridad post-migración

### **Riesgo 3**: Performance impact por sync overhead
**Mitigación**:
- Sync throttling y batching
- Priorización de operaciones críticas
- Monitoring de performance en tiempo real

---

## 📁 Referencias Técnicas

### **Archivos de Referencia (Ya implementados)**
- `lib/features/projects/data/repositories/projects_repository_impl.dart` - ✅ Patrón cache-aside perfecto
- `lib/core/sync/background_sync_coordinator.dart` - ✅ Coordinación no-bloqueante  
- `lib/core/sync/domain/services/conflict_resolution_service.dart` - ✅ Resolución de conflictos

### **Servicios Core Disponibles**
- ✅ `BackgroundSyncCoordinator` - Sync no-bloqueante
- ✅ `NetworkStateManager` - Gestión conectividad reactiva  
- ✅ `ConflictResolutionService` - Resolución automática conflictos
- ✅ `PendingOperationsManager` - Cola de operaciones offline
- ✅ `SyncAwareMixin` - BLoC integration (sin usar aún)

---

## 🎯 Plan de Implementación Sugerido

### **Sprint 1 (1-2 semanas)**: FASE 1 - Critical Fixes
- AudioTrack repository migration completa
- SyncAwareMixin integration básica
- Testing offline crítico

### **Sprint 2 (1-2 semanas)**: FASE 2 - Core Features  
- AudioComment migration completa
- UserProfile migration completa
- Cross-feature testing

### **Sprint 3 (1 semana)**: FASE 3 - Secondary Features
- Playlist migration completa
- End-to-end offline testing
- Performance optimization

### **Sprint 4 (1 semana)**: FASE 4 - Polish & Optimization  
- Advanced conflict resolution
- UI/UX refinements  
- Production readiness validation

**Timeline Total Estimado: 4-6 semanas**

---

## ✅ Checklist Final

### **Pre-Migration**
- [ ] Backup completo de base de datos
- [ ] Feature flags configurados
- [ ] Monitoring de performance establecido

### **Post-Migration**  
- [ ] Validación de integridad de datos
- [ ] Performance benchmarks comparativos
- [ ] User acceptance testing
- [ ] Documentation actualizada

### **Production Readiness**
- [ ] Zero network-blocking operations
- [ ] 100% offline functionality verified
- [ ] Conflict resolution tested under load
- [ ] Rollback procedures validated

---

**🎯 Meta Final**: TrackFlow funcionando perfectamente offline con sincronización inteligente y transparente en background, siguiendo el patrón de arquitectura offline-first establecido en Projects.
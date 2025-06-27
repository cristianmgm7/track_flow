# Audio Cache Architecture - Feature Requirement Document (FRD)

## Overview

Rediseño de la arquitectura de audio cache para soportar cache de tracks individuales y playlists con infraestructura compartida, siguiendo principios de Clean Architecture y las mejores prácticas establecidas en TrackFlow.

## Current State Analysis

- Arquitectura dual confusa (Repository + DownloadManagementService)
- BLoC monolítico que mezcla concerns de tracks y playlists
- Duplicación potencial de infraestructura
- Límites hardcoded y configuración inflexible

## Proposed Architecture

### Directory Structure

```
lib/features/audio_cache/
├── shared/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── cached_audio.dart
│   │   │   ├── cache_reference.dart
│   │   │   ├── cache_metadata.dart
│   │   │   └── download_progress.dart
│   │   ├── repositories/
│   │   │   ├── cache_storage_repository.dart
│   │   │   └── cache_metadata_repository.dart
│   │   ├── services/
│   │   │   ├── cache_orchestration_service.dart
│   │   │   ├── storage_management_service.dart
│   │   │   ├── download_management_service.dart
│   │   │   └── cache_analytics_service.dart
│   │   └── value_objects/
│   │       ├── cache_key.dart
│   │       ├── storage_limit.dart
│   │       └── download_priority.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── cache_local_datasource.dart
│   │   │   └── cache_remote_datasource.dart
│   │   ├── models/
│   │   │   ├── cached_audio_document.dart
│   │   │   ├── cache_reference_document.dart
│   │   │   └── cache_metadata_dto.dart
│   │   └── repositories/
│   │       ├── cache_storage_repository_impl.dart
│   │       └── cache_metadata_repository_impl.dart
│   └── infrastructure/
│       └── services/
│           ├── cache_orchestration_service_impl.dart
│           ├── storage_management_service_impl.dart
│           ├── download_management_service_impl.dart
│           └── cache_analytics_service_impl.dart
├── track/
│   ├── domain/
│   │   └── usecases/
│   │       ├── cache_track_usecase.dart
│   │       ├── remove_track_cache_usecase.dart
│   │       ├── get_track_cache_status_usecase.dart
│   │       └── get_cached_track_path_usecase.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── track_cache_bloc.dart
│       │   ├── track_cache_event.dart
│       │   └── track_cache_state.dart
│       └── widgets/
│           └── smart_track_cache_icon.dart
├── playlist/
│   ├── domain/
│   │   └── usecases/
│   │       ├── cache_playlist_usecase.dart
│   │       ├── remove_playlist_cache_usecase.dart
│   │       ├── get_playlist_cache_status_usecase.dart
│   │       └── bulk_cache_operations_usecase.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── playlist_cache_bloc.dart
│       │   ├── playlist_cache_event.dart
│       │   └── playlist_cache_state.dart
│       └── widgets/
│           └── playlist_cache_icon.dart
└── presentation/
    ├── screens/
    │   └── cache_management_screen.dart
    └── widgets/
        └── storage_stats_widget.dart
```

## Core Entities & Value Objects

### Entities

```dart
// cached_audio.dart
class CachedAudio extends Equatable {
  final String trackId;
  final String filePath;
  final int fileSizeBytes;
  final DateTime cachedAt;
  final String checksum;
  final AudioQuality quality;
}

// cache_reference.dart
class CacheReference extends Equatable {
  final String trackId;
  final List<String> referenceIds; // ['playlist_123', 'individual']
  final DateTime createdAt;

  // CRITICAL: Reference counting to prevent data loss
  bool get canDelete => referenceIds.isEmpty;
  int get referenceCount => referenceIds.length;
}

// cache_metadata.dart
class CacheMetadata extends Equatable {
  final String trackId;
  final int referenceCount;
  final DateTime lastAccessed;
  final List<String> references;
  final CacheStatus status;
  final int downloadAttempts;
}
```

### Value Objects

```dart
// cache_key.dart
class CacheKey extends ValueObject<String> {
  // CRITICAL: Use composite key to avoid collisions
  factory CacheKey.composite(String trackId, String checksum) =>
    CacheKey._("${trackId}_${checksum}");
  factory CacheKey.fromUrl(String url) => CacheKey._(sha1Hash(url));
}

// storage_limit.dart
class StorageLimit extends ValueObject<int> {
  static const StorageLimit defaultLimit = StorageLimit._(500 * 1024 * 1024); // 500MB
  factory StorageLimit.megabytes(int mb) => StorageLimit._(mb * 1024 * 1024);
}

// download_priority.dart
enum DownloadPriority { high, normal, low, background }
```

## Services Architecture

### 1. Cache Orchestration Service (Simplified Coordinator)

```dart
abstract class CacheOrchestrationService {
  // Core operations - simplified for MVP
  Future<Either<CacheFailure, Unit>> cacheAudio(
    String trackId,
    String audioUrl,
    String referenceId,
    {ConflictPolicy policy = ConflictPolicy.lastWins}
  );

  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);

  Future<Either<CacheFailure, Unit>> removeFromCache(
    String trackId,
    String referenceId
  );

  // Streams for real-time updates
  Stream<DownloadProgress> watchDownloadProgress(String trackId);
  Stream<CacheStatus> watchCacheStatus(String trackId);
  Stream<StorageStats> watchStorageStats();
}

// Simple conflict resolution for MVP
enum ConflictPolicy { lastWins, firstWins, higherQuality }
```

### 2. Storage Management Service

```dart
abstract class StorageManagementService {
  Future<Either<StorageFailure, StorageStats>> getStorageStats();
  Future<Either<StorageFailure, Unit>> cleanupStorage();
  Future<Either<StorageFailure, Unit>> enforceStorageLimit();
  Stream<StorageStats> watchStorageStats();
}
```

### 3. Download Management Service

```dart
abstract class DownloadManagementService {
  Future<Either<DownloadFailure, Unit>> downloadAudio(
    String trackId,
    String url,
    {DownloadPriority priority = DownloadPriority.normal}
  );

  Future<Either<DownloadFailure, Unit>> cancelDownload(String trackId);
  Stream<DownloadProgress> watchDownloadProgress(String trackId);
  Stream<List<ActiveDownload>> watchActiveDownloads();
}
```

## Error Handling Strategy

### Failure Hierarchy

```dart
// Base failures
abstract class CacheFailure extends Equatable {}

// Specific failures
class NetworkCacheFailure extends CacheFailure {
  final String message;
  final String? errorCode;
}

class StorageCacheFailure extends CacheFailure {
  final String message;
  final StorageFailureType type;
}

class PermissionCacheFailure extends CacheFailure {
  final String requiredPermission;
}

class CorruptedCacheFailure extends CacheFailure {
  final String trackId;
  final String checksum;
}

class CacheKeyCollisionFailure extends CacheFailure {
  final String trackId;
  final String conflictingChecksum;
}
```

### Error Propagation Pattern

- Services return `Either<Failure, Success>`
- Use Cases wrap service calls with additional context
- BLoC handles failures and emits appropriate error states
- UI components show user-friendly error messages

## Implementation Roadmap

### Phase 1: Core Infrastructure (Weeks 1-2)

1. **Create Shared Domain Layer**

   - [ ] Define core entities (CachedAudio, CacheReference, CacheMetadata)
   - [ ] Create value objects (CacheKey, StorageLimit, DownloadPriority)
   - [ ] Define service interfaces
   - [ ] Create failure types and error hierarchy

2. **Implement Data Layer**

   - [ ] Create Isar models for local storage
   - [ ] Implement local datasource with Isar
   - [ ] Create Firebase Storage remote datasource
   - [ ] Implement repository implementations

3. **Build Infrastructure Services**
   - [ ] Implement StorageManagementService with file system operations
   - [ ] Create DownloadManagementService with Dio integration
   - [ ] Build CacheOrchestrationService as main coordinator
   - [ ] Add CacheAnalyticsService for usage tracking

### Phase 2: Track Cache Feature (Week 3)

4. **Track Cache Use Cases**

   - [ ] CacheTrackUseCase with validation and error handling
   - [ ] RemoveTrackCacheUseCase with reference counting
   - [ ] GetTrackCacheStatusUseCase with real-time updates
   - [ ] GetCachedTrackPathUseCase with path validation

5. **Track Cache BLoC**

   - [ ] TrackCacheBloc with event/state management
   - [ ] Integration with shared services
   - [ ] Error state management and recovery
   - [ ] Stream subscriptions management

6. **Track Cache UI**
   - [ ] SmartTrackCacheIcon with animations and states
   - [ ] Progress indicators and error dialogs
   - [ ] Haptic feedback and accessibility

### Phase 3: Playlist Cache Feature (Week 4)

7. **Playlist Cache Use Cases**

   - [ ] CachePlaylistUseCase with batch operations
   - [ ] RemovePlaylistCacheUseCase with selective removal
   - [ ] GetPlaylistCacheStatusUseCase with aggregate status
   - [ ] BulkCacheOperationsUseCase for playlist management

8. **Playlist Cache BLoC**

   - [ ] PlaylistCacheBloc with bulk operation support
   - [ ] Progress tracking for multiple tracks
   - [ ] Cancellation and retry mechanisms
   - [ ] State synchronization with track cache

9. **Playlist Cache UI**
   - [ ] PlaylistCacheIcon with progress visualization
   - [ ] Bulk operation controls and feedback
   - [ ] Cache status indicators per track

### Phase 4: Management & Analytics (Week 5)

10. **Cache Management Screen**

    - [ ] Storage stats visualization
    - [ ] Cache cleanup controls
    - [ ] Individual track/playlist management
    - [ ] Settings and configuration

11. **Analytics & Optimization**
    - [ ] Usage pattern tracking
    - [ ] Cache hit/miss analytics
    - [ ] Performance metrics
    - [ ] Cleanup strategy optimization

### Phase 5: Testing & Migration (Week 6)

12. **Testing Suite**

    - [ ] Unit tests for all use cases
    - [ ] Integration tests for services
    - [ ] Widget tests for UI components
    - [ ] End-to-end cache scenarios

13. **Migration Strategy**
    - [ ] Data migration from current implementation
    - [ ] Gradual feature flag rollout
    - [ ] Performance comparison
    - [ ] Rollback plan

## Configuration & Settings

### Configurable Parameters

```dart
class CacheConfiguration {
  final StorageLimit maxStorageSize;
  final int maxConcurrentDownloads;
  final Duration downloadTimeout;
  final int maxRetryAttempts;
  final Duration cleanupInterval;
  final double cleanupThreshold; // Percentage to trigger cleanup
}
```

### Environment-Specific Settings

- Development: Smaller limits, verbose logging
- Staging: Production-like limits, detailed analytics
- Production: Optimized limits, error reporting

## Performance Considerations

### Memory Management

- Stream subscription disposal in BLoCs
- File handle cleanup after operations
- Progress tracking object pooling

### Storage Optimization

- Deduplication by track ID and checksum
- Efficient cleanup strategies (LRU, size-based)
- Compression for metadata storage

### Network Optimization

- Retry with exponential backoff
- Connection pooling through Dio
- Download prioritization and throttling

## Security & Privacy

- Audio file encryption at rest (optional)
- Secure cleanup ensuring no data remnants
- Privacy-compliant analytics collection
- Permission handling for storage access

## Monitoring & Observability

- Download success/failure rates
- Storage usage patterns
- Cache hit/miss ratios
- Performance metrics (download speed, cleanup time)
- Error frequency and types

## Dependencies

- **Isar**: Local database for metadata
- **Firebase Storage**: Remote audio storage
- **Dio**: HTTP client for downloads
- **path_provider**: File system access
- **crypto**: File checksum generation
- **equatable**: Value equality comparisons
- **injectable**: Dependency injection
- **dartz**: Functional programming (Either)

## Success Metrics

- Zero data duplication across track/playlist cache
- Sub-100ms cache status checks
- > 95% download success rate
- Configurable storage limits respected
- Clean error recovery and user feedback
- Seamless migration from current implementation

---

## MVP vs Post-MVP Features

### 🚀 CRITICAL for Production (MVP - Weeks 1-4)

#### Phase 1: Core MVP Infrastructure (Weeks 1-2)

1. **Shared Domain Layer - MVP Version**

   - [ ] Core entities with simplified structure
   - [ ] CacheKey with composite key (trackId + checksum) - **CRITICAL**
   - [ ] CacheReference with reference counting - **CRITICAL**
   - [ ] Basic value objects (StorageLimit, ConflictPolicy)
   - [ ] Essential failure types including CacheKeyCollisionFailure

2. **Data Layer - MVP Version**

   - [ ] Isar models for core entities only
   - [ ] Basic local datasource implementation
   - [ ] Firebase Storage integration
   - [ ] Repository implementations focused on core functionality

3. **Infrastructure Services - Simplified**
   - [ ] Single CacheOrchestrationService (no separation for MVP)
   - [ ] Basic StorageManagementService (essential cleanup only)
   - [ ] Simple DownloadManagementService (basic queue, no priorities)
   - [ ] **Skip**: CacheAnalyticsService (post-MVP)

#### Phase 2: Feature Implementation (Weeks 3-4)

4. **Track Cache - MVP**

   - [ ] Essential use cases only (cache, remove, get status, get path)
   - [ ] TrackCacheBloc with basic state management
   - [ ] Simple UI components without advanced animations

5. **Playlist Cache - MVP**

   - [ ] Core use cases for playlist operations
   - [ ] PlaylistCacheBloc with bulk operation support
   - [ ] Basic UI components with progress indication

6. **Testing & Migration - Critical Path**
   - [ ] Unit tests for critical path use cases
   - [ ] Integration tests for core services
   - [ ] Migration strategy from current implementation

### 📈 POST-MVP Features (Weeks 5+)

#### Advanced Architecture Improvements

- [ ] **Service Separation**: Split CacheOrchestrationService into specialized coordinators
  - [ ] TrackCacheCoordinator
  - [ ] PlaylistCacheCoordinator
  - [ ] CacheTaskRunner for advanced queuing
- [ ] **CacheEventBus**: For cross-BLoC synchronization
- [ ] **Advanced Analytics**: CacheAnalyticsService with usage patterns
- [ ] **Conflict Resolution**: Advanced policies beyond simple rules

#### Enhanced Features

- [ ] **Pre-caching**: Intelligent background caching based on user patterns
- [ ] **Cache Optimization**: ML-based cleanup strategies
- [ ] **Advanced UI**: Complex animations, haptic feedback, undo operations
- [ ] **Partial Caching**: For large playlists with progressive download
- [ ] **Offline-first**: Global toggle for cache-preferred playback

#### Performance & Observability

- [ ] **Memory Optimization**: Advanced stream management and object pooling
- [ ] **Network Optimization**: Sophisticated retry strategies and connection pooling
- [ ] **Advanced Analytics**: Detailed metrics, performance tracking
- [ ] **A/B Testing**: Framework for cache strategy experiments

### Critical Implementation Notes

#### Must-Have for MVP:

1. **Cache Key Collision Prevention**: Composite keys prevent data loss
2. **Reference Counting**: Prevents accidental deletion of shared tracks
3. **Conflict Resolution**: Simple policies prevent silent failures
4. **Basic Error Recovery**: Robust error handling for production stability

#### MVP Simplifications:

1. **Single Orchestrator**: Avoid over-engineering with multiple coordinators
2. **No Event Bus**: Direct BLoC communication for simplicity
3. **Basic Analytics**: Only essential metrics (success/failure rates)
4. **Simple Cleanup**: LRU-based cleanup without advanced algorithms

#### Post-MVP Evolution Path:

1. **Gradual Service Separation**: Split orchestrator when complexity increases
2. **Event-Driven Architecture**: Add EventBus when cross-feature sync becomes complex
3. **Advanced Features**: Add pre-caching and ML when user base grows
4. **Performance Optimization**: Implement advanced strategies based on production metrics

---

**Next Steps**: Begin MVP Phase 1 implementation focusing on core infrastructure with critical collision prevention and reference counting.

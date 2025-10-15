---
date: 2025-10-11T13:16:12+0000
researcher: Cristian
git_commit: 50c0c7df5015e44e335c98f6ff786db68a3280ab
branch: record/comments
repository: track_flow
topic: "Audio Storage Architecture - Current Implementation Analysis"
tags: [research, codebase, audio-storage, firebase, cache-management, clean-architecture]
status: complete
last_updated: 2025-10-11
last_updated_by: Cristian
---

# Research: Audio Storage Architecture - Current Implementation Analysis

**Date**: 2025-10-11T13:16:12+0000
**Researcher**: Cristian
**Git Commit**: 50c0c7df5015e44e335c98f6ff786db68a3280ab
**Branch**: record/comments
**Repository**: track_flow

## Research Question

Document the current audio storage architecture across TrackFlow, validating concerns raised in `thoughts/thoughts_audio_storage.md` regarding:
1. Code duplication in audio upload/download operations
2. Tight coupling between features and Firebase
3. Lack of centralized contract for audio operations
4. Improper local directory handling inside repositories
5. Status of the `FirebaseAudioUploadService` refactor

## Summary

The TrackFlow codebase is currently in a **partially completed refactoring state** for audio storage operations. A new centralized `FirebaseAudioService` has been created in `lib/core/audio/data/audio_file_repository_impl.dart` to replace the deleted `FirebaseAudioUploadService`, but **the migration is incomplete**, causing broken imports in 3 files and preventing successful code generation.

**Key Findings:**

1. **Broken State**: `FirebaseAudioUploadService` was deleted but is still imported by:
   - [track_version_remote_datasource.dart](lib/features/track_version/data/datasources/track_version_remote_datasource.dart#L8)
   - [audio_comment_storage_coordinator.dart](lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart#L6)
   - [injection.config.dart](lib/core/di/injection.config.dart#L77) (generated)

2. **Missing Contract**: The domain layer file [audio_file_repository.dart](lib/core/audio/domain/audio_file_repository.dart) is completely empty, violating Clean Architecture's dependency inversion principle.

3. **Directory Management**: Multiple files duplicate the same `_getCacheDirectory()` pattern across 6+ locations, managing filesystem paths directly in repositories and datasources.

4. **Dual Systems**: Two overlapping systems exist:
   - **New (Incomplete)**: `FirebaseAudioService` in `lib/core/audio/`
   - **Old (Active)**: `CacheStorageRemoteDataSource` and `AudioDownloadRepository` in `lib/features/audio_cache/`

5. **Complex Cache Architecture**: A sophisticated offline-first audio caching system exists with proper Clean Architecture but lacks centralization for cloud operations.

## Detailed Findings

### 1. FirebaseAudioUploadService - Deleted But Still Referenced

#### File Status
- **Original Location**: [lib/core/services/firebase_audio_upload_service.dart](lib/core/services/firebase_audio_upload_service.dart)
- **Git Status**: `D` (deleted in working tree)
- **Replacement**: [lib/core/audio/data/audio_file_repository_impl.dart](lib/core/audio/data/audio_file_repository_impl.dart) with `FirebaseAudioService` class

#### Broken References

**1. TrackVersionRemoteDataSource** ([track_version_remote_datasource.dart:8](lib/features/track_version/data/datasources/track_version_remote_datasource.dart#L8)):
```dart
import 'package:trackflow/core/services/firebase_audio_upload_service.dart';

// Line 35: Field declaration
final FirebaseAudioUploadService _uploadService;

// Line 54: Usage in createTrackVersion
final uploadResult = await _uploadService.uploadAudioFile(
  audioFile: audioFile,
  storagePath: storagePath,
  metadata: {...},
);
```

**2. AudioCommentStorageCoordinator** ([audio_comment_storage_coordinator.dart:6](lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart#L6)):
```dart
import 'package:trackflow/core/services/firebase_audio_upload_service.dart';

// Line 15: Field declaration
final FirebaseAudioUploadService _uploadService;

// Used in 3 methods:
// - uploadCommentAudio (line 49)
// - deleteCommentAudio (line 60)
// - downloadAndCacheCommentAudio (line 175)
```

**3. Generated DI Config** ([injection.config.dart:77](lib/core/di/injection.config.dart#L77)):
```dart
import 'package:trackflow/core/services/firebase_audio_upload_service.dart' as _i84;

// Line 694-695: Service registration
gh.lazySingleton<_i84.FirebaseAudioUploadService>(
    () => _i84.FirebaseAudioUploadService(gh<_i16.FirebaseStorage>()));

// Injected into:
// - TrackVersionRemoteDataSource (line 777)
// - AudioCommentStorageCoordinator (line 998)
```

**Impact**: These broken imports prevent successful code generation with `build_runner`, blocking the registration of the new `FirebaseAudioService`.

---

### 2. New Audio Service - Incomplete Implementation

#### FirebaseAudioService Implementation

**Location**: [lib/core/audio/data/audio_file_repository_impl.dart](lib/core/audio/data/audio_file_repository_impl.dart)

**Class Structure** (Lines 15-133):
```dart
@LazySingleton()
class FirebaseAudioService {
  final FirebaseStorage _storage;
  final http.Client _httpClient;

  FirebaseAudioService(
    this._storage, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  // Methods:
  Future<Either<Failure, String>> uploadAudioFile({...})
  Future<Either<Failure, String>> downloadAudioFile({...})
  Future<Either<Failure, Unit>> deleteAudioFile({...})
  Future<Either<Failure, bool>> fileExists({...})
  void dispose()
}
```

**Backward Compatibility Alias** (Lines 135-138):
```dart
@Deprecated('Use FirebaseAudioService instead')
typedef FirebaseAudioUploadService = FirebaseAudioService;
```

**Key Characteristics**:
- Storage-path agnostic (consumers provide complete paths)
- Uses `http.Client.get()` for downloads (not Firebase SDK)
- Returns `Either<Failure, T>` for functional error handling
- Registered as `@LazySingleton()` for dependency injection
- **No progress tracking** (removed in current implementation)

#### Missing Domain Contract

**Location**: [lib/core/audio/domain/audio_file_repository.dart](lib/core/audio/domain/audio_file_repository.dart)

**Status**: **EMPTY FILE** (1 line, no content)

**Expected Content**: Should contain an abstract repository interface like:
```dart
abstract class AudioFileRepository {
  Future<Either<Failure, String>> uploadAudioFile({...});
  Future<Either<Failure, String>> downloadAudioFile({...});
  Future<Either<Failure, Unit>> deleteAudioFile({...});
  Future<Either<Failure, bool>> fileExists({...});
}
```

**Architecture Violation**: The implementation exists without a domain contract, violating Clean Architecture's dependency inversion principle.

---

### 3. Local Directory Management - Duplicate Patterns

The codebase has **10+ instances** of similar `_getCacheDirectory()` implementations across multiple layers.

#### Pattern 1: Repository Implementation

**Location**: [audio_storage_repository_impl.dart:96-105](lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart#L96-L105)

```dart
Future<Directory> _getCacheDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final cacheDir = Directory('${appDir.path}/trackflow/audio');

  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return cacheDir;
}
```

**Used in**:
- `storeAudio()` method (line 30)
- `_getCachedAudioPathFromFileSystem()` method (line 198)

#### Pattern 2: Data Source Implementation

**Location**: [cache_storage_local_data_source.dart:328-338](lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart#L328-L338)

```dart
Future<Directory> _getCacheDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  // Store persistent audio files under Documents/trackflow/audio
  final cacheDir = Directory('${appDir.path}/trackflow/audio');

  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return cacheDir;
}
```

**Used in**:
- `deleteAudioFile()` method (line 228)
- `getFilePathFromCacheKey()` method (line 265)

#### Pattern 3: Model-Level Function

**Location**: [cached_audio_document_unified.dart:199-209](lib/features/audio_cache/data/models/cached_audio_document_unified.dart#L199-L209)

```dart
/// Get the cache directory for relative path resolution
Future<Directory> _getCacheDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final cacheDir = Directory('${appDir.path}/trackflow/audio');

  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return cacheDir;
}
```

**Used by**:
- `getAbsolutePath()` method (converts relative to absolute paths)
- `validateFileExists()` method (validates cached files)

#### Pattern 4: Service with Constant

**Location**: [cache_maintenance_service_impl.dart:14-16, 439-455](lib/features/cache_management/data/services/cache_maintenance_service_impl.dart#L439-L455)

```dart
static const String _cacheRootPath = 'trackflow/audio';

@override
Future<Either<CacheFailure, Directory>> getCacheDirectory() async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheRootPath');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return Right(cacheDir);
  } catch (e) {
    return Left(
      StorageCacheFailure(
        message: 'Failed to get cache directory: $e',
        type: StorageFailureType.diskError,
      ),
    );
  }
}
```

#### Pattern 5: Use Case with Temp Directory

**Location**: [start_recording_usecase.dart:33-37](lib/features/audio_recording/domain/usecases/start_recording_usecase.dart#L33-L37)

```dart
Future<String> _generateOutputPath() async {
  final tempDir = await getTemporaryDirectory();
  final fileName = FileSystemUtils.generateUniqueFilename('.m4a');
  return '${tempDir.path}/$fileName';
}
```

#### Pattern 6: Utility Class

**Location**: [image_utils.dart:9-29](lib/core/utils/image_utils.dart#L9-L29)

```dart
class ImageUtils {
  static const String _localAvatarsDir = 'local_avatars';

  static Future<String?> saveLocalImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/$_localAvatarsDir');

      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }
      // ... file operations
    }
  }
}
```

#### Common Path Structures

1. **Audio Cache**: `Documents/trackflow/audio/{trackId}/{versionId}.ext`
2. **Local Avatars**: `Documents/local_avatars/avatar_{timestamp}.ext`
3. **Temporary Files**: `SystemTemp/temp_{identifier}.ext`
4. **Waveforms**: `SystemTemp/waveforms/temp_{timestamp}.wave`
5. **Recordings**: `SystemTemp/recording_{timestamp}_{uuid}.ext`

**Observation**: All implementations follow the same pattern but are duplicated across 6+ files, violating DRY (Don't Repeat Yourself) principle.

---

### 4. Audio Upload Architecture

#### Current Upload Flow (Offline-First with Background Sync)

```
1. User Action (Use Case)
   ↓
2. Create Local Entity (Repository)
   → Cache locally in Isar
   → Cache audio file in local storage
   ↓
3. Queue Sync Operation (Repository)
   → Add to PendingOperationsManager
   → High priority for uploads
   ↓
4. Trigger Background Sync (Repository)
   → BackgroundSyncCoordinator.pushUpstream()
   ↓
5. Execute Upload (Operation Executor)
   → Read from queue
   → Upload to Firebase Storage
   → Update Firestore metadata
   → Mark operation complete
```

#### Upload Implementations

**1. Track Version Upload**

**Location**: [track_version_remote_datasource.dart:42-77](lib/features/track_version/data/datasources/track_version_remote_datasource.dart#L42-L77)

**Storage Path**: `track_versions/{trackId}/{versionId}.{ext}`

```dart
@override
Future<Either<Failure, TrackVersionDTO>> createTrackVersion(
  TrackVersionDTO versionData,
  File audioFile,
) async {
  // 1. Generate filename with extension
  final fileExtension = AudioFormatUtils.getFileExtension(audioFile.path);
  final fileName = '${versionData.id}$fileExtension';
  final storagePath = 'track_versions/${versionData.trackId}/$fileName';

  // 2. Upload file to Firebase Storage
  final uploadResult = await _uploadService.uploadAudioFile(
    audioFile: audioFile,
    storagePath: storagePath,
    metadata: {
      'trackId': versionData.trackId,
      'versionNumber': versionData.versionNumber.toString(),
      'createdBy': versionData.createdBy,
    },
  );

  // 3. Update DTO with download URL
  final downloadUrl = uploadResult.fold(...);
  final updatedVersionDTO = TrackVersionDTO(..., fileRemoteUrl: downloadUrl);

  // 4. Save metadata to Firestore
  await _firestore.collection(...).doc(...).set(data);

  return Right(updatedVersionDTO);
}
```

**Called by**: [audio_track_operation_executor.dart:95](lib/core/sync/domain/executors/audio_track_operation_executor.dart#L95)

**2. Audio Comment Upload**

**Location**: [audio_comment_storage_coordinator.dart:32-60](lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart#L32-L60)

**Storage Path**: `audio_comments/{projectId}/{versionId}/{commentId}.m4a`

```dart
Future<Either<Failure, String>> uploadCommentAudio({
  required String localPath,
  required ProjectId projectId,
  required TrackVersionId versionId,
  required AudioCommentId commentId,
}) async {
  final file = File(localPath);
  if (!await file.exists()) {
    return Left(StorageFailure('Audio file not found at: $localPath'));
  }

  final storagePath = _buildStoragePath(projectId, versionId, commentId);

  final metadata = {
    'projectId': projectId.value,
    'versionId': versionId.value,
    'commentId': commentId.value,
    'type': 'audio_comment',
  };

  return await _uploadService.uploadAudioFile(
    audioFile: file,
    storagePath: storagePath,
    metadata: metadata,
  );
}
```

**Called by**: [audio_comment_operation_executor.dart:63](lib/core/sync/domain/executors/audio_comment_operation_executor.dart#L63)

#### Firebase Storage Rules

**Location**: [storage.rules](storage.rules)

```javascript
// Audio tracks - 50MB limit
match /audio_tracks/{trackFile} {
  allow write: if request.auth != null
               && isValidAudioFile(trackFile)
               && request.resource.size < 50 * 1024 * 1024;
  allow read: if request.auth != null;
  allow delete: if request.auth != null;
}

// Audio comments - 10MB limit
match /audio_comments/{projectId}/{versionId}/{commentFile} {
  allow write: if request.auth != null
               && isValidAudioFile(commentFile)
               && request.resource.size < 10 * 1024 * 1024;
  allow read: if request.auth != null;
  allow delete: if request.auth != null;
}

function isValidAudioFile(filename) {
  return filename.matches('.*\\.(mp3|wav|m4a|aac|ogg|flac)$');
}
```

---

### 5. Audio Download & Caching Architecture

#### Cache System Components

**Domain Layer**:
- [AudioDownloadRepository](lib/features/audio_cache/domain/repositories/audio_download_repository.dart) - Download contract
- [AudioStorageRepository](lib/features/audio_cache/domain/repositories/audio_storage_repository.dart) - Storage contract

**Data Layer**:
- [CacheStorageRemoteDataSource](lib/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart) - HTTP downloads
- [CacheStorageLocalDataSource](lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart) - Isar DB operations
- [AudioDownloadRepositoryImpl](lib/features/audio_cache/data/repositories/audio_download_repository_impl.dart) - Download orchestration
- [AudioStorageRepositoryImpl](lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart) - Local storage

**Infrastructure Layer**:
- [AudioSourceResolverImpl](lib/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart) - Cache-first resolution

#### HTTP-Based Download Implementation

**Location**: [cache_storage_remote_data_source.dart:32-148](lib/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart#L32-L148)

```dart
@override
Future<Either<CacheFailure, File>> downloadAudio({
  required String audioUrl,
  required String localFilePath,
  required Function(DownloadProgress) onProgress,
}) async {
  // 1. Validate URL
  final uri = Uri.tryParse(audioUrl);

  // 2. Create HTTP client
  final client = http.Client();

  // 3. Stream download with progress tracking
  final request = http.Request('GET', uri);
  final response = await client.send(request);

  final totalBytes = response.contentLength ?? 0;
  int downloadedBytes = 0;

  // 4. Listen to response stream
  response.stream.listen(
    (List<int> chunk) {
      downloadedBytes += chunk.length;
      sink.add(chunk);

      // Report progress
      final progress = DownloadProgress(
        trackId: downloadId,
        state: DownloadState.downloading,
        downloadedBytes: downloadedBytes,
        totalBytes: totalBytes,
      );
      onProgress(progress);
    },
    onDone: () => downloadCompleter.complete(),
    onError: (error) => downloadCompleter.completeError(error),
  );

  // 5. Auto-detect file extension from Content-Type
  final contentType = response.headers['content-type'] ?? '';
  final detectedExt = AudioFormatUtils.getExtensionFromMimeType(contentType);

  return Right(targetFile);
}
```

**Key Features**:
- HTTP streaming with chunked downloads
- Real-time progress tracking via callback
- Auto-detects file extension from Content-Type header
- Validates downloaded file size

#### Offline-First Audio Resolution

**Location**: [audio_source_resolver_impl.dart:24-52](lib/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart#L24-L52)

```dart
@override
Future<Either<Failure, String>> resolveAudioSource(
  String originalUrl, {
  String? trackId,
}) async {
  final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(originalUrl);

  // 1. Always check cache first (offline-first principle)
  final cacheResult = await validateCachedTrack(originalUrl, trackId: effectiveTrackId);
  if (cacheResult.isRight()) {
    final cachedPath = cacheResult.getOrElse(() => null);
    if (cachedPath != null) {
      return Right(cachedPath);
    }
  }

  // 2. Start background caching for future use
  await startBackgroundCaching(originalUrl, trackId: effectiveTrackId);

  // 3. Return original URL for streaming
  return Right(originalUrl);
}
```

**Strategy**:
1. Check local cache first
2. If cached, return local file path
3. If not cached, start background download
4. Return streaming URL immediately (don't block playback)

#### Storage Structure

**Directory Hierarchy**:
```
Application Documents/
└── trackflow/
    └── audio/
        ├── {trackId}/
        │   ├── {versionId}.mp3
        │   ├── {versionId}.m4a
        │   └── ...
        └── {anotherTrackId}/
            └── {versionId}.wav
```

**Isar Database Document** ([cached_audio_document_unified.dart:10-196](lib/features/audio_cache/data/models/cached_audio_document_unified.dart#L10-L196)):

```dart
@collection
class CachedAudioDocumentUnified {
  Id get isarId => fastHash('$trackId|$versionId');

  @Index(unique: true, composite: [CompositeIndex('versionId')])
  late String trackId;
  late String versionId;

  // File information
  late String relativePath;  // Relative to cache directory
  late int fileSizeBytes;
  late DateTime cachedAt;
  late String checksum;      // SHA1 checksum

  @Enumerated(EnumType.name)
  late AudioQuality quality;

  // Management metadata
  @Enumerated(EnumType.name)
  late CacheStatus status;

  late DateTime lastAccessed;
  late int downloadAttempts;
  DateTime? lastDownloadAttempt;
  String? failureReason;
  String? originalUrl;
}
```

**Key Features**:
- Composite unique key: `trackId + versionId`
- Stores relative paths for portability
- SHA1 checksum for file integrity validation
- Download retry metadata
- Last accessed tracking for cleanup

---

### 6. Dependency Injection Configuration

#### Audio Services Registered (injection.config.dart)

**Core Audio Services**:
1. `AudioMetadataService` (line 522-523) - Lazy Singleton
2. `AudioPlaybackService` (line 524-525) - Lazy Singleton
3. `AudioTrackConflictResolutionService` (line 526-527) - Lazy Singleton
4. `AudioPlayerService` (line 1231-1244) - Factory with 14 dependencies

**Cache & Storage Services**:
5. `AudioDownloadRepository` (line 801-805) - Lazy Singleton
6. `AudioStorageRepository` (line 806-808) - Lazy Singleton

**Track Services**:
7. `AudioTrackRepository` (line 1005-1010) - Lazy Singleton
8. `AudioTrackIncrementalSyncService` (line 706-707) - Lazy Singleton
9. `AudioTrackOperationExecutor` (line 809-813) - Factory

**Comment Services**:
10. `AudioCommentRepository` (line 1219-1228) - Lazy Singleton with 7 dependencies
11. `AudioCommentStorageCoordinator` (line 996-1000) - Factory (depends on deleted service)
12. `AudioCommentIncrementalSyncService` (line 712-713) - Lazy Singleton

**Resolvers**:
13. `AudioSourceResolver` (line 1001-1004) - Factory

#### Broken Service Registration

**FirebaseAudioUploadService** (line 694-695):
```dart
gh.lazySingleton<_i84.FirebaseAudioUploadService>(
    () => _i84.FirebaseAudioUploadService(gh<_i16.FirebaseStorage>()));
```

**Status**: Registration exists but source file deleted, blocking code generation.

**Missing Service**: `FirebaseAudioService` is not registered because `build_runner` cannot generate config due to broken imports.

---

### 7. Overlapping Responsibilities

#### System Comparison

| Feature | CacheStorageRemoteDataSource | FirebaseAudioService |
|---------|------------------------------|----------------------|
| **Location** | `lib/features/audio_cache/data/` | `lib/core/audio/data/` |
| **Purpose** | Download audio for caching | General audio operations |
| **Upload** | ❌ No | ✅ Yes |
| **Download** | ✅ HTTP streaming | ✅ HTTP simple |
| **Delete** | ❌ No | ✅ Yes |
| **Progress** | ✅ Yes (callback) | ❌ No (removed) |
| **File Exists** | ❌ No | ✅ Yes |
| **Storage Path** | Managed internally | Consumer provides |
| **Used By** | AudioDownloadRepository | TrackVersion, AudioComment (intended) |

**Observation**: Both systems handle audio downloads but serve different purposes:
- `CacheStorageRemoteDataSource`: Feature-specific, download-only, with progress tracking
- `FirebaseAudioService`: General-purpose, full CRUD, no progress tracking

---

## Code References

### Core Audio Files (New System)
- [lib/core/audio/domain/audio_file_repository.dart](lib/core/audio/domain/audio_file_repository.dart) - Empty domain contract
- [lib/core/audio/data/audio_file_repository_impl.dart](lib/core/audio/data/audio_file_repository_impl.dart) - `FirebaseAudioService` implementation

### Cache Feature (Active System)
- [lib/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart](lib/features/audio_cache/data/datasources/cache_storage_remote_data_source.dart) - HTTP download implementation
- [lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart](lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart) - Isar operations
- [lib/features/audio_cache/domain/repositories/audio_download_repository.dart](lib/features/audio_cache/domain/repositories/audio_download_repository.dart) - Download contract
- [lib/features/audio_cache/data/repositories/audio_download_repository_impl.dart](lib/features/audio_cache/data/repositories/audio_download_repository_impl.dart) - Download orchestration
- [lib/features/audio_cache/domain/repositories/audio_storage_repository.dart](lib/features/audio_cache/domain/repositories/audio_storage_repository.dart) - Storage contract
- [lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart](lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart) - Local storage implementation

### Broken References (Needs Migration)
- [lib/features/track_version/data/datasources/track_version_remote_datasource.dart:8](lib/features/track_version/data/datasources/track_version_remote_datasource.dart#L8) - Broken import
- [lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart:6](lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart#L6) - Broken import
- [lib/core/di/injection.config.dart:77](lib/core/di/injection.config.dart#L77) - Broken import (generated)

### Directory Management Examples
- [lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart:96-105](lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart#L96-L105) - Repository pattern
- [lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart:328-338](lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart#L328-L338) - Datasource pattern
- [lib/features/audio_cache/data/models/cached_audio_document_unified.dart:199-209](lib/features/audio_cache/data/models/cached_audio_document_unified.dart#L199-L209) - Model-level pattern
- [lib/features/cache_management/data/services/cache_maintenance_service_impl.dart:439-455](lib/features/cache_management/data/services/cache_maintenance_service_impl.dart#L439-L455) - Service pattern with constant

### Infrastructure
- [lib/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart](lib/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart) - Offline-first resolution
- [lib/core/utils/audio_format_utils.dart](lib/core/utils/audio_format_utils.dart) - Format utilities
- [lib/core/utils/file_system_utils.dart](lib/core/utils/file_system_utils.dart) - File operations

### Dependency Injection
- [lib/core/di/injection.dart](lib/core/di/injection.dart) - DI configuration entry point
- [lib/core/di/injection.config.dart](lib/core/di/injection.config.dart) - Generated DI config (25,371+ tokens)

### Configuration
- [storage.rules](storage.rules) - Firebase Storage security rules

---

## Architecture Documentation

### Current Clean Architecture Layers

**Domain Layer** (Business Logic):
- Entities: `CachedAudio`, `DownloadProgress`, `CacheMetadata`
- Value Objects: `AudioTrackId`, `TrackVersionId`, `AudioCommentId`
- Repository Contracts: `AudioDownloadRepository`, `AudioStorageRepository`
- Use Cases: `CacheTrackUseCase`, `GetCachedTrackPathUseCase`, `RemoveTrackCacheUseCase`

**Data Layer** (Implementation):
- Remote Data Sources: `CacheStorageRemoteDataSource`, `TrackVersionRemoteDataSource`
- Local Data Sources: `CacheStorageLocalDataSource`
- Repository Implementations: `AudioDownloadRepositoryImpl`, `AudioStorageRepositoryImpl`
- Models: `CachedAudioDocumentUnified` (Isar), `TrackVersionDTO` (Firestore)

**Infrastructure Layer** (Frameworks):
- `AudioSourceResolverImpl`: Resolves audio sources with cache-first strategy
- `FirebaseAudioService`: Firebase Storage operations

**Presentation Layer** (UI):
- BLoC: `TrackCacheBloc`
- Widgets: `CacheStatusIndicator`, `SmartTrackCacheIcon`

### Sync Architecture

**Components**:
1. `PendingOperationsManager`: Queues operations in Isar
2. `BackgroundSyncCoordinator`: Orchestrates upstream sync
3. Operation Executors:
   - `AudioTrackOperationExecutor`
   - `TrackVersionOperationExecutor`
   - `AudioCommentOperationExecutor`

**Flow**:
```
Repository → Queue Operation → Trigger Sync → Execute Upload → Update Remote
```

### Storage Path Conventions

**Firebase Storage Paths**:
- Track Versions: `track_versions/{trackId}/{versionId}.{ext}`
- Audio Comments: `audio_comments/{projectId}/{versionId}/{commentId}.m4a`
- Waveforms: `waveforms/{trackId}/{versionId}.json`
- Avatars: `avatars/{userId}/{fileName}`

**Local Storage Paths**:
- Audio Cache: `Documents/trackflow/audio/{trackId}/{versionId}.{ext}`
- Temp Files: `SystemTemp/temp_{identifier}.{ext}`
- Avatars: `Documents/local_avatars/avatar_{timestamp}.{ext}`

---

## Validation of Concerns

### 1. Code Duplication - ✅ CONFIRMED

**Evidence**:
- `_getCacheDirectory()` duplicated across 6+ files
- Similar HTTP download logic in multiple locations
- Path construction patterns repeated

**Examples**:
- [audio_storage_repository_impl.dart:96-105](lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart#L96-L105)
- [cache_storage_local_data_source.dart:328-338](lib/features/audio_cache/data/datasources/cache_storage_local_data_source.dart#L328-L338)
- [cached_audio_document_unified.dart:199-209](lib/features/audio_cache/data/models/cached_audio_document_unified.dart#L199-L209)

### 2. Tight Coupling - ✅ CONFIRMED

**Evidence**:
- Direct Firebase Storage usage in multiple data sources
- Features directly depend on `FirebaseAudioUploadService` (now broken)
- No abstraction layer for cloud operations in some areas

**Examples**:
- `TrackVersionRemoteDataSource` directly uses upload service
- `AudioCommentStorageCoordinator` directly uses upload service
- `UserProfileRemoteDataSource` directly uses `FirebaseStorage.ref()`

### 3. Lack of Centralized Contract - ✅ CONFIRMED

**Evidence**:
- Domain contract file is empty ([audio_file_repository.dart](lib/core/audio/domain/audio_file_repository.dart))
- `FirebaseAudioService` is a concrete implementation without interface
- Different features use different patterns for same operations

### 4. Improper Directory Handling - ✅ CONFIRMED

**Evidence**:
- Repositories manage filesystem paths directly
- Data sources construct directory paths
- Models have directory path logic
- No centralized directory service exists

**All instances documented in section "Local Directory Management"**

### 5. Incomplete Refactor - ✅ CONFIRMED

**Evidence**:
- New `FirebaseAudioService` exists but isn't fully integrated
- Old `FirebaseAudioUploadService` deleted but still imported
- Code generation blocked by broken imports
- Migration halfway complete

---

## Open Questions

1. **Should `FirebaseAudioService` handle progress tracking?**
   - Current implementation removed progress tracking
   - `CacheStorageRemoteDataSource` has it
   - Use case: UI feedback during large file uploads

2. **Should download operations be centralized?**
   - Current: Split between `FirebaseAudioService` and `CacheStorageRemoteDataSource`
   - Both use HTTP downloads but different strategies
   - Potential overlap in responsibility

3. **What should the domain contract look like?**
   - Interface vs abstract class?
   - Should it include progress callbacks?
   - How to handle optional metadata?

4. **Where should `LocalDirectoryService` live?**
   - Core infrastructure (`lib/core/infrastructure/`)?
   - Core services (`lib/core/services/`)?
   - Shared utilities (`lib/core/utils/`)?

5. **Should audio comments use the same cache structure as tracks?**
   - Current: Uses projectId as trackId
   - Alternative: Separate directory hierarchy
   - Impact on cache management and cleanup

---

## Related Documentation

- [thoughts/thoughts_audio_storage.md](thoughts/thoughts_audio_storage.md) - Original concerns and proposal
- [documentation/datasources.md](documentation/datasources.md) - Data sources documentation
- [documentation/repositories.md](documentation/repositories.md) - Repositories documentation
- [thoughts/plans/record_comment_plan.md](thoughts/plans/record_comment_plan.md) - Audio comment recording plan

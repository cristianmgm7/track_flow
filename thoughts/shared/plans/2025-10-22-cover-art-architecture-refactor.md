# Cover Art Architecture Refactor and Track Cover Art Implementation

## Overview

This plan refactors the existing project cover art implementation to follow clean architecture principles and implements comprehensive track cover art support. The refactor addresses architectural inconsistencies, adds offline-first support with local caching, and creates a centralized image storage service following the pattern established by `AudioFileRepository`.

## Current State Analysis

### Existing Project Cover Art Implementation
- ✅ UI component exists: `ProjectCoverArt` widget with `CachedNetworkImage`
- ✅ Domain entity has `coverUrl` field
- ✅ Upload use case exists but needs refactor
- ✅ Data flows through all layers (DTO, Isar, Firestore)
- ❌ **Business logic in repository** - `uploadCoverArt()` method orchestrates file upload (line 238 of `projects_repository_impl.dart`)
- ❌ **Direct Firebase Storage instantiation** in repository
- ❌ **No offline-first caching** - missing `coverLocalPath` field
- ❌ **Hardcoded JPG format** - no WebP compression
- ❌ **No image compression** before upload

### Track Cover Art Status
- ✅ `AudioTrack.url` field exists (documented as "Cover art URL" at line 6 of `audio_track.dart`)
- ✅ UI component exists: `TrackCoverArt` widget ready for images
- ✅ Field flows through all data layers
- ❌ **No upload implementation** - missing use case, repository method, datasource logic
- ❌ **No UI for upload** - missing form and action sheet
- ❌ **No offline support** - missing `coverLocalPath` field
- ❌ **Field name unclear** - `url` should be renamed to `coverUrl` for clarity

### User Avatar Pattern (Reference Implementation)
- ✅ Dual fields: `avatarUrl` (remote) + `avatarLocalPath` (local cache)
- ✅ Offline-first: Uses `ImageUtils.saveLocalImage()` to cache before upload
- ✅ Firebase Storage injected in datasource
- ✅ Path pattern: `avatars/{userId}/avatar_{timestamp}.{ext}`
- ❌ No image compression before upload

## Desired End State

### Architecture
- Centralized `ImageStorageRepository` in `lib/core/storage/` for all image operations
- **Use cases orchestrate business logic**: `UploadProjectCoverArtUseCase` and `UploadTrackCoverArtUseCase` coordinate the workflow
- **Repositories handle data only**: Simple `updateProject()` and `updateTrack()` calls
- Consistent dependency injection of Firebase Storage
- WebP format with 80-85% quality compression for all cover art
- Offline-first pattern with dual URL fields (remote + local)
- Fallback behavior: track → project cover art when track has none

### Storage Structure
```
Firebase Storage:
├── cover_art_projects/
│   └── {projectId}/
│       └── cover_{timestamp}.webp
└── cover_art_tracks/
    └── {trackId}/
        └── cover_{timestamp}.webp

Local Storage:
├── /Documents/trackflow/cover_art/
│   ├── projects/
│   │   └── {projectId}_cover_{timestamp}.webp
│   └── tracks/
│       └── {trackId}_cover_{timestamp}.webp
```

### Verification
After implementation:
- ✅ `flutter analyze` passes with no warnings
- ✅ Projects can upload cover art with automatic WebP compression
- ✅ Tracks can upload unique cover art or inherit from project
- ✅ Cover art displays offline from local cache
- ✅ Existing projects with remote cover URLs backfill local cache on app launch
- ✅ All Firebase Storage access goes through dependency injection
- ✅ Unit tests pass for all new use cases and repositories

## What We're NOT Doing

- AI-generated cover art or automatic art suggestions
- Bulk cover art operations or batch uploads
- Cover art editing/cropping within the app (user must crop externally)
- Video thumbnails or animated cover art
- Social sharing of cover art separately from tracks/projects
- Cover art versioning or history tracking
- Custom storage backends (only Firebase Storage supported)

## Implementation Approach

Follow offline-first, dependency injection, and clean architecture patterns established in the codebase. Use the `AudioFileRepository` pattern as a reference for the new `ImageStorageRepository`. Implement dual-field pattern (remote URL + local path) for offline support, matching the user avatar implementation.

---

## Phase 1: Core Image Storage Infrastructure

### Overview
Create centralized image storage abstraction layer in `core/storage/` with WebP compression, progress tracking, and offline caching support.

### Changes Required

#### 1. Add flutter_image_compress Dependency
**File**: `pubspec.yaml`
**Changes**: Add image compression package

```yaml
dependencies:
  # ... existing dependencies ...
  flutter_image_compress: ^2.3.0
```

**Run**: `flutter pub get`

#### 2. Create ImageStorageRepository Interface
**File**: `lib/core/storage/domain/image_storage_repository.dart`
**Changes**: New file - Define repository contract

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

abstract class ImageStorageRepository {
  /// Upload image to Firebase Storage with WebP compression
  ///
  /// [imageFile] - Original image file (any format)
  /// [storagePath] - Firebase Storage path (e.g., 'cover_art_projects/123/cover.webp')
  /// [metadata] - Custom metadata to attach to uploaded file
  /// [quality] - WebP compression quality (1-100, default 85)
  ///
  /// Returns download URL on success
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String storagePath,
    Map<String, String>? metadata,
    int quality = 85,
  });

  /// Download image from Firebase Storage URL to local path
  /// Checks cache first, downloads if needed
  ///
  /// [storageUrl] - Firebase Storage download URL
  /// [localPath] - Destination path for downloaded file
  /// [entityId] - Track/Project ID for cache lookup
  /// [entityType] - 'project' or 'track' for cache organization
  ///
  /// Returns absolute path to local file
  Future<Either<Failure, String>> downloadImage({
    required String storageUrl,
    required String localPath,
    String? entityId,
    String? entityType,
  });

  /// Check if image is cached locally
  ///
  /// [entityId] - Track or Project ID
  /// [entityType] - 'project' or 'track'
  ///
  /// Returns true if cached and file exists
  Future<Either<Failure, bool>> isImageCached({
    required String entityId,
    required String entityType,
  });

  /// Get cached image path if available
  ///
  /// [entityId] - Track or Project ID
  /// [entityType] - 'project' or 'track'
  ///
  /// Returns absolute path or null if not cached
  Future<Either<Failure, String?>> getCachedImagePath({
    required String entityId,
    required String entityType,
  });

  /// Delete image from Firebase Storage
  ///
  /// [storageUrl] - Firebase Storage download URL to delete
  Future<Either<Failure, Unit>> deleteImage({
    required String storageUrl,
  });

  /// Clear cached image for entity
  ///
  /// [entityId] - Track or Project ID
  /// [entityType] - 'project' or 'track'
  Future<Either<Failure, Unit>> clearCache({
    required String entityId,
    required String entityType,
  });
}
```

#### 3. Create ImageCompressionService
**File**: `lib/core/storage/services/image_compression_service.dart`
**Changes**: New file - Handle WebP compression

```dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class ImageCompressionService {
  /// Compress image to WebP format with quality control
  ///
  /// [sourceFile] - Original image file
  /// [quality] - Compression quality 1-100 (default 85)
  ///
  /// Returns compressed WebP file
  Future<File?> compressToWebP({
    required File sourceFile,
    int quality = 85,
  }) async {
    try {
      final sourceExtension = path.extension(sourceFile.path).toLowerCase();

      // Skip compression if already WebP and small enough
      if (sourceExtension == '.webp') {
        final fileSize = await sourceFile.length();
        if (fileSize < 500000) { // 500KB threshold
          AppLogger.info(
            'Image already WebP and under 500KB, skipping compression',
            tag: 'IMAGE_COMPRESSION',
          );
          return sourceFile;
        }
      }

      final targetPath = sourceFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_compressed.webp',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.webp,
      );

      if (result == null) {
        AppLogger.warning(
          'Image compression returned null',
          tag: 'IMAGE_COMPRESSION',
        );
        return null;
      }

      final compressedFile = File(result.path);
      final originalSize = await sourceFile.length();
      final compressedSize = await compressedFile.length();
      final savedPercentage = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);

      AppLogger.info(
        'Image compressed: ${originalSize} → ${compressedSize} bytes (saved ${savedPercentage}%)',
        tag: 'IMAGE_COMPRESSION',
      );

      return compressedFile;
    } catch (e) {
      AppLogger.error(
        'Image compression failed: $e',
        tag: 'IMAGE_COMPRESSION',
        error: e,
      );
      return null;
    }
  }

  /// Get recommended quality level based on original file size
  int getRecommendedQuality(int fileSizeBytes) {
    if (fileSizeBytes > 5000000) return 80; // >5MB: aggressive compression
    if (fileSizeBytes > 2000000) return 85; // 2-5MB: balanced
    return 90; // <2MB: preserve quality
  }
}
```

#### 4. Add Directory Types for Cover Art
**File**: `lib/core/infrastructure/domain/directory_service.dart`
**Changes**: Add new directory types after line 21

```dart
  /// Project cover art: /Documents/trackflow/cover_art/projects
  projectCovers,

  /// Track cover art: /Documents/trackflow/cover_art/tracks
  trackCovers,
```

#### 5. Implement Directory Paths
**File**: `lib/core/infrastructure/services/directory_service_impl.dart`
**Changes**: Add cases in switch statement after line 45

```dart
        case DirectoryType.projectCovers:
          final appDir = await getApplicationDocumentsDirectory();
          basePath = '${appDir.path}/trackflow/cover_art/projects';
          break;
        case DirectoryType.trackCovers:
          final appDir = await getApplicationDocumentsDirectory();
          basePath = '${appDir.path}/trackflow/cover_art/tracks';
          break;
```

#### 6. Create ImageStorageRepository Implementation
**File**: `lib/core/storage/data/image_storage_repository_impl.dart`
**Changes**: New file - Implement repository with Firebase Storage

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/core/storage/services/image_compression_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: ImageStorageRepository)
class ImageStorageRepositoryImpl implements ImageStorageRepository {
  final FirebaseStorage _storage;
  final DirectoryService _directoryService;
  final ImageCompressionService _compressionService;

  ImageStorageRepositoryImpl(
    this._storage,
    this._directoryService,
    this._compressionService,
  );

  @override
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String storagePath,
    Map<String, String>? metadata,
    int quality = 85,
  }) async {
    try {
      // Compress to WebP
      final compressedFile = await _compressionService.compressToWebP(
        sourceFile: imageFile,
        quality: quality,
      );

      if (compressedFile == null) {
        return Left(StorageFailure('Image compression failed'));
      }

      // Create Firebase Storage reference
      final ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: metadata,
        ),
      );

      // Execute upload
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Clean up compressed file if it's different from source
      if (compressedFile.path != imageFile.path) {
        try {
          await compressedFile.delete();
        } catch (e) {
          AppLogger.warning('Failed to delete compressed temp file: $e');
        }
      }

      AppLogger.info(
        'Image uploaded successfully: $storagePath',
        tag: 'IMAGE_STORAGE',
      );

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ServerFailure('Upload failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadImage({
    required String storageUrl,
    required String localPath,
    String? entityId,
    String? entityType,
  }) async {
    try {
      // Check cache first if entity info provided
      if (entityId != null && entityType != null) {
        final cachedPathResult = await getCachedImagePath(
          entityId: entityId,
          entityType: entityType,
        );

        final cachedPath = cachedPathResult.fold(
          (_) => null,
          (path) => path,
        );

        if (cachedPath != null) {
          final cachedFile = File(cachedPath);
          if (await cachedFile.exists()) {
            AppLogger.info('Image found in cache: $cachedPath');
            return Right(cachedPath);
          }
        }
      }

      // Not cached, download from Firebase Storage
      final file = File(localPath);
      await file.parent.create(recursive: true);

      final ref = _storage.refFromURL(storageUrl);
      await ref.writeToFile(file);

      if (!await file.exists()) {
        return Left(StorageFailure('Download completed but file not found'));
      }

      AppLogger.info('Image downloaded: $localPath', tag: 'IMAGE_STORAGE');
      return Right(localPath);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Download failed'));
    } catch (e) {
      return Left(ServerFailure('Download failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isImageCached({
    required String entityId,
    required String entityType,
  }) async {
    try {
      final pathResult = await getCachedImagePath(
        entityId: entityId,
        entityType: entityType,
      );

      return pathResult.fold(
        (_) => Right(false),
        (cachedPath) async {
          if (cachedPath == null) return Right(false);
          final file = File(cachedPath);
          return Right(await file.exists());
        },
      );
    } catch (e) {
      return Right(false); // Treat errors as not cached
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedImagePath({
    required String entityId,
    required String entityType,
  }) async {
    try {
      final directoryType = entityType == 'project'
          ? DirectoryType.projectCovers
          : DirectoryType.trackCovers;

      final dirResult = await _directoryService.getDirectory(directoryType);

      return dirResult.fold(
        (failure) => Left(failure),
        (dir) async {
          // Look for any cover file for this entity
          final files = await dir.list().toList();
          final coverFile = files.whereType<File>().firstWhere(
            (f) => path.basename(f.path).startsWith('${entityId}_cover'),
            orElse: () => File(''),
          );

          if (coverFile.path.isEmpty || !await coverFile.exists()) {
            return Right(null);
          }

          return Right(coverFile.path);
        },
      );
    } catch (e) {
      return Right(null); // Treat errors as not cached
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteImage({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Delete failed'));
    } catch (e) {
      return Left(ServerFailure('Delete failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache({
    required String entityId,
    required String entityType,
  }) async {
    try {
      final pathResult = await getCachedImagePath(
        entityId: entityId,
        entityType: entityType,
      );

      return pathResult.fold(
        (failure) => Left(failure),
        (cachedPath) async {
          if (cachedPath == null) return const Right(unit);

          final file = File(cachedPath);
          if (await file.exists()) {
            await file.delete();
            AppLogger.info('Cleared cached image: $cachedPath');
          }
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(StorageFailure('Failed to clear cache: $e'));
    }
  }
}
```

#### 7. Register in Dependency Injection
**File**: `lib/core/di/app_module.dart`
**Changes**: Already has `FirebaseStorage` registration - verify it exists

The Firebase Storage singleton is already registered at line 39-40. No changes needed.

### Success Criteria

#### Automated Verification:
- [ ] Dependencies install successfully: `flutter pub get`
- [ ] Code generation completes: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] All imports resolve correctly
- [ ] Dependency injection registers successfully (app builds)

#### Manual Verification:
- [ ] `ImageStorageRepository` instance can be injected in test context
- [ ] Image compression reduces file size by >30% for large images
- [ ] WebP files are created with correct MIME type
- [ ] Directory service creates cover art directories on demand

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to Phase 2.

---

## Phase 2: Refactor Project Cover Art (Fix Current Implementation)

### Overview
Refactor existing project cover art to use the new `ImageStorageRepository`, add offline-first support with `coverLocalPath` field, and fix architectural issues.

### Changes Required

#### 1. Add coverLocalPath to Project Entity
**File**: `lib/features/projects/domain/entities/project.dart`
**Changes**: Add field after `coverUrl` at line 25

```dart
  final String? coverUrl; // Remote Firebase Storage URL
  final String? coverLocalPath; // Local cached image path
```

Update constructor at line 36:
```dart
    this.coverUrl,
    this.coverLocalPath,
```

Update `copyWith()` method (add parameter around line 56):
```dart
    String? coverUrl,
    String? coverLocalPath,
```

And in the return statement:
```dart
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
```

#### 2. Update Project DTO
**File**: `lib/features/projects/data/models/project_dto.dart`
**Changes**: Add field at line 24

```dart
  final String? coverUrl;
  final String? coverLocalPath; // Local-only, not serialized to Firestore
```

Update `fromDomain()` at line 68:
```dart
    coverUrl: project.coverUrl,
    coverLocalPath: project.coverLocalPath,
```

Update `toDomain()` at line 96:
```dart
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
```

Update `toMap()` - do NOT serialize `coverLocalPath` (it's local-only):
```dart
    if (coverUrl != null) 'coverUrl': coverUrl,
    // coverLocalPath intentionally excluded from Firestore
```

Update `copyWith()` method (add parameter around line 238):
```dart
    String? coverUrl,
    String? coverLocalPath,
```

#### 3. Update Project Isar Document
**File**: `lib/features/projects/data/models/project_document.dart`
**Changes**: Add field at line 22

```dart
  String? coverUrl;
  String? coverLocalPath;
```

Update `fromDTO()` at line 44:
```dart
      ..coverUrl = dto.coverUrl
      ..coverLocalPath = dto.coverLocalPath
```

Update `toDTO()` at line 92:
```dart
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
```

#### 4. Refactor uploadCoverArt in Repository
**File**: `lib/features/projects/data/repositories/projects_repository_impl.dart`
**Changes**: Replace current implementation (lines 232-263) with new pattern

First, add `ImageStorageRepository` injection in constructor (line 20):
```dart
  final ProjectsLocalDataSource _localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;
  final ImageStorageRepository _imageStorageRepository; // Add this

  ProjectsRepositoryImpl({
    required ProjectsLocalDataSource localDataSource,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
    required ImageStorageRepository imageStorageRepository, // Add this
  }) : _localDataSource = localDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager,
       _imageStorageRepository = imageStorageRepository; // Add this
```

Remove Firebase Storage import at line 4:
```dart
// DELETE: import 'package:firebase_storage/firebase_storage.dart';
```

Replace `uploadCoverArt()` method (lines 232-263):
```dart
  @override
  Future<Either<Failure, String>> uploadCoverArt(
    ProjectId projectId,
    File imageFile,
  ) async {
    try {
      // 1. Get current project
      final projectResult = await getProjectById(projectId);
      if (projectResult.isLeft()) {
        return projectResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
      }

      final project = projectResult.fold((_) => throw StateError('Unreachable'), (p) => p);

      // 2. Cache image locally FIRST (offline-first)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPathResult = await _directoryService.getFilePath(
        DirectoryType.projectCovers,
        '${projectId.value}_cover_$timestamp.webp',
      );

      if (localPathResult.isLeft()) {
        return localPathResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
      }

      final localPath = localPathResult.fold((_) => throw StateError('Unreachable'), (path) => path);

      // Copy to local cache
      final localFile = File(localPath);
      await imageFile.copy(localPath);

      // 3. Update project with local path immediately (offline support)
      final projectWithLocalPath = project.copyWith(coverLocalPath: localPath);
      await updateProject(projectWithLocalPath);

      // 4. Upload to Firebase Storage (use new repository)
      final storagePath = 'cover_art_projects/${projectId.value}/cover_$timestamp.webp';
      final uploadResult = await _imageStorageRepository.uploadImage(
        imageFile: imageFile,
        storagePath: storagePath,
        metadata: {
          'projectId': projectId.value,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
        quality: 85,
      );

      return uploadResult.fold(
        (failure) => Left(failure),
        (downloadUrl) async {
          // 5. Update project with remote URL
          final updatedProject = projectWithLocalPath.copyWith(coverUrl: downloadUrl);
          final updateResult = await updateProject(updatedProject);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => Right(downloadUrl),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to upload cover art: $e'));
    }
  }
```

Add `DirectoryService` injection in constructor:
```dart
  final DirectoryService _directoryService; // Add to fields

  ProjectsRepositoryImpl({
    // ... existing parameters
    required DirectoryService directoryService, // Add this
    required ImageStorageRepository imageStorageRepository,
  }) : // ... existing assignments
       _directoryService = directoryService,
       _imageStorageRepository = imageStorageRepository;
```

#### 5. Update ProjectCoverArt Widget to Support Local Paths
**File**: `lib/features/ui/project/project_cover_art.dart`
**Changes**: Modify `build()` method to check local path first (line 28)

```dart
  @override
  Widget build(BuildContext context) {
    // Check local path first (offline support)
    if (imageUrl != null && imageUrl!.isNotEmpty && !imageUrl!.startsWith('http')) {
      return _buildLocalImageCover();
    }

    // Then check remote URL
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildImageCover();
    }

    // Otherwise, show generated placeholder
    return _buildGeneratedCover();
  }
```

Add new method for local images:
```dart
  Widget _buildLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(),
        ),
      ),
    );
  }
```

Add import at top:
```dart
import 'dart:io';
```

#### 6. Run Code Generation
**Command**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
**Reason**: Regenerate Isar schema for new `coverLocalPath` field

### Success Criteria

#### Automated Verification:
- [ ] Code generation completes successfully
- [ ] No analyzer warnings: `flutter analyze`
- [ ] App builds without errors: `flutter build apk --debug` (or iOS equivalent)
- [ ] Dependency injection resolves `ImageStorageRepository` for `ProjectsRepositoryImpl`

#### Manual Verification:
- [ ] Upload new project cover art → compresses to WebP → saves locally → uploads to Firebase
- [ ] Project cover art displays from local cache when offline
- [ ] Existing projects with `coverUrl` still display (backwards compatible)
- [ ] Generated placeholder shows when no cover art exists

**Implementation Note**: Test offline mode by enabling airplane mode after upload completes. Cover art should still display from local cache.

---

## Phase 3: Implement Track Cover Art (New Feature)

### Overview
Implement complete track cover art functionality: rename `url` field to `coverUrl`, add `coverLocalPath`, create upload use case, add repository method, and build UI components.

### Changes Required

#### 1. Rename and Add Fields to AudioTrack Entity
**File**: `lib/features/audio_track/domain/entities/audio_track.dart`
**Changes**: Rename `url` to `coverUrl` at line 6, add `coverLocalPath`

```dart
  final String coverUrl; // Cover art URL (renamed from 'url')
  final String? coverLocalPath; // Local cached cover art path
```

Update constructor:
```dart
    required this.coverUrl,
    this.coverLocalPath,
```

Update factory method `create()`:
```dart
  factory AudioTrack.create({
    required String name,
    required String coverUrl, // Renamed parameter
    String? coverLocalPath,   // New parameter
    required Duration duration,
    // ... rest of parameters
  }) {
    return AudioTrack(
      id: AudioTrackId(),
      name: name,
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
      // ... rest of fields
    );
  }
```

Update `copyWith()`:
```dart
  AudioTrack copyWith({
    AudioTrackId? id,
    String? name,
    String? coverUrl,        // Renamed parameter
    String? coverLocalPath,  // New parameter
    Duration? duration,
    // ... rest of parameters
  }) {
    return AudioTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      // ... rest of fields
    );
  }
```

#### 2. Update AudioTrack DTO
**File**: `lib/features/audio_track/data/models/audio_track_dto.dart`
**Changes**: Rename field and add local path

At line 9:
```dart
  final String coverUrl; // Renamed from 'url'
  final String? coverLocalPath; // Local-only, not serialized
```

Update constructor:
```dart
  const AudioTrackDTO({
    required this.id,
    required this.name,
    required this.coverUrl,
    this.coverLocalPath,
    // ... rest
  });
```

Update `fromJson()` (line 33):
```dart
    coverUrl: json['url'] as String? ?? '', // Map from 'url' for backwards compatibility
    coverLocalPath: null, // Never from Firestore
```

Update `toJson()` (line 62):
```dart
    'url': coverUrl, // Keep 'url' key for Firestore backwards compatibility
    // coverLocalPath intentionally excluded
```

Update `toDomain()` (line 80):
```dart
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
```

Update `fromDomain()` (line 94):
```dart
      coverUrl: track.coverUrl,
      coverLocalPath: track.coverLocalPath,
```

#### 3. Update AudioTrack Isar Document
**File**: `lib/features/audio_track/data/models/audio_track_document.dart`
**Changes**: Rename field at line 17

```dart
  late String coverUrl; // Renamed from 'url'
  String? coverLocalPath;
```

Update all mappings in `fromDTO()`, `toDTO()`, etc.:
```dart
  // In fromDTO():
  ..coverUrl = dto.coverUrl
  ..coverLocalPath = dto.coverLocalPath

  // In toDTO():
  coverUrl: coverUrl,
  coverLocalPath: coverLocalPath,
```

#### 4. Update AudioTrack Local DataSource
**File**: `lib/features/audio_track/data/datasources/audio_track_local_datasource.dart`
**Changes**: Update method name at line 149

Rename `updateTrackUrl()` to `updateTrackCoverUrl()`:
```dart
  Future<Either<Failure, Unit>> updateTrackCoverUrl(
    String trackId,
    String coverUrl,
    String? coverLocalPath,
  ) async {
    try {
      final isar = await _isarService.db;
      final track = await isar.audioTrackDocuments
          .filter()
          .idEqualTo(trackId)
          .findFirst();

      if (track == null) {
        return Left(DatabaseFailure('Track not found'));
      }

      await isar.writeTxn(() async {
        track.coverUrl = coverUrl;
        track.coverLocalPath = coverLocalPath;
        await isar.audioTrackDocuments.put(track);
      });

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update track cover URL: $e'));
    }
  }
```

#### 5. Create AudioTrack Remote DataSource Method
**File**: `lib/features/audio_track/data/datasources/audio_track_remote_datasource.dart`
**Changes**: Add method to update cover URL in Firestore

Add after `editTrackName()` method (around line 135):
```dart
  /// Update track cover URL in Firestore
  Future<Either<Failure, Unit>> updateTrackCoverUrl(
    String trackId,
    String coverUrl,
  ) async {
    try {
      await _firestore.collection('audio_tracks').doc(trackId).update({
        'url': coverUrl, // Use 'url' field for backwards compatibility
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update track cover URL: $e'));
    }
  }
```

#### 6. Add uploadCoverArt Method to AudioTrackRepository Interface
**File**: `lib/features/audio_track/domain/repositories/audio_track_repository.dart`
**Changes**: Add method signature after line 27

```dart
  /// Upload cover art for track
  /// Returns download URL on success
  Future<Either<Failure, String>> uploadCoverArt(
    AudioTrackId trackId,
    File imageFile,
  );
```

#### 7. Implement uploadCoverArt in AudioTrackRepository
**File**: `lib/features/audio_track/data/repositories/audio_track_repository_impl.dart`
**Changes**: Add method implementation

First, add dependencies in constructor:
```dart
  final ImageStorageRepository _imageStorageRepository;
  final DirectoryService _directoryService;

  AudioTrackRepositoryImpl({
    // ... existing parameters
    required ImageStorageRepository imageStorageRepository,
    required DirectoryService directoryService,
  }) : // ... existing assignments
       _imageStorageRepository = imageStorageRepository,
       _directoryService = directoryService;
```

Add method after `editTrackName()` (around line 210):
```dart
  @override
  Future<Either<Failure, String>> uploadCoverArt(
    AudioTrackId trackId,
    File imageFile,
  ) async {
    try {
      // 1. Get current track
      final trackResult = await _localDataSource.getTrackById(trackId.value);
      if (trackResult.isLeft()) {
        return trackResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
      }

      final trackDoc = trackResult.fold((_) => throw StateError('Unreachable'), (doc) => doc);
      if (trackDoc == null) {
        return Left(DatabaseFailure('Track not found'));
      }

      // 2. Cache image locally FIRST (offline-first)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPathResult = await _directoryService.getFilePath(
        DirectoryType.trackCovers,
        '${trackId.value}_cover_$timestamp.webp',
      );

      if (localPathResult.isLeft()) {
        return localPathResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
      }

      final localPath = localPathResult.fold((_) => throw StateError('Unreachable'), (path) => path);

      // Copy to local cache
      await imageFile.copy(localPath);

      // 3. Update track with local path immediately (offline support)
      await _localDataSource.updateTrackCoverUrl(
        trackId.value,
        trackDoc.coverUrl, // Keep existing remote URL
        localPath,         // Set local path
      );

      // 4. Upload to Firebase Storage
      final storagePath = 'cover_art_tracks/${trackId.value}/cover_$timestamp.webp';
      final uploadResult = await _imageStorageRepository.uploadImage(
        imageFile: imageFile,
        storagePath: storagePath,
        metadata: {
          'trackId': trackId.value,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
        quality: 85,
      );

      return uploadResult.fold(
        (failure) => Left(failure),
        (downloadUrl) async {
          // 5. Update track with remote URL locally
          await _localDataSource.updateTrackCoverUrl(
            trackId.value,
            downloadUrl,
            localPath,
          );

          // 6. Queue remote update via sync system
          final updateData = {
            'url': downloadUrl,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          };

          final queueResult = await _pendingOperationsManager.addUpdateOperation(
            entityType: 'audio_track',
            entityId: trackId.value,
            data: updateData,
            priority: SyncPriority.medium,
          );

          if (queueResult.isLeft()) {
            AppLogger.warning('Failed to queue cover art sync, but local update succeeded');
          } else {
            unawaited(_backgroundSyncCoordinator.pushUpstream());
          }

          return Right(downloadUrl);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to upload track cover art: $e'));
    }
  }
```

Add imports at top:
```dart
import 'dart:async';
import 'dart:io';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';
```

#### 8. Create UploadTrackCoverArtUseCase
**File**: `lib/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart`
**Changes**: New file

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/usecases/usecase.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class UploadTrackCoverArtParams {
  final AudioTrackId trackId;
  final File imageFile;

  UploadTrackCoverArtParams({
    required this.trackId,
    required this.imageFile,
  });
}

@lazySingleton
class UploadTrackCoverArtUseCase implements UseCase<String, UploadTrackCoverArtParams> {
  final AudioTrackRepository _repository;

  UploadTrackCoverArtUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(UploadTrackCoverArtParams params) async {
    return await _repository.uploadCoverArt(
      params.trackId,
      params.imageFile,
    );
  }
}
```

#### 9. Create UI Upload Form Widget
**File**: `lib/features/audio_track/presentation/widgets/upload_track_cover_art_form.dart`
**Changes**: New file (based on project upload form pattern)

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';

class UploadTrackCoverArtForm extends StatefulWidget {
  final AudioTrack track;

  const UploadTrackCoverArtForm({
    super.key,
    required this.track,
  });

  @override
  State<UploadTrackCoverArtForm> createState() => _UploadTrackCoverArtFormState();
}

class _UploadTrackCoverArtFormState extends State<UploadTrackCoverArtForm> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _uploadCoverArt() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    context.read<AudioTrackBloc>().add(
      UploadTrackCoverArt(
        trackId: widget.track.id,
        imageFile: _selectedImage!,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload Cover Art',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Dimensions.spacingLarge),

          // Image Preview
          if (_selectedImage != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: Dimensions.spacingLarge),

          // Pick Image Button
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(_selectedImage == null ? 'Pick Image' : 'Change Image'),
          ),

          const SizedBox(height: Dimensions.spacingMedium),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedImage != null ? _uploadCoverArt : null,
              child: const Text('Upload'),
            ),
          ),

          // Cancel Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
```

#### 10. Add BLoC Event for Track Cover Art Upload
**File**: `lib/features/audio_track/presentation/bloc/audio_track_event.dart`
**Changes**: Add new event class

```dart
class UploadTrackCoverArt extends AudioTrackEvent {
  final AudioTrackId trackId;
  final File imageFile;

  const UploadTrackCoverArt({
    required this.trackId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [trackId, imageFile];
}
```

Add import at top:
```dart
import 'dart:io';
```

#### 11. Add BLoC Event Handler
**File**: `lib/features/audio_track/presentation/bloc/audio_track_bloc.dart`
**Changes**: Add use case injection and event handler

Add field:
```dart
  final UploadTrackCoverArtUseCase uploadTrackCoverArt;
```

Add to constructor:
```dart
  AudioTrackBloc({
    // ... existing parameters
    required this.uploadTrackCoverArt,
  }) : super(AudioTrackInitial()) {
    // ... existing registrations
    on<UploadTrackCoverArt>(_onUploadTrackCoverArt);
  }
```

Add handler method:
```dart
  Future<void> _onUploadTrackCoverArt(
    UploadTrackCoverArt event,
    Emitter<AudioTrackState> emit,
  ) async {
    emit(AudioTrackLoading());

    final result = await uploadTrackCoverArt(
      UploadTrackCoverArtParams(
        trackId: event.trackId,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) => emit(AudioTrackError(failure.message)),
      (downloadUrl) => emit(AudioTrackCoverArtUploaded(downloadUrl)),
    );
  }
```

Add import:
```dart
import 'package:trackflow/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart';
```

#### 12. Add BLoC State for Upload Success
**File**: `lib/features/audio_track/presentation/bloc/audio_track_state.dart`
**Changes**: Add new state class

```dart
class AudioTrackCoverArtUploaded extends AudioTrackState {
  final String downloadUrl;

  const AudioTrackCoverArtUploaded(this.downloadUrl);

  @override
  List<Object?> get props => [downloadUrl];
}
```

#### 13. Update TrackCoverArt Widget to Support Local Paths
**File**: `lib/features/ui/track/track_cover_art.dart`
**Changes**: Add local file support in `build()` method (line 28)

```dart
  @override
  Widget build(BuildContext context) {
    // Priority 1: Explicit imageUrl parameter (local or remote)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (!imageUrl!.startsWith('http')) {
        return _buildLocalImageCover();
      }
      return _buildImageCover();
    }

    // Priority 2: Track's coverLocalPath
    if (track != null && track!.coverLocalPath != null && track!.coverLocalPath!.isNotEmpty) {
      return _buildTrackLocalImageCover();
    }

    // Priority 3: Track's coverUrl
    if (track != null && track!.coverUrl.isNotEmpty) {
      return _buildTrackImageCover();
    }

    // Priority 4: Metadata coverUrl (fallback to project cover art)
    if (metadata?.coverUrl != null && metadata!.coverUrl!.isNotEmpty) {
      return _buildMetadataImageCover();
    }

    // Priority 5: Generated placeholder
    return _buildGeneratedCover();
  }
```

Add helper methods:
```dart
  Widget _buildLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(),
        ),
      ),
    );
  }

  Widget _buildTrackLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(track!.coverLocalPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(),
        ),
      ),
    );
  }

  Widget _buildTrackImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: track!.coverUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingCover(),
          errorBuilder: (context, url, error) => _buildGeneratedCover(),
        ),
      ),
    );
  }

  Widget _buildMetadataImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: metadata!.coverUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingCover(),
          errorBuilder: (context, url, error) => _buildGeneratedCover(),
        ),
      ),
    );
  }
```

Add import:
```dart
import 'dart:io';
```

#### 14. Add Upload Action to Track Actions Sheet
**File**: `lib/features/audio_track/presentation/widgets/track_actions_sheet.dart` (or similar)
**Changes**: Add "Upload Cover Art" action

If this file doesn't exist, create a similar pattern to `project_detail_actions_sheet.dart`:

```dart
ListTile(
  leading: const Icon(Icons.image),
  title: const Text('Upload Cover Art'),
  onTap: () {
    Navigator.of(context).pop(); // Close actions sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UploadTrackCoverArtForm(track: track),
    );
  },
),
```

#### 15. Run Code Generation
**Command**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
**Reason**: Regenerate Isar schema and dependency injection for new fields and use case

### Success Criteria

#### Automated Verification:
- [ ] Code generation completes successfully
- [ ] No analyzer warnings: `flutter analyze`
- [ ] App builds without errors
- [ ] All dependencies inject correctly (no DI errors)
- [ ] Unit tests pass for `UploadTrackCoverArtUseCase`

#### Manual Verification:
- [ ] Track cover art upload form opens from track actions
- [ ] Image picker selects image successfully
- [ ] Upload compresses to WebP and uploads to Firebase Storage
- [ ] Track displays uploaded cover art immediately
- [ ] Cover art persists offline (test in airplane mode)
- [ ] Track without cover art falls back to project cover art (if available)
- [ ] Generated placeholder shows when no cover art exists anywhere

**Implementation Note**: Test fallback behavior by creating a track in a project that has cover art. The track should initially show the project's cover art, then its own after upload.

---

## Phase 4: Offline Support and Caching Migration

### Overview
Implement backfill logic to download and cache existing remote cover art URLs for offline support. Run on app launch or background sync.

### Changes Required

#### 1. Create CoverArtCacheService
**File**: `lib/core/storage/services/cover_art_cache_service.dart`
**Changes**: New file - Handle backfilling existing cover art

```dart
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';

@lazySingleton
class CoverArtCacheService {
  final ImageStorageRepository _imageStorage;
  final DirectoryService _directoryService;
  final ProjectsLocalDataSource _projectsLocalDataSource;
  final AudioTrackLocalDataSource _audioTrackLocalDataSource;

  CoverArtCacheService(
    this._imageStorage,
    this._directoryService,
    this._projectsLocalDataSource,
    this._audioTrackLocalDataSource,
  );

  /// Backfill missing local cover art for all projects
  Future<void> backfillProjectCoverArt() async {
    try {
      AppLogger.info('Starting project cover art backfill', tag: 'COVER_ART_CACHE');

      final projectsResult = await _projectsLocalDataSource.getAllProjects();

      await projectsResult.fold(
        (failure) async {
          AppLogger.warning('Failed to load projects for backfill: ${failure.message}');
        },
        (projects) async {
          int cached = 0;
          int skipped = 0;

          for (final projectDto in projects) {
            // Skip if already has local path or no remote URL
            if (projectDto.coverLocalPath != null && projectDto.coverLocalPath!.isNotEmpty) {
              skipped++;
              continue;
            }

            if (projectDto.coverUrl == null || projectDto.coverUrl!.isEmpty) {
              skipped++;
              continue;
            }

            // Download and cache
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final localPathResult = await _directoryService.getFilePath(
              DirectoryType.projectCovers,
              '${projectDto.id}_cover_$timestamp.webp',
            );

            await localPathResult.fold(
              (failure) async {
                AppLogger.warning('Failed to get local path for project ${projectDto.id}');
              },
              (localPath) async {
                final downloadResult = await _imageStorage.downloadImage(
                  storageUrl: projectDto.coverUrl!,
                  localPath: localPath,
                  entityId: projectDto.id,
                  entityType: 'project',
                );

                await downloadResult.fold(
                  (failure) async {
                    AppLogger.warning('Failed to download cover art for project ${projectDto.id}: ${failure.message}');
                  },
                  (cachedPath) async {
                    // Update project with local path
                    final updatedDto = projectDto.copyWith(coverLocalPath: cachedPath);
                    await _projectsLocalDataSource.cacheProject(updatedDto);
                    cached++;
                    AppLogger.debug('Cached cover art for project ${projectDto.id}');
                  },
                );
              },
            );
          }

          AppLogger.info(
            'Project cover art backfill complete: $cached cached, $skipped skipped',
            tag: 'COVER_ART_CACHE',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Project cover art backfill failed: $e', tag: 'COVER_ART_CACHE', error: e);
    }
  }

  /// Backfill missing local cover art for all tracks
  Future<void> backfillTrackCoverArt() async {
    try {
      AppLogger.info('Starting track cover art backfill', tag: 'COVER_ART_CACHE');

      final tracksResult = await _audioTrackLocalDataSource.getAllTracks();

      await tracksResult.fold(
        (failure) async {
          AppLogger.warning('Failed to load tracks for backfill: ${failure.message}');
        },
        (tracks) async {
          int cached = 0;
          int skipped = 0;

          for (final track in tracks) {
            // Skip if already has local path or no remote URL
            if (track.coverLocalPath != null && track.coverLocalPath!.isNotEmpty) {
              skipped++;
              continue;
            }

            if (track.coverUrl.isEmpty) {
              skipped++;
              continue;
            }

            // Download and cache
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final localPathResult = await _directoryService.getFilePath(
              DirectoryType.trackCovers,
              '${track.id}_cover_$timestamp.webp',
            );

            await localPathResult.fold(
              (failure) async {
                AppLogger.warning('Failed to get local path for track ${track.id}');
              },
              (localPath) async {
                final downloadResult = await _imageStorage.downloadImage(
                  storageUrl: track.coverUrl,
                  localPath: localPath,
                  entityId: track.id,
                  entityType: 'track',
                );

                await downloadResult.fold(
                  (failure) async {
                    AppLogger.warning('Failed to download cover art for track ${track.id}: ${failure.message}');
                  },
                  (cachedPath) async {
                    // Update track with local path
                    await _audioTrackLocalDataSource.updateTrackCoverUrl(
                      track.id,
                      track.coverUrl,
                      cachedPath,
                    );
                    cached++;
                    AppLogger.debug('Cached cover art for track ${track.id}');
                  },
                );
              },
            );
          }

          AppLogger.info(
            'Track cover art backfill complete: $cached cached, $skipped skipped',
            tag: 'COVER_ART_CACHE',
          );
        },
      );
    } catch (e) {
      AppLogger.error('Track cover art backfill failed: $e', tag: 'COVER_ART_CACHE', error: e);
    }
  }

  /// Run complete backfill for all cover art
  Future<void> backfillAllCoverArt() async {
    await Future.wait([
      backfillProjectCoverArt(),
      backfillTrackCoverArt(),
    ]);
  }
}
```

#### 2. Add Backfill to App Initialization
**File**: `lib/main.dart` or app initialization location
**Changes**: Trigger backfill after successful app launch

Find the app initialization logic (likely in `main()` or after authentication):

```dart
// After user authentication succeeds
final coverArtCache = getIt<CoverArtCacheService>();

// Run backfill in background (don't await)
unawaited(coverArtCache.backfillAllCoverArt());
```

Add import:
```dart
import 'dart:async';
import 'package:trackflow/core/storage/services/cover_art_cache_service.dart';
```

#### 3. Add getAllProjects Method to ProjectsLocalDataSource
**File**: `lib/features/projects/data/datasources/project_local_data_source.dart`
**Changes**: Add method to retrieve all projects (if doesn't exist)

```dart
  /// Get all projects from local cache
  Future<Either<Failure, List<ProjectDTO>>> getAllProjects() async {
    try {
      final isar = await _isarService.db;
      final documents = await isar.projectDocuments.where().findAll();

      final dtos = documents.map((doc) => doc.toDTO()).toList();
      return Right(dtos);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load all projects: $e'));
    }
  }
```

#### 4. Add getAllTracks Method to AudioTrackLocalDataSource
**File**: `lib/features/audio_track/data/datasources/audio_track_local_datasource.dart`
**Changes**: Add method to retrieve all tracks (if doesn't exist)

```dart
  /// Get all tracks from local cache
  Future<Either<Failure, List<AudioTrackDocument>>> getAllTracks() async {
    try {
      final isar = await _isarService.db;
      final documents = await isar.audioTrackDocuments.where().findAll();

      return Right(documents);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load all tracks: $e'));
    }
  }
```

### Success Criteria

#### Automated Verification:
- [ ] App compiles and runs successfully
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Backfill service is registered in dependency injection

#### Manual Verification:
- [ ] Launch app with existing projects/tracks that have remote cover URLs
- [ ] Wait 10-30 seconds for backfill to complete
- [ ] Check logs for "cover art backfill complete" messages
- [ ] Enable airplane mode
- [ ] Cover art still displays for previously cached items
- [ ] Check local storage directories to confirm WebP files were downloaded

**Implementation Note**: Backfill runs asynchronously in the background and does not block app usage. Errors during backfill are logged but do not affect the user experience.

---

## Phase 5: Testing and Migration

### Overview
Comprehensive testing of cover art functionality, migration verification, and edge case handling.

### Changes Required

#### 1. Create Unit Test for UploadCoverArtUseCase (Projects)
**File**: `test/features/projects/domain/usecases/upload_cover_art_usecase_test.dart`
**Changes**: Verify use case (if not already tested)

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/upload_cover_art_usecase.dart';

import 'upload_cover_art_usecase_test.mocks.dart';

@GenerateMocks([ProjectsRepository])
void main() {
  late UploadCoverArtUseCase useCase;
  late MockProjectsRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectsRepository();
    useCase = UploadCoverArtUseCase(mockRepository);
  });

  final projectId = ProjectId.fromString('test-project-id');
  final imageFile = File('/path/to/test.jpg');
  const downloadUrl = 'https://storage.googleapis.com/cover.webp';

  test('should upload cover art and return download URL', () async {
    // Arrange
    when(mockRepository.uploadCoverArt(projectId, imageFile))
        .thenAnswer((_) async => const Right(downloadUrl));

    // Act
    final result = await useCase(UploadCoverArtParams(
      projectId: projectId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, const Right(downloadUrl));
    verify(mockRepository.uploadCoverArt(projectId, imageFile));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when upload fails', () async {
    // Arrange
    when(mockRepository.uploadCoverArt(projectId, imageFile))
        .thenAnswer((_) async => Left(ServerFailure('Upload failed')));

    // Act
    final result = await useCase(UploadCoverArtParams(
      projectId: projectId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, Left(ServerFailure('Upload failed')));
    verify(mockRepository.uploadCoverArt(projectId, imageFile));
  });
}
```

#### 2. Create Unit Test for UploadTrackCoverArtUseCase
**File**: `test/features/audio_track/domain/usecases/upload_track_cover_art_usecase_test.dart`
**Changes**: New file - Test track cover art use case

```dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart';

import 'upload_track_cover_art_usecase_test.mocks.dart';

@GenerateMocks([AudioTrackRepository])
void main() {
  late UploadTrackCoverArtUseCase useCase;
  late MockAudioTrackRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioTrackRepository();
    useCase = UploadTrackCoverArtUseCase(mockRepository);
  });

  final trackId = AudioTrackId.fromString('test-track-id');
  final imageFile = File('/path/to/test.jpg');
  const downloadUrl = 'https://storage.googleapis.com/track_cover.webp';

  test('should upload track cover art and return download URL', () async {
    // Arrange
    when(mockRepository.uploadCoverArt(trackId, imageFile))
        .thenAnswer((_) async => const Right(downloadUrl));

    // Act
    final result = await useCase(UploadTrackCoverArtParams(
      trackId: trackId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, const Right(downloadUrl));
    verify(mockRepository.uploadCoverArt(trackId, imageFile));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when upload fails', () async {
    // Arrange
    when(mockRepository.uploadCoverArt(trackId, imageFile))
        .thenAnswer((_) async => Left(ServerFailure('Upload failed')));

    // Act
    final result = await useCase(UploadTrackCoverArtParams(
      trackId: trackId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, Left(ServerFailure('Upload failed')));
    verify(mockRepository.uploadCoverArt(trackId, imageFile));
  });
}
```

#### 3. Generate Test Mocks
**Command**: `flutter packages pub run build_runner build --delete-conflicting-outputs`
**Reason**: Generate mocks for new test files

#### 4. Create Integration Test for Cover Art Flow
**File**: `integration_test/cover_art_flow_test.dart`
**Changes**: New file - End-to-end test

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cover Art Integration Tests', () {
    testWidgets('Upload project cover art end-to-end', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // TODO: Navigate to project details
      // TODO: Open cover art upload form
      // TODO: Select test image
      // TODO: Verify upload succeeds
      // TODO: Verify cover art displays
      // TODO: Enable offline mode
      // TODO: Verify cover art still displays from cache
    });

    testWidgets('Upload track cover art with fallback to project', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // TODO: Create project with cover art
      // TODO: Create track in project
      // TODO: Verify track shows project cover art initially
      // TODO: Upload track-specific cover art
      // TODO: Verify track now shows its own cover art
    });
  });
}
```

#### 5. Manual Testing Checklist

Create a testing document or checklist:

**Project Cover Art Tests:**
- [ ] Upload new cover art for project
- [ ] Verify WebP compression (check file size in Firebase Storage)
- [ ] Cover art displays immediately after upload
- [ ] Enable airplane mode → cover art still displays
- [ ] Restart app offline → cover art still displays
- [ ] Delete local cache → re-download works when online
- [ ] Project without cover art shows generated placeholder

**Track Cover Art Tests:**
- [ ] Create track in project without cover art → shows generated placeholder
- [ ] Create track in project with cover art → shows project cover art
- [ ] Upload track-specific cover art → shows track cover art
- [ ] Track cover art persists offline
- [ ] Delete track cover art → falls back to project cover art
- [ ] Track without cover art in project without cover art → shows generated placeholder

**Migration Tests:**
- [ ] Existing projects with old cover URLs backfill successfully
- [ ] Backfill logs show completion in app logs
- [ ] Old projects display cover art offline after backfill
- [ ] New projects use new storage path structure

**Error Handling Tests:**
- [ ] Upload with no internet → saves locally, syncs later
- [ ] Upload with corrupt image → shows error message
- [ ] Download fails during backfill → logged but doesn't crash
- [ ] Firebase Storage quota exceeded → shows appropriate error

### Success Criteria

#### Automated Verification:
- [ ] All unit tests pass: `flutter test`
- [ ] Code generation for test mocks completes successfully
- [ ] No test failures or warnings
- [ ] Code coverage >80% for new use cases and repositories

#### Manual Verification:
- [ ] All manual testing checklist items pass
- [ ] Cover art uploads complete in <5 seconds on good connection
- [ ] WebP compression reduces file sizes by 30-50%
- [ ] No memory leaks or crashes during upload/download
- [ ] Offline mode works reliably for cached cover art
- [ ] Backfill completes without blocking app usage

**Implementation Note**: Integration tests require a test Firebase project and test images. Consider adding test fixtures in `test/fixtures/` directory.

---

## Performance Considerations

### Image Compression
- WebP format reduces file sizes by 30-50% compared to PNG/JPG
- Quality 85% provides excellent visual quality with smaller files
- Compression happens before upload, reducing network bandwidth

### Caching Strategy
- Dual-field pattern (remote + local) enables offline-first
- `CachedNetworkImage` provides HTTP caching for network images
- Local files stored in organized directories for easy cleanup
- Backfill runs asynchronously without blocking UI

### Firebase Storage
- Hierarchical path structure enables efficient querying
- Custom metadata supports future features (e.g., attribution, dimensions)
- Download URLs are cached to avoid repeated getDownloadURL() calls

### Potential Optimizations
- Implement LRU cache cleanup for old cover art (future enhancement)
- Add image dimension validation (e.g., min 300x300, max 4000x4000)
- Consider lazy loading backfill (on-demand instead of app launch)

## Migration Notes

### Database Migration
- Isar schema changes auto-handled by code generation
- New nullable fields (`coverLocalPath`) are backwards compatible
- Existing data remains valid; new field starts as null

### Firebase Storage Migration
- New storage paths coexist with old paths (no breaking changes)
- Existing cover URLs remain accessible at old paths
- Backfill downloads from old URLs and caches locally

### Backwards Compatibility
- Old projects with `coverUrl` only continue to work
- `CachedNetworkImage` handles old URLs transparently
- DTO maintains 'url' field name in Firestore for tracks (compatibility)

### Rollback Plan
If issues arise during deployment:
1. Revert code changes to previous commit
2. Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
3. Old schema still works (new fields are nullable)
4. No data loss - Firebase Storage files remain accessible

## References

- Original issue: Cover art persistence and upload refactor request
- Related research:
  - User avatar implementation: `lib/features/user_profile/`
  - Audio file repository pattern: `lib/core/audio/data/unified_audio_service.dart`
  - Firebase Storage integration: `lib/core/di/app_module.dart:39-40`
- Similar implementations:
  - Project cover art widget: [lib/features/ui/project/project_cover_art.dart](lib/features/ui/project/project_cover_art.dart)
  - User profile avatar: [lib/features/user_profile/data/repositories/user_profile_repository_impl.dart:65-138](lib/features/user_profile/data/repositories/user_profile_repository_impl.dart#L65-L138)
- Architecture guidelines: `CLAUDE.md`

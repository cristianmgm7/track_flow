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

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

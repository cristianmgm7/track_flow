import 'dart:io';
import 'package:dartz/dartz.dart';

import '../entities/cached_audio.dart';
import '../entities/cleanup_details.dart';
import '../entities/cache_validation_result.dart';
import '../failures/cache_failure.dart';

abstract class CacheMaintenanceService {
  /// Perform comprehensive cache cleanup
  Future<Either<CacheFailure, CleanupDetails>> performCleanup({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool removeTemporary = true,
    int? targetFreeBytes,
  });

  /// Remove corrupted files from cache
  Future<Either<CacheFailure, int>> removeCorruptedFiles();

  /// Remove orphaned files from cache
  Future<Either<CacheFailure, int>> removeOrphanedFiles();

  /// Clean up temporary files
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles();

  /// Free up space by removing oldest files
  Future<Either<CacheFailure, int>> freeUpSpace(int targetFreeBytes);

  /// Validate cache integrity
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheIntegrity();

  /// Get cache directory size
  Future<Either<CacheFailure, int>> getCacheDirectorySize();

  /// Get list of corrupted files
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();

  /// Get list of orphaned files
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();

  /// Get total storage usage
  Future<Either<CacheFailure, int>> getTotalStorageUsage();

  /// Get available storage space
  Future<Either<CacheFailure, int>> getAvailableStorageSpace();

  /// Get all cached audios
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();

  /// Validate file integrity using checksum
  Future<Either<CacheFailure, bool>> validateFileIntegrity(
    String trackId,
    String expectedChecksum,
  );

  /// Calculate file checksum
  Future<Either<CacheFailure, String>> calculateFileChecksum(String filePath);

  /// Get cache directory
  Future<Either<CacheFailure, Directory>> getCacheDirectory();
}

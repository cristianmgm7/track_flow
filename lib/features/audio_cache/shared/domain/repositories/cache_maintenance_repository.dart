import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../entities/cache_validation_result.dart';
import '../failures/cache_failure.dart';

/// Repository responsible for cache maintenance and validation operations
/// Follows Single Responsibility Principle - only handles maintenance tasks
abstract class CacheMaintenanceRepository {
  // ===============================================
  // CACHE VALIDATION
  // ===============================================

  /// Validate entire cache consistency
  Future<Either<CacheFailure, CacheValidationResult>>
      validateCacheConsistency();

  /// Validate specific cache entry
  Future<Either<CacheFailure, bool>> validateCacheEntry(AudioTrackId trackId);

  /// Validate cache metadata integrity
  Future<Either<CacheFailure, bool>> validateCacheMetadata();

  // ===============================================
  // CACHE CLEANUP
  // ===============================================

  /// Clean up orphaned files (files without metadata)
  Future<Either<CacheFailure, int>> cleanupOrphanedFiles();

  /// Clean up invalid metadata entries (metadata without files)
  Future<Either<CacheFailure, int>> cleanupInvalidMetadata();

  /// Clean up temporary files
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles();

  /// Clean up old cache entries based on policies
  Future<Either<CacheFailure, int>> cleanupOldEntries({
    Duration? maxAge,
    int? maxEntries,
  });

  // ===============================================
  // CACHE REBUILDING
  // ===============================================

  /// Rebuild cache index from existing files
  Future<Either<CacheFailure, int>> rebuildCacheIndex();

  /// Rebuild cache metadata from file system
  Future<Either<CacheFailure, int>> rebuildCacheMetadata();

  /// Scan file system and update cache registry
  Future<Either<CacheFailure, int>> scanAndUpdateCacheRegistry();

  // ===============================================
  // CACHE MIGRATION
  // ===============================================

  /// Migrate existing cache files to new structure
  Future<Either<CacheFailure, int>> migrateCacheStructure();

  /// Migrate cache metadata to new version
  Future<Either<CacheFailure, int>> migrateCacheMetadata();

  /// Check if migration is needed
  Future<Either<CacheFailure, bool>> isMigrationNeeded();

  // ===============================================
  // CACHE OPTIMIZATION
  // ===============================================

  /// Optimize cache storage layout
  Future<Either<CacheFailure, Unit>> optimizeCacheLayout();

  /// Defragment cache storage
  Future<Either<CacheFailure, Unit>> defragmentCacheStorage();

  /// Compress cache metadata
  Future<Either<CacheFailure, Unit>> compressCacheMetadata();

  // ===============================================
  // CACHE HEALTH MONITORING
  // ===============================================

  /// Get cache health statistics
  Future<Either<CacheFailure, Map<String, dynamic>>> getCacheHealthStats();

  /// Check cache integrity
  Future<Either<CacheFailure, double>> checkCacheIntegrityScore();

  /// Generate cache maintenance report
  Future<Either<CacheFailure, String>> generateMaintenanceReport();
}
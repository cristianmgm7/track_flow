import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../failures/cache_failure.dart';
import '../value_objects/cache_key.dart';

/// Repository responsible for cache key management
/// Follows Single Responsibility Principle - only handles cache key operations
abstract class CacheKeyRepository {
  // ===============================================
  // CACHE KEY GENERATION
  // ===============================================

  /// Generate cache key from track ID and URL
  CacheKey generateCacheKey(AudioTrackId trackId, String audioUrl);

  /// Generate cache key with custom parameters
  CacheKey generateCacheKeyWithParams(
    AudioTrackId trackId,
    String audioUrl,
    Map<String, String> parameters,
  );

  // ===============================================
  // CACHE KEY OPERATIONS
  // ===============================================

  /// Get file path from cache key
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);

  /// Get directory path from cache key
  Future<Either<CacheFailure, String>> getDirectoryPathFromCacheKey(
    CacheKey key,
  );

  /// Validate cache key format
  bool isValidCacheKey(CacheKey key);

  /// Parse cache key to extract components
  Either<CacheFailure, Map<String, String>> parseCacheKey(CacheKey key);

  // ===============================================
  // CACHE KEY UTILITIES
  // ===============================================

  /// Generate cache key for temporary files
  CacheKey generateTempCacheKey(AudioTrackId trackId);

  /// Check if cache key represents a temporary file
  bool isTempCacheKey(CacheKey key);

  /// Convert cache key to storage identifier
  String cacheKeyToStorageId(CacheKey key);

  /// Convert storage identifier to cache key
  Either<CacheFailure, CacheKey> storageIdToCacheKey(String storageId);
}
import 'package:dartz/dartz.dart';
import '../entities/cache_reference.dart';
import '../entities/cache_metadata.dart';
import '../entities/cached_audio.dart';
import '../failures/cache_failure.dart';

/// Repository for managing cache metadata and reference counting
/// CRITICAL: This handles reference counting to prevent data loss
abstract class CacheMetadataRepository {
  // ===============================================
  // REFERENCE COUNTING OPERATIONS - CRITICAL
  // ===============================================

  /// Add a reference to a cached track
  /// Creates new reference if track not tracked, adds to existing if present
  Future<Either<CacheFailure, CacheReference>> addReference(
    String trackId,
    String referenceId,
  );

  /// Remove a reference from a cached track
  /// Returns updated reference with remaining references
  /// Returns null if no references remain (safe to delete file)
  Future<Either<CacheFailure, CacheReference?>> removeReference(
    String trackId,
    String referenceId,
  );

  /// Get current reference information for a track
  Future<Either<CacheFailure, CacheReference?>> getReference(String trackId);

  /// Get all references for multiple tracks (for batch operations)
  Future<Either<CacheFailure, Map<String, CacheReference>>> getMultipleReferences(
    List<String> trackIds,
  );

  /// Check if track can be safely deleted (no remaining references)
  Future<Either<CacheFailure, bool>> canDelete(String trackId);

  /// Get all tracks that can be safely deleted (for cleanup)
  Future<Either<CacheFailure, List<String>>> getDeletableTrackIds();

  // ===============================================
  // METADATA MANAGEMENT
  // ===============================================

  /// Store or update metadata for a cached track
  Future<Either<CacheFailure, Unit>> saveMetadata(CacheMetadata metadata);

  /// Get metadata for a specific track
  Future<Either<CacheFailure, CacheMetadata?>> getMetadata(String trackId);

  /// Get metadata for multiple tracks
  Future<Either<CacheFailure, Map<String, CacheMetadata>>> getMultipleMetadata(
    List<String> trackIds,
  );

  /// Update last accessed time for a track
  Future<Either<CacheFailure, Unit>> updateLastAccessed(String trackId);

  /// Increment download attempts for failed downloads
  Future<Either<CacheFailure, Unit>> incrementDownloadAttempts(
    String trackId,
    String? failureReason,
  );

  /// Mark track as downloading
  Future<Either<CacheFailure, Unit>> markAsDownloading(String trackId);

  /// Mark track as successfully cached
  Future<Either<CacheFailure, Unit>> markAsCompleted(String trackId);

  /// Mark track as corrupted
  Future<Either<CacheFailure, Unit>> markAsCorrupted(String trackId);

  // ===============================================
  // QUERY OPERATIONS - FOR MANAGEMENT & CLEANUP
  // ===============================================

  /// Get all cached track IDs
  Future<Either<CacheFailure, List<String>>> getAllCachedTrackIds();

  /// Get tracks by status (for filtering in management screen)
  Future<Either<CacheFailure, List<String>>> getTracksByStatus(
    CacheStatus status,
  );

  /// Get tracks with failed downloads that can be retried
  Future<Either<CacheFailure, List<String>>> getRetryableTrackIds();

  /// Get corrupted tracks for cleanup
  Future<Either<CacheFailure, List<String>>> getCorruptedTrackIds();

  /// Get tracks with no references (orphaned) for cleanup
  Future<Either<CacheFailure, List<String>>> getOrphanedTrackIds();

  /// Get tracks by reference ID (e.g., all tracks in a playlist)
  Future<Either<CacheFailure, List<String>>> getTracksByReference(
    String referenceId,
  );

  // ===============================================
  // STATISTICS & MONITORING
  // ===============================================

  /// Get total number of cached tracks
  Future<Either<CacheFailure, int>> getTotalTracksCount();

  /// Get total number of references across all tracks
  Future<Either<CacheFailure, int>> getTotalReferencesCount();

  /// Get reference count distribution (for analytics)
  Future<Either<CacheFailure, Map<int, int>>> getReferenceCountDistribution();

  /// Get tracks with most references (popular tracks)
  Future<Either<CacheFailure, List<CacheReference>>> getMostReferencedTracks({
    int limit = 10,
  });

  /// Get recently accessed tracks
  Future<Either<CacheFailure, List<CacheReference>>> getRecentlyAccessedTracks({
    int limit = 10,
  });

  // ===============================================
  // BATCH OPERATIONS - FOR PERFORMANCE
  // ===============================================

  /// Save multiple metadata entries in a single transaction
  Future<Either<CacheFailure, Unit>> saveMultipleMetadata(
    List<CacheMetadata> metadataList,
  );

  /// Delete metadata for multiple tracks (for cleanup)
  Future<Either<CacheFailure, Unit>> deleteMultipleMetadata(
    List<String> trackIds,
  );

  /// Clear all metadata (for complete cache reset)
  Future<Either<CacheFailure, Unit>> clearAllMetadata();

  // ===============================================
  // REACTIVE STREAMS - FOR REAL-TIME UPDATES
  // ===============================================

  /// Watch reference changes for a specific track
  Stream<CacheReference?> watchReference(String trackId);

  /// Watch metadata changes for a specific track
  Stream<CacheMetadata?> watchMetadata(String trackId);

  /// Watch all reference changes (for global cache monitoring)
  Stream<List<CacheReference>> watchAllReferences();
}
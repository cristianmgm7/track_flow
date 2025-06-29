import 'package:dartz/dartz.dart';
import '../entities/cached_audio.dart';
import '../entities/cache_reference.dart';
import '../entities/download_progress.dart';
import '../failures/cache_failure.dart';
import '../value_objects/conflict_policy.dart';

/// Main coordinator service for all cache operations in MVP
/// This service orchestrates downloads, storage, and metadata management
/// while maintaining reference counting and preventing data loss
abstract class CacheOrchestrationService {
  // ===============================================
  // CORE CACHE OPERATIONS - MVP FUNCTIONALITY
  // ===============================================

  /// Cache audio with reference tracking and conflict resolution
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  /// [referenceId] - Reference ID (e.g., 'individual', 'playlist_123')
  /// [policy] - How to handle conflicts if track already exists
  ///
  /// Returns success or specific failure type for proper error handling
  Future<Either<CacheFailure, Unit>> cacheAudio(
    String trackId,
    String audioUrl,
    String referenceId, {
    ConflictPolicy policy = ConflictPolicy.lastWins,
  });

  /// Get cached audio file path if available
  ///
  /// Returns file path or failure if not cached/corrupted
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);

  /// Remove reference from cache with proper reference counting
  ///
  /// Only deletes actual file when no references remain
  /// Prevents accidental data loss from shared tracks
  Future<Either<CacheFailure, Unit>> removeFromCache(
    String trackId,
    String referenceId,
  );

  /// Check current cache status for a track
  ///
  /// Returns current status (cached, downloading, failed, etc.)
  Future<Either<CacheFailure, CacheStatus>> getCacheStatus(String trackId);

  /// Get cache reference information for debugging/management
  Future<Either<CacheFailure, CacheReference?>> getCacheReference(
    String trackId,
  );

  // ===============================================
  // REAL-TIME UPDATES - REACTIVE STREAMS
  // ===============================================

  /// Watch download progress for real-time UI updates
  Stream<DownloadProgress> watchDownloadProgress(String trackId);

  /// Watch cache status changes for a specific track
  Stream<CacheStatus> watchCacheStatus(String trackId);

  /// Watch all active downloads for global progress indication
  Stream<List<DownloadProgress>> watchActiveDownloads();

  // ===============================================
  // BATCH OPERATIONS - FOR PLAYLIST SUPPORT
  // ===============================================

  /// Cache multiple tracks with single reference (e.g., playlist)
  ///
  /// Optimized for playlist caching with proper queue management
  Future<Either<CacheFailure, Unit>> cacheMultipleAudios(
    Map<String, String> trackUrlPairs, // trackId -> audioUrl
    String referenceId, {
    ConflictPolicy policy = ConflictPolicy.lastWins,
  });

  /// Remove multiple references at once (e.g., when deleting playlist)
  Future<Either<CacheFailure, Unit>> removeMultipleFromCache(
    List<String> trackIds,
    String referenceId,
  );

  /// Get cache status for multiple tracks (for playlist UI)
  Future<Either<CacheFailure, Map<String, CacheStatus>>> getMultipleCacheStatus(
    List<String> trackIds,
  );

  // ===============================================
  // MANAGEMENT OPERATIONS - FOR CACHE SCREEN
  // ===============================================

  /// Get all cached tracks with their metadata
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();

  /// Get storage statistics and usage information
  Future<Either<CacheFailure, StorageStats>> getStorageStats();

  /// Force cleanup of corrupted or unused files
  Future<Either<CacheFailure, CleanupResult>> cleanupCache({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
  });

  /// Cancel ongoing download
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId);

  /// Retry failed download with exponential backoff
  Future<Either<CacheFailure, Unit>> retryDownload(String trackId);
}

/// Storage statistics for cache management
class StorageStats {
  const StorageStats({
    required this.totalCachedFiles,
    required this.totalSizeBytes,
    required this.availableSpaceBytes,
    required this.usedPercentage,
    required this.corruptedFiles,
    required this.orphanedFiles,
  });

  final int totalCachedFiles;
  final int totalSizeBytes;
  final int availableSpaceBytes;
  final double usedPercentage;
  final int corruptedFiles;
  final int orphanedFiles;

  String get formattedTotalSize => _formatBytes(totalSizeBytes);
  String get formattedAvailableSpace => _formatBytes(availableSpaceBytes);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Cleanup operation results
class CleanupResult {
  const CleanupResult({
    required this.removedFiles,
    required this.freedSpaceBytes,
    required this.corruptedRemoved,
    required this.orphanedRemoved,
    this.errors = const [],
  });

  final int removedFiles;
  final int freedSpaceBytes;
  final int corruptedRemoved;
  final int orphanedRemoved;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
  String get formattedFreedSpace => StorageStats._formatBytes(freedSpaceBytes);
}

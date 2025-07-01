import 'package:dartz/dartz.dart';
import '../entities/cached_audio.dart';
import '../entities/download_progress.dart';
import '../entities/cache_validation_result.dart';
import '../failures/cache_failure.dart';
import '../value_objects/cache_key.dart';

/// Repository for managing physical file storage operations
/// Handles actual file downloads, storage, and retrieval
abstract class CacheStorageRepository {
  // ===============================================
  // BASIC CRUD OPERATIONS
  // ===============================================

  /// Download and store audio file
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  /// [progressCallback] - Optional callback for download progress
  ///
  /// Returns cached audio info or failure
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  });

  /// Get cached audio file path if exists
  ///
  /// Returns absolute file path or failure if not found
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);

  /// Check if audio file exists and is valid
  Future<Either<CacheFailure, bool>> audioExists(String trackId);

  /// Get cached audio information
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);

  /// Delete audio file from storage
  /// WARNING: This physically deletes the file - ensure reference counting first
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);

  // ===============================================
  // BATCH OPERATIONS - FOR PERFORMANCE
  // ===============================================

  /// Download multiple audio files with progress tracking
  Future<Either<CacheFailure, List<CachedAudio>>> downloadMultipleAudios(
    Map<String, String> trackUrlPairs, { // trackId -> audioUrl
    void Function(String trackId, DownloadProgress)? progressCallback,
  });

  /// Get cached audio info for multiple tracks
  Future<Either<CacheFailure, Map<String, CachedAudio>>>
  getMultipleCachedAudios(List<String> trackIds);

  /// Delete multiple audio files
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(
    List<String> trackIds,
  );

  /// Check existence of multiple audio files
  Future<Either<CacheFailure, Map<String, bool>>> checkMultipleAudioExists(
    List<String> trackIds,
  );

  // ===============================================
  // STORAGE MANAGEMENT
  // ===============================================

  // Note: Storage management and cleanup operations are handled by CacheMaintenanceService
  // to avoid duplication of responsibilities

  // ===============================================
  // DOWNLOAD MANAGEMENT
  // ===============================================

  /// Cancel ongoing download for a track
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId);

  /// Pause download (if supported)
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId);

  /// Resume paused download
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId);

  /// Get current download progress for a track
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(
    String trackId,
  );

  /// Get all currently active downloads
  Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads();

  // ===============================================
  // REACTIVE STREAMS
  // ===============================================

  /// Watch download progress for a specific track
  Stream<DownloadProgress> watchDownloadProgress(String trackId);

  /// Watch all active downloads
  Stream<List<DownloadProgress>> watchActiveDownloads();

  /// Watch storage usage changes
  Stream<int> watchStorageUsage();

  // ===============================================
  // CACHE KEY MANAGEMENT
  // ===============================================

  /// Generate cache key from track ID and URL
  CacheKey generateCacheKey(String trackId, String audioUrl);

  /// Get file path from cache key
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);

  /// Validate cache key format
  bool isValidCacheKey(CacheKey key);

  // ===============================================
  // MIGRATION & MAINTENANCE
  // ===============================================

  /// Migrate existing cache files to new structure
  Future<Either<CacheFailure, int>> migrateCacheStructure();

  /// Rebuild cache index from existing files
  Future<Either<CacheFailure, int>> rebuildCacheIndex();

  /// Validate entire cache consistency
  Future<Either<CacheFailure, CacheValidationResult>>
  validateCacheConsistency();
}

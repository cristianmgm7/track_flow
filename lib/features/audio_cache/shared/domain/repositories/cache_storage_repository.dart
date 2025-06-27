import 'package:dartz/dartz.dart';
import '../entities/cached_audio.dart';
import '../entities/download_progress.dart';
import '../failures/cache_failure.dart';
import '../value_objects/cache_key.dart';

/// Repository for managing physical file storage operations
/// Handles actual file downloads, storage, and retrieval
abstract class CacheStorageRepository {
  // ===============================================
  // CORE FILE OPERATIONS
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

  /// Verify file integrity using checksum
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  );

  // ===============================================
  // BATCH OPERATIONS - FOR PERFORMANCE
  // ===============================================

  /// Download multiple audio files with progress tracking
  Future<Either<CacheFailure, List<CachedAudio>>> downloadMultipleAudios(
    Map<String, String> trackUrlPairs, // trackId -> audioUrl
    {void Function(String trackId, DownloadProgress)? progressCallback}
  );

  /// Get cached audio info for multiple tracks
  Future<Either<CacheFailure, Map<String, CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  );

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

  /// Get all cached audio files with their information
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();

  /// Get total storage usage in bytes
  Future<Either<CacheFailure, int>> getTotalStorageUsage();

  /// Get available storage space in bytes
  Future<Either<CacheFailure, int>> getAvailableStorageSpace();

  /// Calculate cache directory size
  Future<Either<CacheFailure, int>> getCacheDirectorySize();

  /// Get list of corrupted files (checksum mismatch)
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();

  /// Get list of orphaned files (no metadata reference)
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();

  // ===============================================
  // CLEANUP OPERATIONS
  // ===============================================

  /// Remove corrupted files from storage
  Future<Either<CacheFailure, int>> removeCorruptedFiles();

  /// Remove orphaned files that have no metadata
  Future<Either<CacheFailure, int>> removeOrphanedFiles();

  /// Clean up temporary/incomplete download files
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles();

  /// Free up space by removing oldest files until target size reached
  Future<Either<CacheFailure, int>> freeUpSpace(int targetFreeBytes);

  /// Comprehensive cache cleanup with detailed results
  Future<Either<CacheFailure, CleanupDetails>> performCleanup({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool removeTemporary = true,
    int? targetFreeBytes,
  });

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
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheConsistency();
}

/// Detailed cleanup operation results
class CleanupDetails {
  const CleanupDetails({
    required this.corruptedFilesRemoved,
    required this.orphanedFilesRemoved,
    required this.temporaryFilesRemoved,
    required this.oldestFilesRemoved,
    required this.totalSpaceFreed,
    required this.totalFilesRemoved,
    this.errors = const [],
  });

  final int corruptedFilesRemoved;
  final int orphanedFilesRemoved;
  final int temporaryFilesRemoved;
  final int oldestFilesRemoved;
  final int totalSpaceFreed;
  final int totalFilesRemoved;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
  
  String get summary => 
    'Removed $totalFilesRemoved files, freed ${_formatBytes(totalSpaceFreed)}';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Cache validation results
class CacheValidationResult {
  const CacheValidationResult({
    required this.totalFiles,
    required this.validFiles,
    required this.corruptedFiles,
    required this.orphanedFiles,
    required this.missingMetadata,
    required this.inconsistentSizes,
    this.issues = const [],
  });

  final int totalFiles;
  final int validFiles;
  final int corruptedFiles;
  final int orphanedFiles;
  final int missingMetadata;
  final int inconsistentSizes;
  final List<String> issues;

  bool get isValid => 
    corruptedFiles == 0 && 
    orphanedFiles == 0 && 
    missingMetadata == 0 && 
    inconsistentSizes == 0;

  double get validityPercentage => 
    totalFiles > 0 ? (validFiles / totalFiles) : 1.0;
}
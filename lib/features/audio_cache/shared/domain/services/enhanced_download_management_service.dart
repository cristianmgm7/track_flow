import 'package:dartz/dartz.dart';
import '../entities/download_progress.dart';
import '../failures/cache_failure.dart';
import '../value_objects/download_priority.dart';

/// Enhanced download management service that extends existing functionality
/// Integrates with shared infrastructure while maintaining compatibility
abstract class EnhancedDownloadManagementService {
  // ===============================================
  // CORE DOWNLOAD OPERATIONS - ENHANCED
  // ===============================================

  /// Download audio with enhanced progress tracking
  /// Replaces the old DownloadTaskRequest with shared entities
  Future<Either<CacheFailure, Unit>> downloadAudio(
    String trackId,
    String audioUrl,
    String trackName, {
    DownloadPriority priority = DownloadPriority.normal,
    void Function(DownloadProgress)? progressCallback,
  });

  /// Download multiple audios with priority management
  Future<Either<CacheFailure, Unit>> downloadMultipleAudios(
    Map<String, DownloadAudioRequest> requests, // trackId -> request
  );

  /// Cancel specific download
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId);

  /// Cancel all active downloads
  Future<Either<CacheFailure, Unit>> cancelAllDownloads();

  /// Pause download (if supported by implementation)
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId);

  /// Resume paused download
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId);

  /// Retry failed download with exponential backoff
  Future<Either<CacheFailure, Unit>> retryDownload(String trackId);

  /// Retry all failed downloads
  Future<Either<CacheFailure, Unit>> retryAllFailedDownloads();

  // ===============================================
  // QUEUE MANAGEMENT - ENHANCED
  // ===============================================

  /// Get current queue information with enhanced details
  Future<Either<CacheFailure, EnhancedQueueInfo>> getQueueInfo();

  /// Get position of track in download queue
  Future<Either<CacheFailure, int?>> getQueuePosition(String trackId);

  /// Move track to front of queue (high priority)
  Future<Either<CacheFailure, Unit>> prioritizeDownload(String trackId);

  /// Change download priority for queued track
  Future<Either<CacheFailure, Unit>> changeDownloadPriority(
    String trackId,
    DownloadPriority newPriority,
  );

  /// Clear completed downloads from queue
  Future<Either<CacheFailure, Unit>> clearCompletedDownloads();

  /// Get maximum concurrent downloads setting
  int get maxConcurrentDownloads;

  /// Set maximum concurrent downloads
  Future<Either<CacheFailure, Unit>> setMaxConcurrentDownloads(int max);

  // ===============================================
  // PROGRESS TRACKING - REACTIVE
  // ===============================================

  /// Watch download progress for specific track
  Stream<DownloadProgress> watchDownloadProgress(String trackId);

  /// Watch progress for all active downloads
  Stream<List<DownloadProgress>> watchAllDownloadProgress();

  /// Get current download progress snapshot
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(
    String trackId,
  );

  /// Get progress for multiple tracks
  Future<Either<CacheFailure, Map<String, DownloadProgress>>> getMultipleDownloadProgress(
    List<String> trackIds,
  );

  // ===============================================
  // STATUS MANAGEMENT
  // ===============================================

  /// Get current download state for track
  Future<Either<CacheFailure, DownloadState>> getDownloadState(String trackId);

  /// Get download states for multiple tracks
  Future<Either<CacheFailure, Map<String, DownloadState>>> getMultipleDownloadStates(
    List<String> trackIds,
  );

  /// Watch download state changes
  Stream<Map<String, DownloadState>> watchDownloadStates();

  /// Get all tracks by download state
  Future<Either<CacheFailure, List<String>>> getTracksByState(
    DownloadState state,
  );

  // ===============================================
  // BATCH OPERATIONS
  // ===============================================

  /// Add multiple tracks to download queue
  Future<Either<CacheFailure, Unit>> enqueueMultipleDownloads(
    List<DownloadAudioRequest> requests,
  );

  /// Remove multiple tracks from queue
  Future<Either<CacheFailure, Unit>> removeMultipleFromQueue(
    List<String> trackIds,
  );

  /// Cancel downloads for multiple tracks
  Future<Either<CacheFailure, Unit>> cancelMultipleDownloads(
    List<String> trackIds,
  );

  // ===============================================
  // STATISTICS & MONITORING
  // ===============================================

  /// Get download statistics
  Future<Either<CacheFailure, DownloadStatistics>> getDownloadStatistics();

  /// Get failed download reasons
  Future<Either<CacheFailure, Map<String, String>>> getFailureReasons();

  /// Get average download speed
  Future<Either<CacheFailure, double>> getAverageDownloadSpeed();

  /// Get download completion rate
  Future<Either<CacheFailure, double>> getDownloadCompletionRate();

  // ===============================================
  // CONFIGURATION
  // ===============================================

  /// Get download timeout setting
  Duration get downloadTimeout;

  /// Set download timeout
  Future<Either<CacheFailure, Unit>> setDownloadTimeout(Duration timeout);

  /// Get retry attempts setting
  int get maxRetryAttempts;

  /// Set maximum retry attempts
  Future<Either<CacheFailure, Unit>> setMaxRetryAttempts(int attempts);

  /// Get/Set automatic retry on failure
  bool get automaticRetryEnabled;
  Future<Either<CacheFailure, Unit>> setAutomaticRetryEnabled(bool enabled);
}

/// Enhanced download request with shared infrastructure support
class DownloadAudioRequest {
  const DownloadAudioRequest({
    required this.trackId,
    required this.audioUrl,
    required this.trackName,
    this.priority = DownloadPriority.normal,
    this.referenceId,
  });

  final String trackId;
  final String audioUrl;
  final String trackName;
  final DownloadPriority priority;
  final String? referenceId; // For reference counting

  /// Convert to old format for backward compatibility
  // DownloadTaskRequest toDownloadTaskRequest() {
  //   return DownloadTaskRequest(
  //     trackId: trackId,
  //     trackUrl: audioUrl,
  //     trackName: trackName,
  //     priority: _convertPriority(priority),
  //   );
  // }
}

/// Enhanced queue information with detailed metrics
class EnhancedQueueInfo {
  const EnhancedQueueInfo({
    required this.queuedCount,
    required this.downloadingCount,
    required this.completedCount,
    required this.failedCount,
    required this.pausedCount,
    required this.cancelledCount,
    required this.totalTasks,
    required this.estimatedTimeRemaining,
    required this.averageDownloadSpeed,
    required this.currentBandwidthUsage,
  });

  final int queuedCount;
  final int downloadingCount;
  final int completedCount;
  final int failedCount;
  final int pausedCount;
  final int cancelledCount;
  final int totalTasks;
  final Duration? estimatedTimeRemaining;
  final double averageDownloadSpeed; // bytes per second
  final double currentBandwidthUsage; // bytes per second

  double get completionRate => 
    totalTasks > 0 ? completedCount / totalTasks : 0.0;

  int get activeCount => downloadingCount + queuedCount;
  
  bool get hasActiveDownloads => activeCount > 0;
  
  bool get allCompleted => totalTasks > 0 && completedCount == totalTasks;
}

/// Download statistics for monitoring and analytics
class DownloadStatistics {
  const DownloadStatistics({
    required this.totalDownloads,
    required this.successfulDownloads,
    required this.failedDownloads,
    required this.cancelledDownloads,
    required this.totalBytesDownloaded,
    required this.averageDownloadTime,
    required this.averageFileSize,
    required this.peakDownloadSpeed,
    required this.failureRate,
    this.lastUpdated,
  });

  final int totalDownloads;
  final int successfulDownloads;
  final int failedDownloads;
  final int cancelledDownloads;
  final int totalBytesDownloaded;
  final Duration averageDownloadTime;
  final int averageFileSize;
  final double peakDownloadSpeed;
  final double failureRate;
  final DateTime? lastUpdated;

  double get successRate => 
    totalDownloads > 0 ? successfulDownloads / totalDownloads : 0.0;

  String get formattedTotalSize => _formatBytes(totalBytesDownloaded);
  String get formattedAverageSize => _formatBytes(averageFileSize);
  String get formattedPeakSpeed => '${_formatBytes(peakDownloadSpeed.round())}/s';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
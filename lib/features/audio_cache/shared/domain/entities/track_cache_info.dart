import 'package:equatable/equatable.dart';
import 'cached_audio.dart';
import 'download_progress.dart';

/// Unified information about track cache status and download progress
/// This entity combines both status and progress for simplified stream handling
class TrackCacheInfo extends Equatable {
  const TrackCacheInfo({
    required this.trackId,
    required this.status,
    required this.progress,
  });

  final String trackId;
  final CacheStatus status;
  final DownloadProgress progress;

  /// Factory constructor for initial state
  factory TrackCacheInfo.initial(String trackId) {
    return TrackCacheInfo(
      trackId: trackId,
      status: CacheStatus.notCached,
      progress: DownloadProgress.notStarted(trackId),
    );
  }

  /// Factory constructor for cached state
  factory TrackCacheInfo.cached(String trackId) {
    return TrackCacheInfo(
      trackId: trackId,
      status: CacheStatus.cached,
      progress: DownloadProgress.completed(trackId, 0),
    );
  }

  /// Factory constructor for downloading state
  factory TrackCacheInfo.downloading(
    String trackId,
    DownloadProgress progress,
  ) {
    return TrackCacheInfo(
      trackId: trackId,
      status: CacheStatus.downloading,
      progress: progress,
    );
  }

  /// Factory constructor for failed state
  factory TrackCacheInfo.failed(String trackId, String error) {
    return TrackCacheInfo(
      trackId: trackId,
      status: CacheStatus.failed,
      progress: DownloadProgress.failed(trackId, error),
    );
  }

  /// Check if track is currently being downloaded
  bool get isDownloading => status == CacheStatus.downloading;

  /// Check if track is cached and ready for playback
  bool get isCached => status == CacheStatus.cached;

  /// Check if track download failed
  bool get isFailed => status == CacheStatus.failed;

  /// Check if track is not cached
  bool get isNotCached => status == CacheStatus.notCached;

  /// Get download progress percentage (0.0 to 1.0)
  double get progressPercentage => progress.progressPercentage;

  /// Get formatted progress text
  String get progressText => progress.formattedProgress;

  /// Get error message if failed
  String? get errorMessage => progress.errorMessage;

  /// Create a copy with updated status
  TrackCacheInfo copyWithStatus(CacheStatus newStatus) {
    return TrackCacheInfo(
      trackId: trackId,
      status: newStatus,
      progress: progress,
    );
  }

  /// Create a copy with updated progress
  TrackCacheInfo copyWithProgress(DownloadProgress newProgress) {
    return TrackCacheInfo(
      trackId: trackId,
      status: status,
      progress: newProgress,
    );
  }

  /// Create a copy with updated values
  TrackCacheInfo copyWith({
    String? trackId,
    CacheStatus? status,
    DownloadProgress? progress,
  }) {
    return TrackCacheInfo(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [trackId, status, progress];

  @override
  String toString() {
    return 'TrackCacheInfo(trackId: $trackId, status: $status, progress: $progress)';
  }
}

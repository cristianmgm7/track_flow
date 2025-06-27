import 'package:equatable/equatable.dart';

enum DownloadState {
  notStarted,
  queued,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadProgress extends Equatable {
  const DownloadProgress({
    required this.trackId,
    required this.state,
    required this.downloadedBytes,
    required this.totalBytes,
    this.downloadSpeed,
    this.estimatedTimeRemaining,
    this.errorMessage,
  });

  final String trackId;
  final DownloadState state;
  final int downloadedBytes;
  final int totalBytes;
  final double? downloadSpeed; // bytes per second
  final Duration? estimatedTimeRemaining;
  final String? errorMessage;

  double get progressPercentage {
    if (totalBytes == 0) return 0.0;
    return (downloadedBytes / totalBytes).clamp(0.0, 1.0);
  }

  bool get isCompleted => state == DownloadState.completed;
  bool get isDownloading => state == DownloadState.downloading;
  bool get isFailed => state == DownloadState.failed;
  bool get isCancelled => state == DownloadState.cancelled;
  bool get isActive => isDownloading || state == DownloadState.queued;

  String get formattedProgress {
    final percentage = (progressPercentage * 100).toStringAsFixed(1);
    return '$percentage%';
  }

  String get formattedSize {
    return '${_formatBytes(downloadedBytes)} / ${_formatBytes(totalBytes)}';
  }

  String get formattedSpeed {
    if (downloadSpeed == null) return '';
    return '${_formatBytes(downloadSpeed!.round())}/s';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  DownloadProgress copyWith({
    String? trackId,
    DownloadState? state,
    int? downloadedBytes,
    int? totalBytes,
    double? downloadSpeed,
    Duration? estimatedTimeRemaining,
    String? errorMessage,
  }) {
    return DownloadProgress(
      trackId: trackId ?? this.trackId,
      state: state ?? this.state,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory DownloadProgress.notStarted(String trackId) {
    return DownloadProgress(
      trackId: trackId,
      state: DownloadState.notStarted,
      downloadedBytes: 0,
      totalBytes: 0,
    );
  }

  factory DownloadProgress.queued(String trackId) {
    return DownloadProgress(
      trackId: trackId,
      state: DownloadState.queued,
      downloadedBytes: 0,
      totalBytes: 0,
    );
  }

  factory DownloadProgress.completed(String trackId, int totalBytes) {
    return DownloadProgress(
      trackId: trackId,
      state: DownloadState.completed,
      downloadedBytes: totalBytes,
      totalBytes: totalBytes,
    );
  }

  factory DownloadProgress.failed(String trackId, String errorMessage) {
    return DownloadProgress(
      trackId: trackId,
      state: DownloadState.failed,
      downloadedBytes: 0,
      totalBytes: 0,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    trackId,
    state,
    downloadedBytes,
    totalBytes,
    downloadSpeed,
    estimatedTimeRemaining,
    errorMessage,
  ];
}
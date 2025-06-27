import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

enum DownloadStatus {
  notStarted,
  queued,
  downloading,
  completed,
  failed,
  cancelled,
}

enum DownloadPriority {
  low,
  normal,
  high,
  urgent,
}

class DownloadTaskRequest {
  final String trackId;
  final String trackUrl;
  final String trackName;
  final DownloadPriority priority;

  const DownloadTaskRequest({
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
    this.priority = DownloadPriority.normal,
  });
}

class DownloadProgressInfo {
  final String trackId;
  final String trackName;
  final double progress;
  final DownloadStatus status;
  final String? errorMessage;

  const DownloadProgressInfo({
    required this.trackId,
    required this.trackName,
    required this.progress,
    required this.status,
    this.errorMessage,
  });
}

class QueueInfo {
  final int queuedCount;
  final int downloadingCount;
  final int completedCount;
  final int failedCount;
  final int totalTasks;

  const QueueInfo({
    required this.queuedCount,
    required this.downloadingCount,
    required this.completedCount,
    required this.failedCount,
    required this.totalTasks,
  });
}

/// Abstract service for managing downloads with queue, progress tracking, and batch operations
abstract class DownloadManagementService {
  /// Stream of download statuses for all tracks
  Stream<Map<String, DownloadStatus>> get downloadStatuses;

  /// Downloads a single track
  Future<Either<Failure, Unit>> downloadTrack(DownloadTaskRequest request);

  /// Downloads multiple tracks
  Future<Either<Failure, Unit>> downloadTracks(List<DownloadTaskRequest> requests);

  /// Cancels a specific download
  Future<Either<Failure, Unit>> cancelDownload(String trackId);

  /// Cancels all downloads
  Future<Either<Failure, Unit>> cancelAllDownloads();

  /// Gets current download status for a track
  DownloadStatus getDownloadStatus(String trackId);

  /// Gets download progress stream for a specific track
  Stream<DownloadProgressInfo> getDownloadProgress(String trackId);

  /// Gets current queue information
  QueueInfo getQueueInfo();

  /// Retries failed downloads
  Future<Either<Failure, Unit>> retryFailedDownloads();
}
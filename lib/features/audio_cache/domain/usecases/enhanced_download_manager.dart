import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path_usecase.dart';

/// Enhanced download manager that builds on top of the existing audio cache system
/// Adds batch downloads, queue management, and progress tracking
@Injectable()
class EnhancedDownloadManager {
  final AudioCacheRepository audioCacheRepository;
  final GetCachedAudioPath getCachedAudioPath;

  final Map<String, DownloadStatus> _downloadStatuses = {};
  final Map<String, StreamController<DownloadProgressInfo>>
  _progressControllers = {};
  final StreamController<Map<String, DownloadStatus>> _statusController =
      StreamController<Map<String, DownloadStatus>>.broadcast();

  final List<DownloadTask> _downloadQueue = [];
  bool _isProcessingQueue = false;
  static const int _maxConcurrentDownloads = 2;
  int _activeDownloads = 0;

  EnhancedDownloadManager(this.audioCacheRepository, this.getCachedAudioPath);

  /// Downloads a single track
  Future<Either<Failure, Unit>> downloadTrack({
    required String trackId,
    required String trackUrl,
    required String trackName,
    DownloadPriority priority = DownloadPriority.normal,
  }) async {
    try {
      // Check if already cached
      if (await _isTrackCached(trackUrl)) {
        _downloadStatuses[trackId] = DownloadStatus.completed;
        _notifyStatusUpdate();
        return const Right(unit);
      }

      // Add to queue
      final task = DownloadTask(
        trackId: trackId,
        trackUrl: trackUrl,
        trackName: trackName,
        priority: priority,
        addedAt: DateTime.now(),
      );

      _downloadQueue.add(task);
      _downloadQueue.sort(
        (a, b) => b.priority.index.compareTo(a.priority.index),
      );

      _downloadStatuses[trackId] = DownloadStatus.queued;
      _notifyStatusUpdate();

      _processQueue();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Downloads multiple tracks
  Future<Either<Failure, Unit>> downloadTracks(
    List<DownloadTaskRequest> requests,
  ) async {
    try {
      for (final request in requests) {
        await downloadTrack(
          trackId: request.trackId,
          trackUrl: request.trackUrl,
          trackName: request.trackName,
          priority: request.priority,
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Gets download status for a specific track
  DownloadStatus getDownloadStatus(String trackId) {
    return _downloadStatuses[trackId] ?? DownloadStatus.notStarted;
  }

  /// Stream of all download statuses
  Stream<Map<String, DownloadStatus>> get downloadStatuses =>
      _statusController.stream;

  /// Gets download progress for a specific track
  Stream<DownloadProgressInfo> getDownloadProgress(String trackId) {
    if (!_progressControllers.containsKey(trackId)) {
      _progressControllers[trackId] =
          StreamController<DownloadProgressInfo>.broadcast();
    }
    return _progressControllers[trackId]!.stream;
  }

  /// Cancels a specific download
  Future<Either<Failure, Unit>> cancelDownload(String trackId) async {
    try {
      // Remove from queue
      _downloadQueue.removeWhere((task) => task.trackId == trackId);

      // Update status
      if (_downloadStatuses[trackId] == DownloadStatus.downloading ||
          _downloadStatuses[trackId] == DownloadStatus.queued) {
        _downloadStatuses[trackId] = DownloadStatus.cancelled;
        _notifyStatusUpdate();
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Cancels all downloads
  Future<Either<Failure, Unit>> cancelAllDownloads() async {
    try {
      _downloadQueue.clear();

      for (final trackId in _downloadStatuses.keys.toList()) {
        if (_downloadStatuses[trackId] == DownloadStatus.downloading ||
            _downloadStatuses[trackId] == DownloadStatus.queued) {
          _downloadStatuses[trackId] = DownloadStatus.cancelled;
        }
      }

      _notifyStatusUpdate();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Retries failed downloads
  Future<Either<Failure, Unit>> retryFailedDownloads() async {
    try {
      final failedTracks =
          _downloadStatuses.entries
              .where((entry) => entry.value == DownloadStatus.failed)
              .map((entry) => entry.key)
              .toList();

      for (final trackId in failedTracks) {
        // Find the original task details (would need to store them)
        // For now, we'll just reset the status to allow manual retry
        _downloadStatuses[trackId] = DownloadStatus.notStarted;
      }

      _notifyStatusUpdate();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Gets queue information
  QueueInfo getQueueInfo() {
    final queued =
        _downloadStatuses.values
            .where((status) => status == DownloadStatus.queued)
            .length;
    final downloading =
        _downloadStatuses.values
            .where((status) => status == DownloadStatus.downloading)
            .length;
    final completed =
        _downloadStatuses.values
            .where((status) => status == DownloadStatus.completed)
            .length;
    final failed =
        _downloadStatuses.values
            .where((status) => status == DownloadStatus.failed)
            .length;

    return QueueInfo(
      queuedCount: queued,
      downloadingCount: downloading,
      completedCount: completed,
      failedCount: failed,
      totalTasks: _downloadStatuses.length,
    );
  }

  /// Checks if a track is cached using the existing cache system
  Future<bool> _isTrackCached(String trackUrl) async {
    try {
      final path = await getCachedAudioPath(trackUrl);
      return path.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Processes the download queue
  void _processQueue() {
    if (_isProcessingQueue || _activeDownloads >= _maxConcurrentDownloads) {
      return;
    }

    if (_downloadQueue.isEmpty) {
      return;
    }

    _isProcessingQueue = true;

    // Start next download
    final task = _downloadQueue.removeAt(0);
    _startDownload(task);

    _isProcessingQueue = false;

    // Continue processing if there are more tasks and slots available
    if (_downloadQueue.isNotEmpty &&
        _activeDownloads < _maxConcurrentDownloads) {
      _processQueue();
    }
  }

  /// Starts downloading a specific task
  Future<void> _startDownload(DownloadTask task) async {
    _activeDownloads++;
    _downloadStatuses[task.trackId] = DownloadStatus.downloading;
    _notifyStatusUpdate();

    try {
      await audioCacheRepository.getCachedAudioPath(
        task.trackUrl,
        onProgress: (progress) {
          _notifyProgressUpdate(
            task.trackId,
            DownloadProgressInfo(
              trackId: task.trackId,
              trackName: task.trackName,
              progress: progress,
              status: DownloadStatus.downloading,
            ),
          );
        },
      );

      _downloadStatuses[task.trackId] = DownloadStatus.completed;
      _notifyProgressUpdate(
        task.trackId,
        DownloadProgressInfo(
          trackId: task.trackId,
          trackName: task.trackName,
          progress: 1.0,
          status: DownloadStatus.completed,
        ),
      );
    } catch (e) {
      _downloadStatuses[task.trackId] = DownloadStatus.failed;
      _notifyProgressUpdate(
        task.trackId,
        DownloadProgressInfo(
          trackId: task.trackId,
          trackName: task.trackName,
          progress: 0.0,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _activeDownloads--;
      _notifyStatusUpdate();

      // Continue processing queue
      _processQueue();
    }
  }

  void _notifyStatusUpdate() {
    _statusController.add(Map.from(_downloadStatuses));
  }

  void _notifyProgressUpdate(String trackId, DownloadProgressInfo progress) {
    if (_progressControllers.containsKey(trackId)) {
      _progressControllers[trackId]!.add(progress);
    }
  }

  void dispose() {
    _statusController.close();
    for (final controller in _progressControllers.values) {
      controller.close();
    }
  }
}

class DownloadTask {
  final String trackId;
  final String trackUrl;
  final String trackName;
  final DownloadPriority priority;
  final DateTime addedAt;

  const DownloadTask({
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
    required this.priority,
    required this.addedAt,
  });
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

enum DownloadStatus {
  notStarted,
  queued,
  downloading,
  completed,
  failed,
  cancelled,
}

enum DownloadPriority { low, normal, high, urgent }

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

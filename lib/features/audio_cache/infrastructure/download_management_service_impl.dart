import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';

@Injectable(as: DownloadManagementService)
class DownloadManagementServiceImpl implements DownloadManagementService {
  final AudioCacheRepository _audioCacheRepository;
  final GetCachedAudioPath _getCachedAudioPath;

  final Map<String, DownloadStatus> _downloadStatuses = {};
  final Map<String, StreamController<DownloadProgressInfo>>
  _progressControllers = {};
  final StreamController<Map<String, DownloadStatus>> _statusController =
      StreamController<Map<String, DownloadStatus>>.broadcast();

  final List<_DownloadTask> _downloadQueue = [];
  bool _isProcessingQueue = false;
  static const int _maxConcurrentDownloads = 2;
  int _activeDownloads = 0;

  DownloadManagementServiceImpl(
    this._audioCacheRepository,
    this._getCachedAudioPath,
  );

  @override
  Stream<Map<String, DownloadStatus>> get downloadStatuses =>
      _statusController.stream;

  @override
  Future<Either<Failure, Unit>> downloadTrack(
    DownloadTaskRequest request,
  ) async {
    try {
      // Check if already cached
      if (await _isTrackCached(request.trackUrl)) {
        _downloadStatuses[request.trackId] = DownloadStatus.completed;
        _notifyStatusUpdate();
        return const Right(unit);
      }

      // Add to queue
      final task = _DownloadTask(
        trackId: request.trackId,
        trackUrl: request.trackUrl,
        trackName: request.trackName,
        priority: request.priority,
        addedAt: DateTime.now(),
      );

      _downloadQueue.add(task);
      _downloadQueue.sort(
        (a, b) => b.priority.index.compareTo(a.priority.index),
      );

      _downloadStatuses[request.trackId] = DownloadStatus.queued;
      _notifyStatusUpdate();
      _processQueue();

      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> downloadTracks(
    List<DownloadTaskRequest> requests,
  ) async {
    try {
      for (final request in requests) {
        await downloadTrack(request);
      }
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelDownload(String trackId) async {
    try {
      _downloadQueue.removeWhere((task) => task.trackId == trackId);

      if (_downloadStatuses[trackId] == DownloadStatus.downloading ||
          _downloadStatuses[trackId] == DownloadStatus.queued) {
        _downloadStatuses[trackId] = DownloadStatus.cancelled;
      }

      _notifyStatusUpdate();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
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
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> retryFailedDownloads() async {
    try {
      final failedTracks =
          _downloadStatuses.entries
              .where((entry) => entry.value == DownloadStatus.failed)
              .map((entry) => entry.key)
              .toList();

      for (final trackId in failedTracks) {
        _downloadStatuses[trackId] = DownloadStatus.notStarted;
      }

      _notifyStatusUpdate();
      return const Right(unit);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  DownloadStatus getDownloadStatus(String trackId) {
    return _downloadStatuses[trackId] ?? DownloadStatus.notStarted;
  }

  @override
  Stream<DownloadProgressInfo> getDownloadProgress(String trackId) {
    if (!_progressControllers.containsKey(trackId)) {
      _progressControllers[trackId] =
          StreamController<DownloadProgressInfo>.broadcast();
    }
    return _progressControllers[trackId]!.stream;
  }

  @override
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

  Future<bool> _isTrackCached(String trackUrl) async {
    try {
      final path = await _getCachedAudioPath(trackUrl);
      return path.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _processQueue() {
    if (_isProcessingQueue || _activeDownloads >= _maxConcurrentDownloads) {
      return;
    }

    if (_downloadQueue.isEmpty) {
      return;
    }

    _isProcessingQueue = true;
    final task = _downloadQueue.removeAt(0);
    _startDownload(task);
    _isProcessingQueue = false;

    if (_downloadQueue.isNotEmpty &&
        _activeDownloads < _maxConcurrentDownloads) {
      _processQueue();
    }
  }

  Future<void> _startDownload(_DownloadTask task) async {
    _activeDownloads++;
    _downloadStatuses[task.trackId] = DownloadStatus.downloading;
    _notifyStatusUpdate();

    try {
      await _audioCacheRepository.getCachedAudioPath(
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

class _DownloadTask {
  final String trackId;
  final String trackUrl;
  final String trackName;
  final DownloadPriority priority;
  final DateTime addedAt;

  const _DownloadTask({
    required this.trackId,
    required this.trackUrl,
    required this.trackName,
    required this.priority,
    required this.addedAt,
  });
}

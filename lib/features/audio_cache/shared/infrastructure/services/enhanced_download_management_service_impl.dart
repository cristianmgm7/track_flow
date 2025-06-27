import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_storage_repository.dart';
import '../../domain/services/enhanced_download_management_service.dart';
import '../../domain/value_objects/download_priority.dart';

@LazySingleton(as: EnhancedDownloadManagementService)
class EnhancedDownloadManagementServiceImpl implements EnhancedDownloadManagementService {
  final CacheStorageRepository _storageRepository;
  
  // Download queue management
  final List<DownloadAudioRequest> _downloadQueue = [];
  final Map<String, DownloadProgress> _activeDownloads = {};
  final Map<String, String> _failureReasons = {};
  
  // Settings
  int _maxConcurrentDownloads = 2;
  Duration _downloadTimeout = const Duration(minutes: 10);
  int _maxRetryAttempts = 3;
  bool _automaticRetryEnabled = true;
  
  // Stream controllers
  final StreamController<List<DownloadProgress>> _progressController =
      StreamController<List<DownloadProgress>>.broadcast();
  final StreamController<Map<String, DownloadState>> _statesController =
      StreamController<Map<String, DownloadState>>.broadcast();

  // Statistics
  final DownloadStatistics _statistics = DownloadStatistics(
    totalDownloads: 0,
    successfulDownloads: 0,
    failedDownloads: 0,
    cancelledDownloads: 0,
    totalBytesDownloaded: 0,
    averageDownloadTime: Duration.zero,
    averageFileSize: 0,
    peakDownloadSpeed: 0.0,
    failureRate: 0.0,
    lastUpdated: DateTime.now(),
  );

  EnhancedDownloadManagementServiceImpl({
    required CacheStorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

  @override
  Future<Either<CacheFailure, Unit>> downloadAudio(
    String trackId,
    String audioUrl,
    String trackName, {
    DownloadPriority priority = DownloadPriority.normal,
    void Function(DownloadProgress)? progressCallback,
  }) async {
    final request = DownloadAudioRequest(
      trackId: trackId,
      audioUrl: audioUrl,
      trackName: trackName,
      priority: priority,
    );

    return await enqueueMultipleDownloads([request]);
  }

  @override
  Future<Either<CacheFailure, Unit>> downloadMultipleAudios(
    Map<String, DownloadAudioRequest> requests,
  ) async {
    return await enqueueMultipleDownloads(requests.values.toList());
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId) async {
    try {
      // Remove from queue
      _downloadQueue.removeWhere((request) => request.trackId == trackId);
      
      // Cancel active download
      if (_activeDownloads.containsKey(trackId)) {
        _activeDownloads[trackId] = _activeDownloads[trackId]!.copyWith(
          state: DownloadState.cancelled,
        );
        
        // Delegate to storage repository for actual cancellation
        final result = await _storageRepository.cancelDownload(trackId);
        
        _activeDownloads.remove(trackId);
        _updateStreams();
        
        return result;
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to cancel download: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelAllDownloads() async {
    try {
      final trackIds = [..._activeDownloads.keys, ..._downloadQueue.map((r) => r.trackId)];
      
      for (final trackId in trackIds) {
        await cancelDownload(trackId);
      }
      
      _downloadQueue.clear();
      _activeDownloads.clear();
      _updateStreams();
      
      return const Right(unit);
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to cancel all downloads: $e',
          trackId: 'all',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId) async {
    if (_activeDownloads.containsKey(trackId)) {
      _activeDownloads[trackId] = _activeDownloads[trackId]!.copyWith(
        state: DownloadState.cancelled, // Using cancelled as paused for now
      );
      _updateStreams();
    }
    
    return await _storageRepository.pauseDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId) async {
    // Find the request in failed/paused state and re-queue it
    // For now, simplified implementation
    return await _storageRepository.resumeDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> retryDownload(String trackId) async {
    try {
      // Find the original request (simplified - would need better tracking)
      if (_failureReasons.containsKey(trackId)) {
        // Create a retry request (would need to store original request data)
        // For now, simplified implementation
        _failureReasons.remove(trackId);
        return const Right(unit);
      }
      
      return Left(
        ValidationCacheFailure(
          message: 'No failed download found for track',
          field: 'trackId',
          value: trackId,
        ),
      );
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to retry download: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> retryAllFailedDownloads() async {
    try {
      final failedTrackIds = List<String>.from(_failureReasons.keys);
      
      for (final trackId in failedTrackIds) {
        await retryDownload(trackId);
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to retry all failed downloads: $e',
          trackId: 'all',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, EnhancedQueueInfo>> getQueueInfo() async {
    try {
      final queuedCount = _downloadQueue.length;
      final downloadingCount = _activeDownloads.values
          .where((p) => p.isDownloading)
          .length;
      final completedCount = _activeDownloads.values
          .where((p) => p.isCompleted)
          .length;
      final failedCount = _failureReasons.length;
      final totalTasks = queuedCount + downloadingCount + completedCount + failedCount;

      return Right(
        EnhancedQueueInfo(
          queuedCount: queuedCount,
          downloadingCount: downloadingCount,
          completedCount: completedCount,
          failedCount: failedCount,
          pausedCount: 0, // Not implemented yet
          cancelledCount: 0, // Would need tracking
          totalTasks: totalTasks,
          estimatedTimeRemaining: _calculateEstimatedTime(),
          averageDownloadSpeed: _calculateAverageSpeed(),
          currentBandwidthUsage: _calculateCurrentBandwidth(),
        ),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get queue info: $e',
          field: 'queue',
          value: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int?>> getQueuePosition(String trackId) async {
    try {
      final index = _downloadQueue.indexWhere((request) => request.trackId == trackId);
      return Right(index >= 0 ? index : null);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get queue position: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> prioritizeDownload(String trackId) async {
    try {
      final requestIndex = _downloadQueue.indexWhere((r) => r.trackId == trackId);
      if (requestIndex > 0) {
        final request = _downloadQueue.removeAt(requestIndex);
        _downloadQueue.insert(0, request);
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to prioritize download: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> changeDownloadPriority(
    String trackId,
    DownloadPriority newPriority,
  ) async {
    try {
      final requestIndex = _downloadQueue.indexWhere((r) => r.trackId == trackId);
      if (requestIndex >= 0) {
        final request = _downloadQueue[requestIndex];
        _downloadQueue[requestIndex] = DownloadAudioRequest(
          trackId: request.trackId,
          audioUrl: request.audioUrl,
          trackName: request.trackName,
          priority: newPriority,
          referenceId: request.referenceId,
        );
        
        // Re-sort queue by priority
        _sortQueueByPriority();
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to change download priority: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> clearCompletedDownloads() async {
    try {
      _activeDownloads.removeWhere((key, progress) => progress.isCompleted);
      _updateStreams();
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to clear completed downloads: $e',
          field: 'completed',
          value: null,
        ),
      );
    }
  }

  @override
  int get maxConcurrentDownloads => _maxConcurrentDownloads;

  @override
  Future<Either<CacheFailure, Unit>> setMaxConcurrentDownloads(int max) async {
    try {
      _maxConcurrentDownloads = max.clamp(1, 10);
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set max concurrent downloads: $e',
          field: 'maxConcurrentDownloads',
          value: max,
        ),
      );
    }
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    return _progressController.stream
        .map((progressList) => progressList.firstWhere(
          (p) => p.trackId == trackId,
          orElse: () => DownloadProgress.notStarted(trackId),
        ));
  }

  @override
  Stream<List<DownloadProgress>> watchAllDownloadProgress() {
    return _progressController.stream;
  }

  @override
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(String trackId) async {
    try {
      return Right(_activeDownloads[trackId]);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get download progress: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, DownloadProgress>>> getMultipleDownloadProgress(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, DownloadProgress> progressMap = {};
      
      for (final trackId in trackIds) {
        final progress = _activeDownloads[trackId];
        if (progress != null) {
          progressMap[trackId] = progress;
        }
      }
      
      return Right(progressMap);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get multiple download progress: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, DownloadState>> getDownloadState(String trackId) async {
    try {
      final progress = _activeDownloads[trackId];
      if (progress != null) {
        return Right(progress.state);
      }
      
      // Check if in queue
      if (_downloadQueue.any((r) => r.trackId == trackId)) {
        return const Right(DownloadState.queued);
      }
      
      return const Right(DownloadState.notStarted);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get download state: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, DownloadState>>> getMultipleDownloadStates(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, DownloadState> statesMap = {};
      
      for (final trackId in trackIds) {
        final stateResult = await getDownloadState(trackId);
        stateResult.fold(
          (failure) => statesMap[trackId] = DownloadState.failed,
          (state) => statesMap[trackId] = state,
        );
      }
      
      return Right(statesMap);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get multiple download states: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Stream<Map<String, DownloadState>> watchDownloadStates() {
    return _statesController.stream;
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksByState(DownloadState state) async {
    try {
      final trackIds = <String>[];
      
      for (final entry in _activeDownloads.entries) {
        if (entry.value.state == state) {
          trackIds.add(entry.key);
        }
      }
      
      return Right(trackIds);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get tracks by state: $e',
          field: 'state',
          value: state,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> enqueueMultipleDownloads(
    List<DownloadAudioRequest> requests,
  ) async {
    try {
      _downloadQueue.addAll(requests);
      _sortQueueByPriority();
      
      // Start downloads if capacity available
      _processQueue();
      
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to enqueue multiple downloads: $e',
          field: 'requests',
          value: requests,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> removeMultipleFromQueue(List<String> trackIds) async {
    try {
      _downloadQueue.removeWhere((request) => trackIds.contains(request.trackId));
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to remove multiple from queue: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelMultipleDownloads(List<String> trackIds) async {
    try {
      for (final trackId in trackIds) {
        await cancelDownload(trackId);
      }
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to cancel multiple downloads: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, DownloadStatistics>> getDownloadStatistics() async {
    try {
      return Right(_statistics);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get download statistics: $e',
          field: 'statistics',
          value: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, String>>> getFailureReasons() async {
    try {
      return Right(Map<String, String>.from(_failureReasons));
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get failure reasons: $e',
          field: 'failureReasons',
          value: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, double>> getAverageDownloadSpeed() async {
    try {
      return Right(_calculateAverageSpeed());
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get average download speed: $e',
          field: 'averageSpeed',
          value: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, double>> getDownloadCompletionRate() async {
    try {
      final totalDownloads = _statistics.totalDownloads;
      if (totalDownloads > 0) {
        return Right(_statistics.successfulDownloads / totalDownloads);
      }
      return const Right(0.0);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get download completion rate: $e',
          field: 'completionRate',
          value: null,
        ),
      );
    }
  }

  // Configuration getters/setters
  @override
  Duration get downloadTimeout => _downloadTimeout;

  @override
  Future<Either<CacheFailure, Unit>> setDownloadTimeout(Duration timeout) async {
    try {
      _downloadTimeout = timeout;
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set download timeout: $e',
          field: 'downloadTimeout',
          value: timeout,
        ),
      );
    }
  }

  @override
  int get maxRetryAttempts => _maxRetryAttempts;

  @override
  Future<Either<CacheFailure, Unit>> setMaxRetryAttempts(int attempts) async {
    try {
      _maxRetryAttempts = attempts.clamp(0, 10);
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set max retry attempts: $e',
          field: 'maxRetryAttempts',
          value: attempts,
        ),
      );
    }
  }

  @override
  bool get automaticRetryEnabled => _automaticRetryEnabled;

  @override
  Future<Either<CacheFailure, Unit>> setAutomaticRetryEnabled(bool enabled) async {
    try {
      _automaticRetryEnabled = enabled;
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set automatic retry enabled: $e',
          field: 'automaticRetryEnabled',
          value: enabled,
        ),
      );
    }
  }

  // Private helper methods
  void _sortQueueByPriority() {
    _downloadQueue.sort((a, b) => b.priority.value.compareTo(a.priority.value));
  }

  void _processQueue() {
    final currentDownloading = _activeDownloads.values
        .where((p) => p.isDownloading)
        .length;
    
    final availableSlots = _maxConcurrentDownloads - currentDownloading;
    
    for (int i = 0; i < availableSlots && _downloadQueue.isNotEmpty; i++) {
      final request = _downloadQueue.removeAt(0);
      _startDownload(request);
    }
  }

  void _startDownload(DownloadAudioRequest request) {
    _activeDownloads[request.trackId] = DownloadProgress.queued(request.trackId);
    
    // Start actual download (simplified)
    // In real implementation, this would use the storage repository
    _storageRepository.downloadAndStoreAudio(
      request.trackId,
      request.audioUrl,
      progressCallback: (progress) {
        _activeDownloads[request.trackId] = progress;
        _updateStreams();
      },
    ).then((result) {
      result.fold(
        (failure) {
          _failureReasons[request.trackId] = failure.message;
          _activeDownloads[request.trackId] = DownloadProgress.failed(
            request.trackId,
            failure.message,
          );
        },
        (cachedAudio) {
          _activeDownloads[request.trackId] = DownloadProgress.completed(
            request.trackId,
            cachedAudio.fileSizeBytes,
          );
        },
      );
      
      _updateStreams();
      _processQueue(); // Process next in queue
    });
  }

  void _updateStreams() {
    _progressController.add(_activeDownloads.values.toList());
    
    final statesMap = <String, DownloadState>{};
    for (final entry in _activeDownloads.entries) {
      statesMap[entry.key] = entry.value.state;
    }
    _statesController.add(statesMap);
  }

  Duration? _calculateEstimatedTime() {
    // Simplified calculation
    final activeDownloads = _activeDownloads.values.where((p) => p.isDownloading);
    if (activeDownloads.isEmpty) return null;
    
    // Would need more sophisticated calculation based on current speeds
    return const Duration(minutes: 5);
  }

  double _calculateAverageSpeed() {
    final activeDownloads = _activeDownloads.values.where((p) => p.isDownloading);
    if (activeDownloads.isEmpty) return 0.0;
    
    final totalSpeed = activeDownloads
        .map((p) => p.downloadSpeed ?? 0.0)
        .fold(0.0, (sum, speed) => sum + speed);
    
    return totalSpeed / activeDownloads.length;
  }

  double _calculateCurrentBandwidth() {
    return _activeDownloads.values
        .where((p) => p.isDownloading)
        .map((p) => p.downloadSpeed ?? 0.0)
        .fold(0.0, (sum, speed) => sum + speed);
  }

  void dispose() {
    _progressController.close();
    _statesController.close();
  }
}
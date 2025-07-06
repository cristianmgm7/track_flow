import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/audio_download_repository.dart';
import '../datasources/cache_storage_remote_data_source.dart';

@LazySingleton(as: AudioDownloadRepository)
class AudioDownloadRepositoryImpl implements AudioDownloadRepository {
  final CacheStorageRemoteDataSource _remoteDataSource;

  // Active downloads tracking for progress and cancellation
  final Map<AudioTrackId, String> _activeDownloads =
      {}; // trackId -> downloadId
  final Map<AudioTrackId, StreamController<DownloadProgress>>
  _progressControllers = {};

  AudioDownloadRepositoryImpl({
    required CacheStorageRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<CacheFailure, String>> downloadAudio(
    AudioTrackId trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      // Create progress controller for this download
      final progressController = StreamController<DownloadProgress>.broadcast();
      _progressControllers[trackId] = progressController;

      // Replace hardcoded temp path with a writable temp directory
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          '${tempDir.path}/audio_cache_${trackId.value}_${DateTime.now().millisecondsSinceEpoch}.tmp';

      // Download using remote data source
      String? downloadId;
      final downloadResult = await _remoteDataSource.downloadAudio(
        audioUrl: audioUrl,
        localFilePath: tempFilePath,
        onProgress: (progress) {
          // Store download ID for cancellation tracking
          if (downloadId == null) {
            downloadId =
                progress.trackId; // This is the download ID from remote source
            _activeDownloads[trackId] = downloadId!;
          }

          // Map download ID back to trackId for consistency
          final trackProgress = progress.copyWith(trackId: trackId.value);
          progressCallback?.call(trackProgress);
          progressController.add(trackProgress);
        },
      );

      return downloadResult.fold(
        (failure) {
          final failedProgress = DownloadProgress.failed(
            trackId.value,
            failure.message,
          );
          progressCallback?.call(failedProgress);
          progressController.add(failedProgress);
          _cleanupDownload(trackId);
          return Left(failure);
        },
        (downloadedFile) {
          final completedProgress = DownloadProgress.completed(
            trackId.value,
            downloadedFile.lengthSync(),
          );
          progressCallback?.call(completedProgress);
          progressController.add(completedProgress);

          // Clean up tracking but keep the file for storage repository
          _cleanupDownload(trackId);

          return Right(downloadedFile.path);
        },
      );
    } catch (e) {
      final failedProgress = DownloadProgress.failed(
        trackId.value,
        e.toString(),
      );
      progressCallback?.call(failedProgress);

      // Emit to progress controller if it exists
      _progressControllers[trackId]?.add(failedProgress);
      _cleanupDownload(trackId);

      return Left(
        DownloadCacheFailure(
          message: 'Failed to download audio: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<AudioTrackId, String>>>
  downloadMultipleAudios(
    Map<AudioTrackId, String> trackUrlPairs, {
    void Function(AudioTrackId trackId, DownloadProgress)? progressCallback,
  }) async {
    try {
      final Map<AudioTrackId, String> downloadedFiles = {};

      for (final entry in trackUrlPairs.entries) {
        final trackId = entry.key;
        final audioUrl = entry.value;

        final result = await downloadAudio(
          trackId,
          audioUrl,
          progressCallback: (progress) {
            progressCallback?.call(trackId, progress);
          },
        );

        result.fold(
          (failure) {
            // Log failure but continue with other downloads
          },
          (filePath) {
            downloadedFiles[trackId] = filePath;
          },
        );
      }

      return Right(downloadedFiles);
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to download multiple audios: $e',
          trackId: 'multiple',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(
    AudioTrackId trackId,
  ) async {
    try {
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        final result = await _remoteDataSource.cancelDownload(downloadId);
        return result.fold((failure) => Left(failure), (_) {
          // Emit cancelled progress
          final cancelledProgress = DownloadProgress.failed(
            trackId.value,
            'Download cancelled by user',
          );
          _progressControllers[trackId]?.add(cancelledProgress);

          _cleanupDownload(trackId);
          return const Right(unit);
        });
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'No active download found for track',
            field: 'trackId',
            value: trackId.value,
          ),
        );
      }
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to cancel download: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> pauseDownload(AudioTrackId trackId) async {
    try {
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        // For Firebase Storage, we need to cancel and store progress for later resume
        final result = await _remoteDataSource.cancelDownload(downloadId);
        return result.fold((failure) => Left(failure), (_) {
          // Mark as paused in progress controller
          final pausedProgress = DownloadProgress(
            trackId: trackId.value,
            state:
                DownloadState
                    .downloading, // Keep as downloading but store pause state internally
            downloadedBytes: 0, // We'd need to store this from last progress
            totalBytes: 0,
          );
          _progressControllers[trackId]?.add(pausedProgress);

          // Don't cleanup yet - keep for resume
          return const Right(unit);
        });
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'No active download found for track',
            field: 'trackId',
            value: trackId.value,
          ),
        );
      }
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to pause download: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> resumeDownload(
    AudioTrackId trackId,
  ) async {
    try {
      // For Firebase Storage, resuming means starting a new download
      // In a full implementation, we'd need to store the original URL and progress
      // For now, return an error indicating resume is not supported with current implementation
      return Left(
        ValidationCacheFailure(
          message:
              'Download resuming not supported with current Firebase Storage implementation. Please restart download.',
          field: 'trackId',
          value: trackId.value,
        ),
      );
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to resume download: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(
    AudioTrackId trackId,
  ) async {
    try {
      // Check if download is currently active
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        // Return a basic progress indicating it's active
        // In a full implementation, we'd store last known progress
        return Right(
          DownloadProgress(
            trackId: trackId.value,
            state: DownloadState.downloading,
            downloadedBytes: 0,
            totalBytes: 0,
          ),
        );
      }

      // No active download
      return const Right(null);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get download progress: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<DownloadProgress>>>
  getActiveDownloads() async {
    try {
      final activeDownloads = <DownloadProgress>[];

      for (final entry in _activeDownloads.entries) {
        final trackId = entry.key;

        // Create a basic progress object for each active download
        activeDownloads.add(
          DownloadProgress(
            trackId: trackId.value,
            state: DownloadState.downloading,
            downloadedBytes: 0, // We'd need to store actual progress
            totalBytes: 0,
          ),
        );
      }

      return Right(activeDownloads);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get active downloads: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(AudioTrackId trackId) {
    // Return existing controller stream or create a new one
    final controller = _progressControllers[trackId];
    if (controller != null) {
      return controller.stream;
    } else {
      // Create a new controller for future downloads
      final newController = StreamController<DownloadProgress>.broadcast();
      _progressControllers[trackId] = newController;
      return newController.stream;
    }
  }

  @override
  Stream<List<DownloadProgress>> watchActiveDownloads() {
    // Create a combined stream of all active downloads
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      final activeDownloads = <DownloadProgress>[];
      for (final trackId in _activeDownloads.keys) {
        // For active downloads, we could track their last known progress
        // For now, just indicate they're active
        activeDownloads.add(
          DownloadProgress(
            trackId: trackId.value,
            state: DownloadState.downloading,
            downloadedBytes: 0,
            totalBytes: 0,
          ),
        );
      }
      return activeDownloads;
    }).distinct();
  }

  /// Cleanup download tracking resources
  void _cleanupDownload(AudioTrackId trackId) {
    _activeDownloads.remove(trackId);
    _progressControllers[trackId]?.close();
    _progressControllers.remove(trackId);
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _activeDownloads.clear();
  }
}

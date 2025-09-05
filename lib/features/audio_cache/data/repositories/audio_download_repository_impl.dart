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

  // Minimal internal progress stream per track (only while downloading)
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
      final downloadResult = await _remoteDataSource.downloadAudio(
        audioUrl: audioUrl,
        localFilePath: tempFilePath,
        onProgress: (progress) {
          // Map remote progress back to this trackId
          final mapped = progress.copyWith(trackId: trackId.value);
          progressCallback?.call(mapped);
          progressController.add(mapped);
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
          _cleanup(trackId);
          return Left(failure);
        },
        (downloadedFile) {
          final completedProgress = DownloadProgress.completed(
            trackId.value,
            downloadedFile.lengthSync(),
          );
          progressCallback?.call(completedProgress);
          progressController.add(completedProgress);

          // Clean up controller but keep file for storage repository
          _cleanup(trackId);

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
      _cleanup(trackId);

      return Left(
        DownloadCacheFailure(
          message: 'Failed to download audio: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  /// Cleanup progress resources
  void _cleanup(AudioTrackId trackId) {
    _progressControllers[trackId]?.close();
    _progressControllers.remove(trackId);
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
}

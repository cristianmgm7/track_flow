import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
// Removed temp directory usage; we download directly to final cache path

import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/audio_download_repository.dart';
import '../datasources/cache_storage_remote_data_source.dart';
import '../datasources/cache_storage_local_data_source.dart';

@LazySingleton(as: AudioDownloadRepository)
class AudioDownloadRepositoryImpl implements AudioDownloadRepository {
  final CacheStorageRemoteDataSource _remoteDataSource;
  final CacheStorageLocalDataSource _localDataSource;

  AudioDownloadRepositoryImpl({
    required CacheStorageRemoteDataSource remoteDataSource,
    required CacheStorageLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<CacheFailure, String>> downloadAudio(
    AudioTrackId trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      // No internal controller; just forward to callback

      // Compute final destination path in the fixed cache directory
      final cacheKey = _localDataSource.generateCacheKey(
        trackId.value,
        audioUrl,
      );
      final destPathEither = await _localDataSource.getFilePathFromCacheKey(
        cacheKey,
      );
      final destPath = await destPathEither.fold(
        (failure) => Future.error(failure.message),
        (p) async => p,
      );

      // Download using remote data source
      final downloadResult = await _remoteDataSource.downloadAudio(
        audioUrl: audioUrl,
        localFilePath: destPath,
        onProgress: (progress) {
          // Map remote progress back to this trackId
          final mapped = progress.copyWith(trackId: trackId.value);
          progressCallback?.call(mapped);
          // no-op beyond callback
        },
      );

      return downloadResult.fold(
        (failure) {
          final failedProgress = DownloadProgress.failed(
            trackId.value,
            failure.message,
          );
          progressCallback?.call(failedProgress);
          // no-op beyond callback
          return Left(failure);
        },
        (downloadedFile) {
          final completedProgress = DownloadProgress.completed(
            trackId.value,
            downloadedFile.lengthSync(),
          );
          progressCallback?.call(completedProgress);
          // no-op beyond callback

          return Right(downloadedFile.path);
        },
      );
    } catch (e) {
      final failedProgress = DownloadProgress.failed(
        trackId.value,
        e.toString(),
      );
      progressCallback?.call(failedProgress);

      return Left(
        DownloadCacheFailure(
          message: 'Failed to download audio: $e',
          trackId: trackId.value,
        ),
      );
    }
  }

  // No internal resources to dispose
  void dispose() {}
}

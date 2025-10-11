import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/audio/domain/audio_file_repository.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/entities/download_progress.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_download_repository.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart' as cache_failures;

@LazySingleton(as: AudioDownloadRepository)
class AudioDownloadRepositoryImpl implements AudioDownloadRepository {
  final AudioFileRepository _audioFileRepository;

  AudioDownloadRepositoryImpl({
    required AudioFileRepository audioFileRepository,
  }) : _audioFileRepository = audioFileRepository;

  @override
  Future<Either<cache_failures.CacheFailure, String>> downloadAudio(
    AudioTrackId trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      // Get cache directory for destination
      final tempDir = await getTemporaryDirectory();
      final cacheKey = _generateCacheKey(trackId.value, audioUrl);
      final fileName = '$cacheKey.mp3';
      final localPath = '${tempDir.path}/$fileName';

      // Use unified service with caching
      final result = await _audioFileRepository.downloadAudioFile(
        storageUrl: audioUrl,
        localPath: localPath,
        trackId: trackId.value,
        onProgress: progressCallback,
      );

      return result.fold(
        (failure) => Left(_convertFailure(failure, trackId.value)),
        (filePath) => Right(filePath),
      );
    } catch (e) {
      return Left(cache_failures.DownloadCacheFailure(
        message: 'Download failed: $e',
        trackId: trackId.value,
      ));
    }
  }

  // Helper to generate cache key
  String _generateCacheKey(String trackId, String url) {
    return '${trackId}_${url.hashCode.abs()}';
  }

  // Helper to convert Failure to CacheFailure
  cache_failures.CacheFailure _convertFailure(Failure failure, String trackId) {
    if (failure is NetworkFailure) {
      return cache_failures.NetworkCacheFailure(
        message: failure.message,
        statusCode: 0,
      );
    }
    if (failure is StorageFailure) {
      return cache_failures.StorageCacheFailure(
        message: failure.message,
        type: cache_failures.StorageFailureType.diskError,
      );
    }
    return cache_failures.DownloadCacheFailure(
      message: failure.message,
      trackId: trackId,
    );
  }

  // No internal resources to dispose
  void dispose() {}
}

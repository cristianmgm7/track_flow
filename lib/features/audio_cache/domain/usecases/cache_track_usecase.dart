import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

import '../failures/cache_failure.dart' as cache_failures;
import '../repositories/audio_storage_repository.dart';
import '../../../../core/audio/domain/audio_file_repository.dart';
import '../../../../core/infrastructure/domain/directory_service.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../core/error/failures.dart';

@injectable
class CacheTrackUseCase {
  final AudioFileRepository _audioFileRepository;
  final AudioStorageRepository _audioStorageRepository;
  final DirectoryService _directoryService;

  CacheTrackUseCase(
    this._audioFileRepository,
    this._audioStorageRepository,
    this._directoryService,
  );

  /// Cache a single track for individual playback
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  /// [versionId] - Unique identifier for the track version
  ///
  /// Returns success or specific failure for error handling
  Future<Either<cache_failures.CacheFailure, Unit>> call({
    required String trackId,
    required String audioUrl,
    required String versionId,
  }) async {
    // Validate inputs
    if (trackId.isEmpty) {
      return Left(
        cache_failures.ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }

    if (audioUrl.isEmpty) {
      return Left(
        cache_failures.ValidationCacheFailure(
          message: 'Audio URL cannot be empty',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    if (versionId.isEmpty) {
      return Left(
        cache_failures.ValidationCacheFailure(
          message: 'Version ID cannot be empty',
          field: 'versionId',
          value: versionId,
        ),
      );
    }

    // Validate URL format (basic validation)
    final uri = Uri.tryParse(audioUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      return Left(
        cache_failures.ValidationCacheFailure(
          message: 'Invalid audio URL format',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    try {
      // Get cache directory and create local path
      final cacheDirResult = await _directoryService.getDirectory(DirectoryType.audioCache);
      final localPath = cacheDirResult.fold(
        (failure) => null,
        (dir) => '${dir.path}/${trackId}_${audioUrl.hashCode.abs()}.mp3',
      );

      if (localPath == null) {
        return Left(
          cache_failures.StorageCacheFailure(
            message: 'Failed to get cache directory',
            type: cache_failures.StorageFailureType.diskError,
          ),
        );
      }

      // Download audio file
      final downloadResult = await _audioFileRepository.downloadAudioFile(
        storageUrl: audioUrl,
        localPath: localPath,
        trackId: trackId,
        versionId: versionId,
      );

      return await downloadResult.fold(
        (failure) => Left(_convertFailureToCacheFailure(failure)),
        (filePath) async {
          // Store audio in cache repository
          final storeResult = await _audioStorageRepository.storeAudio(
            AudioTrackId.fromUniqueString(trackId),
            TrackVersionId.fromUniqueString(versionId),
            File(filePath),
          );
          return storeResult.fold(
            (failure) => Left(failure),
            (_) => const Right(unit),
          );
        },
      );
    } catch (e) {
      return Left(
        cache_failures.ValidationCacheFailure(
          message: 'Unexpected error while caching track: $e',
          field: 'cache_operation',
          value: {'trackId': trackId, 'audioUrl': audioUrl},
        ),
      );
    }
  }

  /// Convert core Failure to CacheFailure
  cache_failures.CacheFailure _convertFailureToCacheFailure(Failure failure) {
    if (failure.message.contains('network') || failure.message.contains('Network')) {
      return cache_failures.NetworkCacheFailure(
        message: failure.message,
        statusCode: 0,
      );
    }
    if (failure.message.contains('storage') || failure.message.contains('disk')) {
      return cache_failures.StorageCacheFailure(
        message: failure.message,
        type: cache_failures.StorageFailureType.diskError,
      );
    }
    return cache_failures.ValidationCacheFailure(
      message: failure.message,
      field: 'download',
      value: null,
    );
  }
}

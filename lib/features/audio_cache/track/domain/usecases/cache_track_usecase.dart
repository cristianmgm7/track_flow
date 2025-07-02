import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_facade_repository.dart';

@injectable
class CacheTrackUseCase {
  final CacheStorageFacadeRepository _cacheStorageRepository;

  CacheTrackUseCase(this._cacheStorageRepository);

  /// Cache a single track for individual playback
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  ///
  /// Returns success or specific failure for error handling
  Future<Either<CacheFailure, Unit>> call({
    required String trackId,
    required String audioUrl,
  }) async {
    // Validate inputs
    if (trackId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }

    if (audioUrl.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Audio URL cannot be empty',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    // Validate URL format (basic validation)
    final uri = Uri.tryParse(audioUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      return Left(
        ValidationCacheFailure(
          message: 'Invalid audio URL format',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    try {
      final result = await _cacheStorageRepository.downloadAndStoreAudio(
        trackId,
        audioUrl,
      );

      return result.fold(
        (failure) => Left(failure),
        (cachedAudio) => const Right(unit),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while caching track: $e',
          field: 'cache_operation',
          value: {'trackId': trackId, 'audioUrl': audioUrl},
        ),
      );
    }
  }

  /// Cache multiple tracks
  Future<Either<CacheFailure, Unit>> cacheMultiple({
    required Map<String, String> trackUrlPairs, // trackId -> audioUrl
  }) async {
    try {
      final result = await _cacheStorageRepository.downloadAndStoreMultipleAudios(
        trackUrlPairs,
      );

      return result.fold(
        (failure) => Left(failure),
        (cachedAudios) => const Right(unit),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while caching multiple tracks: $e',
          field: 'cache_operation',
          value: {'trackUrlPairs': trackUrlPairs},
        ),
      );
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_facade_repository.dart';
import '../../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../../../../../core/entities/unique_id.dart';

@injectable
class CachePlaylistUseCase {
  final CacheStorageFacadeRepository _cacheStorageRepository;
  final AudioTrackRepository _audioTrackRepository;

  CachePlaylistUseCase(
    this._cacheStorageRepository,
    this._audioTrackRepository,
  );

  /// Cache all tracks in a playlist
  Future<Either<CacheFailure, Unit>> call({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    // Validate inputs
    if (playlistId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Playlist ID cannot be empty',
          field: 'playlistId',
          value: playlistId,
        ),
      );
    }

    if (trackIds.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track IDs cannot be empty',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }

    final trackUrlPairs = <String, String>{};
    for (final trackId in trackIds) {
      try {
        final trackOrFailure = await _audioTrackRepository.getTrackById(
          AudioTrackId.fromUniqueString(trackId),
        );
        trackOrFailure.fold(
          (failure) {
            // Optionally handle error per track (skip or log)
          },
          (track) {
            if (track.url.isNotEmpty) {
              trackUrlPairs[trackId] = track.url;
            }
          },
        );
      } catch (e) {
        // Optionally handle error per track
      }
    }

    if (trackUrlPairs.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message:
              'No valid audio URLs could be resolved for the provided track IDs',
          field: 'trackUrlPairs',
          value: trackUrlPairs,
        ),
      );
    }

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
          message: 'Unexpected error while caching playlist: $e',
          field: 'cache_operation',
          value: {'playlistId': playlistId, 'trackCount': trackUrlPairs.length},
        ),
      );
    }
  }

  /// Cache a single track from playlist
  Future<Either<CacheFailure, Unit>> cachePlaylistTrack({
    required String playlistId,
    required String trackId,
    required String audioUrl,
  }) async {
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
          message: 'Unexpected error while caching playlist track: $e',
          field: 'cache_operation',
          value: {
            'playlistId': playlistId,
            'trackId': trackId,
            'audioUrl': audioUrl,
          },
        ),
      );
    }
  }
}

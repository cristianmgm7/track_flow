import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';

@injectable
class RemovePlaylistCacheUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  RemovePlaylistCacheUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, Unit>> call({
    required String playlistId,
    required List<String> trackIds,
  }) async {
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
          message: 'Track IDs list cannot be empty',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }

    try {
      final referenceId = 'playlist_$playlistId';
      
      return await _cacheOrchestrationService.removeMultipleFromCache(
        trackIds,
        referenceId,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing playlist cache: $e',
          field: 'cache_operation',
          value: {'playlistId': playlistId, 'trackCount': trackIds.length},
        ),
      );
    }
  }

  Future<Either<CacheFailure, Unit>> removeSelectedTracks({
    required String playlistId,
    required List<String> selectedTrackIds,
  }) async {
    return await call(
      playlistId: playlistId,
      trackIds: selectedTrackIds,
    );
  }

  Future<Either<CacheFailure, Unit>> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    if (playlistId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Playlist ID cannot be empty',
          field: 'playlistId',
          value: playlistId,
        ),
      );
    }

    if (trackId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }

    try {
      final referenceId = 'playlist_$playlistId';
      
      return await _cacheOrchestrationService.removeFromCache(
        trackId,
        referenceId,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing track from playlist: $e',
          field: 'cache_operation',
          value: {
            'playlistId': playlistId,
            'trackId': trackId,
          },
        ),
      );
    }
  }
}
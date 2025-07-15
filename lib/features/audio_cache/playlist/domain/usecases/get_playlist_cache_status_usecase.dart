import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/audio_storage_repository.dart';
import '../entities/playlist_cache_stats.dart';
import '../../../../../core/entities/unique_id.dart';

@injectable
class GetPlaylistCacheStatusUseCase {
  final AudioStorageRepository _audioStorageRepository;

  GetPlaylistCacheStatusUseCase(this._audioStorageRepository);

  /// Get cache status for all tracks in a playlist
  Future<Either<CacheFailure, Map<String, bool>>> call(
    List<String> trackIds,
  ) async {
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
      final audioTrackIds = trackIds.map((id) => AudioTrackId.fromUniqueString(id)).toList();
      final result = await _audioStorageRepository.checkMultipleAudioExists(audioTrackIds);
      
      return result.fold(
        (failure) => Left(failure),
        (statusMap) {
          // Convert AudioTrackId keys back to String keys
          final stringStatusMap = <String, bool>{};
          statusMap.forEach((audioTrackId, exists) {
            stringStatusMap[audioTrackId.value] = exists;
          });
          return Right(stringStatusMap);
        },
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get playlist cache status: $e',
          field: 'cache_status_operation',
          value: {'trackIds': trackIds},
        ),
      );
    }
  }

  /// Get cache percentage for a playlist
  Future<Either<CacheFailure, double>> getCachePercentage(
    List<String> trackIds,
  ) async {
    try {
      final statusResult = await call(trackIds);

      return statusResult.fold((failure) => Left(failure), (statusMap) {
        if (trackIds.isEmpty) return const Right(0.0);

        final cachedCount = statusMap.values.where((exists) => exists).length;

        return Right(cachedCount / trackIds.length);
      });
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get cache percentage: $e',
          field: 'cache_percentage_operation',
          value: {'trackIds': trackIds},
        ),
      );
    }
  }

  /// Get comprehensive cache statistics for a playlist
  Future<Either<CacheFailure, PlaylistCacheStats>> getPlaylistCacheStats({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final statusResult = await call(trackIds);

      return await statusResult.fold((failure) => Left(failure), (
        statusMap,
      ) async {
        final cachedCount =
            statusMap.values.where((status) => status == true).length;

        return Right(
          PlaylistCacheStats(
            playlistId: playlistId,
            totalTracks: trackIds.length,
            cachedTracks: cachedCount,
            downloadingTracks: 0, // TODO: Integrate with download tracking
            failedTracks: 0, // TODO: Integrate with download tracking  
            cachePercentage:
                trackIds.isNotEmpty ? cachedCount / trackIds.length : 0.0,
          ),
        );
      });
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting playlist cache stats: $e',
          field: 'cache_stats_operation',
          value: {'playlistId': playlistId, 'trackIds': trackIds},
        ),
      );
    }
  }

  /// Get cache status summary for UI display
  Future<Either<CacheFailure, String>> getCacheStatusSummary({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final statsResult = await getPlaylistCacheStats(
        playlistId: playlistId, 
        trackIds: trackIds,
      );

      return statsResult.fold(
        (failure) => Left(failure),
        (stats) => Right(stats.statusDescription),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get cache status summary: $e',
          field: 'cache_summary_operation',
          value: {'playlistId': playlistId, 'trackIds': trackIds},
        ),
      );
    }
  }

  /// Get detailed progress information for UI
  Future<Either<CacheFailure, Map<String, dynamic>>> getDetailedProgress({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final statsResult = await getPlaylistCacheStats(
        playlistId: playlistId,
        trackIds: trackIds,
      );

      return statsResult.fold(
        (failure) => Left(failure),
        (stats) => Right({
          'stats': stats,
          'statusDescription': stats.statusDescription,
          'progressDescription': stats.progressDescription,
          'canCache': !stats.isFullyCached,
          'canRemove': stats.cachedTracks > 0,
          'showProgress': stats.hasDownloading,
          'status': stats.status,
        }),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get detailed progress: $e',
          field: 'detailed_progress_operation',
          value: {'playlistId': playlistId, 'trackIds': trackIds},
        ),
      );
    }
  }
}

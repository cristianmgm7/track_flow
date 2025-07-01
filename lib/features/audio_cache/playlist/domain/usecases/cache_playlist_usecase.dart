import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_repository.dart';

@injectable
class CachePlaylistUseCase {
  final CacheStorageRepository _cacheStorageRepository;

  CachePlaylistUseCase(this._cacheStorageRepository);

  /// Cache all tracks in a playlist
  Future<Either<CacheFailure, Unit>> call({
    required String playlistId,
    required Map<String, String> trackUrlPairs, // trackId -> audioUrl
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

    if (trackUrlPairs.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track URL pairs cannot be empty',
          field: 'trackUrlPairs',
          value: trackUrlPairs,
        ),
      );
    }

    try {
      final result = await _cacheStorageRepository.downloadMultipleAudios(
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

  /// Get cache status for all tracks in a playlist
  Future<Either<CacheFailure, Map<String, bool>>> getPlaylistCacheStatus(
    List<String> trackIds,
  ) async {
    try {
      return await _cacheStorageRepository.checkMultipleAudioExists(trackIds);
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

  /// Get cache statistics for a playlist
  Future<Either<CacheFailure, PlaylistCacheStats>> getPlaylistCacheStats({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final statusResult = await getPlaylistCacheStatus(trackIds);

      return await statusResult.fold((failure) => Left(failure), (
        statusMap,
      ) async {
        final cachedCount =
            statusMap.values.where((status) => status == true).length;

        final downloadingCount =
            statusMap.values.where((status) => status == false).length;

        final failedCount =
            statusMap.values.where((status) => status == false).length;

        return Right(
          PlaylistCacheStats(
            playlistId: playlistId,
            totalTracks: trackIds.length,
            cachedTracks: cachedCount,
            downloadingTracks: downloadingCount,
            failedTracks: failedCount,
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

/// Statistics for playlist caching status
class PlaylistCacheStats {
  const PlaylistCacheStats({
    required this.playlistId,
    required this.totalTracks,
    required this.cachedTracks,
    required this.downloadingTracks,
    required this.failedTracks,
    required this.cachePercentage,
  });

  final String playlistId;
  final int totalTracks;
  final int cachedTracks;
  final int downloadingTracks;
  final int failedTracks;
  final double cachePercentage;

  bool get isFullyCached => cachedTracks == totalTracks;
  bool get hasDownloading => downloadingTracks > 0;
  bool get hasFailures => failedTracks > 0;
  bool get isPartiallyCached => cachedTracks > 0 && cachedTracks < totalTracks;

  int get pendingTracks =>
      totalTracks - cachedTracks - downloadingTracks - failedTracks;

  String get statusDescription {
    if (isFullyCached) return 'Fully cached';
    if (hasDownloading) return 'Downloading...';
    if (isPartiallyCached) return 'Partially cached';
    return 'Not cached';
  }
}

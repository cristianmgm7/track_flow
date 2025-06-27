import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';
import '../../../shared/domain/value_objects/conflict_policy.dart';
import '../../../shared/domain/entities/cached_audio.dart';

@injectable
class CachePlaylistUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  CachePlaylistUseCase(this._cacheOrchestrationService);

  /// Cache all tracks in a playlist with a single reference
  /// 
  /// [playlistId] - Unique identifier for the playlist
  /// [trackUrlPairs] - Map of trackId to audioUrl pairs
  /// [policy] - How to handle conflicts if tracks already exist
  /// 
  /// Returns success or specific failure for error handling
  Future<Either<CacheFailure, Unit>> call({
    required String playlistId,
    required Map<String, String> trackUrlPairs,
    ConflictPolicy policy = ConflictPolicy.lastWins,
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

    // Validate each track entry
    for (final entry in trackUrlPairs.entries) {
      if (entry.key.isEmpty) {
        return Left(
          ValidationCacheFailure(
            message: 'Track ID cannot be empty',
            field: 'trackId',
            value: entry.key,
          ),
        );
      }

      if (entry.value.isEmpty) {
        return Left(
          ValidationCacheFailure(
            message: 'Audio URL cannot be empty',
            field: 'audioUrl',
            value: entry.value,
          ),
        );
      }

      // Validate URL format
      final uri = Uri.tryParse(entry.value);
      if (uri == null || !uri.hasAbsolutePath) {
        return Left(
          ValidationCacheFailure(
            message: 'Invalid audio URL format for track ${entry.key}',
            field: 'audioUrl',
            value: entry.value,
          ),
        );
      }
    }

    try {
      // Use playlist ID as reference with prefix
      final referenceId = 'playlist_$playlistId';
      
      return await _cacheOrchestrationService.cacheMultipleAudios(
        trackUrlPairs,
        referenceId,
        policy: policy,
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

  /// Cache specific tracks from a playlist (partial caching)
  /// Useful for caching only selected tracks from a large playlist
  Future<Either<CacheFailure, Unit>> cacheSelectedTracks({
    required String playlistId,
    required Map<String, String> selectedTrackUrlPairs,
    ConflictPolicy policy = ConflictPolicy.lastWins,
  }) async {
    return await call(
      playlistId: playlistId,
      trackUrlPairs: selectedTrackUrlPairs,
      policy: policy,
    );
  }

  /// Add a single track to an existing cached playlist
  /// This will add the track with the playlist reference
  Future<Either<CacheFailure, Unit>> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
    required String audioUrl,
    ConflictPolicy policy = ConflictPolicy.lastWins,
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
      final referenceId = 'playlist_$playlistId';
      
      return await _cacheOrchestrationService.cacheAudio(
        trackId,
        audioUrl,
        referenceId,
        policy: policy,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while adding track to playlist: $e',
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

  /// Get cache status for all tracks in a playlist
  Future<Either<CacheFailure, Map<String, CacheStatus>>> getPlaylistCacheStatus({
    required List<String> trackIds,
  }) async {
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
      return await _cacheOrchestrationService.getMultipleCacheStatus(trackIds);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting playlist cache status: $e',
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
      final statusResult = await getPlaylistCacheStatus(trackIds: trackIds);
      
      return await statusResult.fold(
        (failure) => Left(failure),
        (statusMap) async {
          final cachedCount = statusMap.values
              .where((status) => status == CacheStatus.cached)
              .length;
          
          final downloadingCount = statusMap.values
              .where((status) => status == CacheStatus.downloading)
              .length;
          
          final failedCount = statusMap.values
              .where((status) => status == CacheStatus.failed)
              .length;

          return Right(
            PlaylistCacheStats(
              playlistId: playlistId,
              totalTracks: trackIds.length,
              cachedTracks: cachedCount,
              downloadingTracks: downloadingCount,
              failedTracks: failedCount,
              cachePercentage: trackIds.isNotEmpty ? cachedCount / trackIds.length : 0.0,
            ),
          );
        },
      );
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

  int get pendingTracks => totalTracks - cachedTracks - downloadingTracks - failedTracks;

  String get statusDescription {
    if (isFullyCached) return 'Fully cached';
    if (hasDownloading) return 'Downloading...';
    if (isPartiallyCached) return 'Partially cached';
    return 'Not cached';
  }
}
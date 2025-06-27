import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';

@injectable
class GetPlaylistCacheStatusUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  GetPlaylistCacheStatusUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, Map<String, CacheStatus>>> call({
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

  Future<Either<CacheFailure, PlaylistCacheStats>> getPlaylistCacheStats({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final statusResult = await call(trackIds: trackIds);
      
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

  Future<Either<CacheFailure, bool>> isPlaylistFullyCached({
    required List<String> trackIds,
  }) async {
    final statusResult = await call(trackIds: trackIds);
    
    return statusResult.fold(
      (failure) => Left(failure),
      (statusMap) {
        final allCached = statusMap.values.every(
          (status) => status == CacheStatus.cached,
        );
        return Right(allCached);
      },
    );
  }

  Future<Either<CacheFailure, List<String>>> getCachedTrackIds({
    required List<String> trackIds,
  }) async {
    final statusResult = await call(trackIds: trackIds);
    
    return statusResult.fold(
      (failure) => Left(failure),
      (statusMap) {
        final cachedTrackIds = <String>[];
        
        for (final entry in statusMap.entries) {
          if (entry.value == CacheStatus.cached) {
            cachedTrackIds.add(entry.key);
          }
        }
        
        return Right(cachedTrackIds);
      },
    );
  }

  Future<Either<CacheFailure, List<String>>> getUncachedTrackIds({
    required List<String> trackIds,
  }) async {
    final statusResult = await call(trackIds: trackIds);
    
    return statusResult.fold(
      (failure) => Left(failure),
      (statusMap) {
        final uncachedTrackIds = <String>[];
        
        for (final entry in statusMap.entries) {
          if (entry.value == CacheStatus.notCached) {
            uncachedTrackIds.add(entry.key);
          }
        }
        
        return Right(uncachedTrackIds);
      },
    );
  }
}

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
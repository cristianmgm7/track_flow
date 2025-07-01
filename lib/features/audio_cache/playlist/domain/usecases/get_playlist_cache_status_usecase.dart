import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_repository.dart';

@injectable
class GetPlaylistCacheStatusUseCase {
  final CacheStorageRepository _cacheStorageRepository;

  GetPlaylistCacheStatusUseCase(this._cacheStorageRepository);

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
}

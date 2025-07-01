import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_repository.dart';

@injectable
class RemoveTrackCacheUseCase {
  final CacheStorageRepository _cacheStorageRepository;

  RemoveTrackCacheUseCase(this._cacheStorageRepository);

  /// Remove a track from cache
  Future<Either<CacheFailure, Unit>> call(String trackId) async {
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

    try {
      return await _cacheStorageRepository.deleteAudioFile(trackId);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing track from cache: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }

  /// Remove multiple tracks from cache
  Future<Either<CacheFailure, Unit>> removeMultiple(
    List<String> trackIds,
  ) async {
    try {
      final result = await _cacheStorageRepository.deleteMultipleAudioFiles(
        trackIds,
      );
      return result.fold(
        (failure) => Left(failure),
        (deletedIds) => const Right(unit),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message:
              'Unexpected error while removing multiple tracks from cache: $e',
          field: 'cache_operation',
          value: {'trackIds': trackIds},
        ),
      );
    }
  }
}

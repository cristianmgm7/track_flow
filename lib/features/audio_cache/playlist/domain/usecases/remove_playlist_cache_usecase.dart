import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/repositories/cache_storage_repository.dart';

@injectable
class RemovePlaylistCacheUseCase {
  final CacheStorageRepository _cacheStorageRepository;

  RemovePlaylistCacheUseCase(this._cacheStorageRepository);

  /// Remove all tracks from a playlist cache
  Future<Either<CacheFailure, Unit>> call(List<String> trackIds) async {
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
          message: 'Unexpected error while removing playlist cache: $e',
          field: 'cache_operation',
          value: {'trackIds': trackIds},
        ),
      );
    }
  }

  /// Remove a single track from playlist cache
  Future<Either<CacheFailure, Unit>> removeTrack(String trackId) async {
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
          message:
              'Unexpected error while removing track from playlist cache: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }
}

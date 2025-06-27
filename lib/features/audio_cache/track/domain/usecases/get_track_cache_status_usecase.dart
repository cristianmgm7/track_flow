import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/cache_reference.dart';
import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';

@injectable
class GetTrackCacheStatusUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  GetTrackCacheStatusUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, CacheStatus>> call({
    required String trackId,
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

    try {
      return await _cacheOrchestrationService.getCacheStatus(trackId);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting cache status: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }

  Future<Either<CacheFailure, String?>> getCachedAudioPath({
    required String trackId,
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

    try {
      final result = await _cacheOrchestrationService.getCachedAudioPath(trackId);
      return result.fold(
        (failure) => Left(failure),
        (path) => Right(path),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting cached audio path: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }

  Future<Either<CacheFailure, CacheReference?>> getCacheReference({
    required String trackId,
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

    try {
      return await _cacheOrchestrationService.getCacheReference(trackId);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting cache reference: $e',
          field: 'cache_operation',
          value: {'trackId': trackId},
        ),
      );
    }
  }

  Stream<CacheStatus> watchCacheStatus({
    required String trackId,
  }) {
    return _cacheOrchestrationService.watchCacheStatus(trackId);
  }
}
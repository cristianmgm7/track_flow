import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';

@injectable
class RemoveTrackCacheUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  RemoveTrackCacheUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, Unit>> call({
    required String trackId,
    String referenceId = 'individual',
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
      return await _cacheOrchestrationService.removeFromCache(
        trackId,
        referenceId,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing track from cache: $e',
          field: 'cache_operation',
          value: {'trackId': trackId, 'referenceId': referenceId},
        ),
      );
    }
  }

  Future<Either<CacheFailure, Unit>> removeWithReference({
    required String trackId,
    required String referenceId,
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

    if (referenceId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Reference ID cannot be empty',
          field: 'referenceId',
          value: referenceId,
        ),
      );
    }

    try {
      return await _cacheOrchestrationService.removeFromCache(
        trackId,
        referenceId,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while removing track with reference: $e',
          field: 'cache_operation',
          value: {'trackId': trackId, 'referenceId': referenceId},
        ),
      );
    }
  }
}
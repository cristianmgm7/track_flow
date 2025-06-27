import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../failures/cache_failure.dart';
import '../services/cache_orchestration_service.dart';

@injectable
class CleanupCacheUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  CleanupCacheUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, CleanupResult>> call({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
  }) async {
    try {
      return await _cacheOrchestrationService.cleanupCache(
        removeCorrupted: removeCorrupted,
        removeOrphaned: removeOrphaned,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error during cache cleanup: $e',
          field: 'cleanup_operation',
          value: {
            'removeCorrupted': removeCorrupted,
            'removeOrphaned': removeOrphaned,
          },
        ),
      );
    }
  }

  Future<Either<CacheFailure, CleanupResult>> cleanupCorruptedFiles() async {
    return await call(
      removeCorrupted: true,
      removeOrphaned: false,
    );
  }

  Future<Either<CacheFailure, CleanupResult>> cleanupOrphanedFiles() async {
    return await call(
      removeCorrupted: false,
      removeOrphaned: true,
    );
  }

  Future<Either<CacheFailure, CleanupResult>> fullCleanup() async {
    return await call(
      removeCorrupted: true,
      removeOrphaned: true,
    );
  }
}
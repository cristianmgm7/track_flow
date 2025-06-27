import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/cached_audio.dart';
import '../failures/cache_failure.dart';
import '../services/cache_orchestration_service.dart';

@injectable
class GetCacheStorageStatsUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  GetCacheStorageStatsUseCase(this._cacheOrchestrationService);

  Future<Either<CacheFailure, StorageStats>> call() async {
    try {
      final result = await _cacheOrchestrationService.getStorageStats();
      return result;
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting storage stats: $e',
          field: 'storage_stats',
          value: null,
        ),
      );
    }
  }

  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    try {
      final result = await _cacheOrchestrationService.getAllCachedAudios();
      return result;
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while getting all cached audios: $e',
          field: 'cached_audios',
          value: null,
        ),
      );
    }
  }
}


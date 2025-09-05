import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../audio_cache/domain/entities/cleanup_details.dart';
import '../../../audio_cache/domain/failures/cache_failure.dart';
import '../services/cache_maintenance_service.dart';

@injectable
class CleanupCacheUseCase {
  final CacheMaintenanceService _cacheMaintenanceService;

  CleanupCacheUseCase(this._cacheMaintenanceService);

  /// Perform comprehensive cache cleanup
  Future<Either<CacheFailure, CleanupDetails>> call({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool removeTemporary = true,
    int? targetFreeBytes,
  }) async {
    try {
      return await _cacheMaintenanceService.performCleanup(
        removeCorrupted: removeCorrupted,
        removeOrphaned: removeOrphaned,
        removeTemporary: removeTemporary,
        targetFreeBytes: targetFreeBytes,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to perform cache cleanup: $e',
          field: 'cleanup_operation',
          value: {
            'removeCorrupted': removeCorrupted,
            'removeOrphaned': removeOrphaned,
            'removeTemporary': removeTemporary,
            'targetFreeBytes': targetFreeBytes,
          },
        ),
      );
    }
  }

  /// Remove only corrupted files
  Future<Either<CacheFailure, int>> removeCorruptedFiles() async {
    try {
      return await _cacheMaintenanceService.removeCorruptedFiles();
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to remove corrupted files: $e',
          field: 'cleanup_operation',
          value: 'removeCorrupted',
        ),
      );
    }
  }

  /// Remove only orphaned files
  Future<Either<CacheFailure, int>> removeOrphanedFiles() async {
    try {
      return await _cacheMaintenanceService.removeOrphanedFiles();
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to remove orphaned files: $e',
          field: 'cleanup_operation',
          value: 'removeOrphaned',
        ),
      );
    }
  }

  /// Free up specific amount of space
  Future<Either<CacheFailure, int>> freeUpSpace(int targetFreeBytes) async {
    try {
      return await _cacheMaintenanceService.freeUpSpace(targetFreeBytes);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to free up space: $e',
          field: 'cleanup_operation',
          value: {'targetFreeBytes': targetFreeBytes},
        ),
      );
    }
  }
}

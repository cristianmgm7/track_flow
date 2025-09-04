import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../audio_cache/domain/entities/cached_audio.dart';
import '../../../audio_cache/domain/failures/cache_failure.dart';
import '../../../audio_cache/domain/services/cache_maintenance_service.dart';

@injectable
class GetCacheStorageStatsUseCase {
  final CacheMaintenanceService _cacheMaintenanceService;

  GetCacheStorageStatsUseCase(this._cacheMaintenanceService);

  /// Get comprehensive storage statistics
  Future<Either<CacheFailure, StorageStats>> call() async {
    try {
      final totalUsageResult =
          await _cacheMaintenanceService.getTotalStorageUsage();
      final availableSpaceResult =
          await _cacheMaintenanceService.getAvailableStorageSpace();
      final allAudiosResult =
          await _cacheMaintenanceService.getAllCachedAudios();
      final corruptedFilesResult =
          await _cacheMaintenanceService.getCorruptedFiles();
      final orphanedFilesResult =
          await _cacheMaintenanceService.getOrphanedFiles();

      return await totalUsageResult.fold((failure) => Left(failure), (
        totalUsage,
      ) async {
        return await availableSpaceResult.fold((failure) => Left(failure), (
          availableSpace,
        ) async {
          return await allAudiosResult.fold((failure) => Left(failure), (
            allAudios,
          ) async {
            return await corruptedFilesResult.fold((failure) => Left(failure), (
              corruptedFiles,
            ) async {
              return await orphanedFilesResult.fold(
                (failure) => Left(failure),
                (orphanedFiles) {
                  final totalSize = totalUsage;
                  final usedPercentage =
                      totalSize > 0
                          ? (totalSize / (totalSize + availableSpace)) * 100
                          : 0.0;

                  return Right(
                    StorageStats(
                      totalCachedFiles: allAudios.length,
                      totalSizeBytes: totalSize,
                      availableSpaceBytes: availableSpace,
                      usedPercentage: usedPercentage,
                      corruptedFiles: corruptedFiles.length,
                      orphanedFiles: orphanedFiles.length,
                    ),
                  );
                },
              );
            });
          });
        });
      });
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get storage stats: $e',
          field: 'storage_stats_operation',
          value: 'get_stats',
        ),
      );
    }
  }

  /// Get total storage usage
  Future<Either<CacheFailure, int>> getTotalStorageUsage() async {
    try {
      return await _cacheMaintenanceService.getTotalStorageUsage();
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get total storage usage: $e',
          field: 'storage_stats_operation',
          value: 'total_usage',
        ),
      );
    }
  }

  /// Get available storage space
  Future<Either<CacheFailure, int>> getAvailableStorageSpace() async {
    try {
      return await _cacheMaintenanceService.getAvailableStorageSpace();
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get available storage space: $e',
          field: 'storage_stats_operation',
          value: 'available_space',
        ),
      );
    }
  }

  /// Get all cached audios
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    try {
      return await _cacheMaintenanceService.getAllCachedAudios();
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get all cached audios: $e',
          field: 'storage_stats_operation',
          value: 'all_audios',
        ),
      );
    }
  }
}

/// Storage statistics for cache management
class StorageStats {
  const StorageStats({
    required this.totalCachedFiles,
    required this.totalSizeBytes,
    required this.availableSpaceBytes,
    required this.usedPercentage,
    required this.corruptedFiles,
    required this.orphanedFiles,
  });

  final int totalCachedFiles;
  final int totalSizeBytes;
  final int availableSpaceBytes;
  final double usedPercentage;
  final int corruptedFiles;
  final int orphanedFiles;

  String get formattedTotalSize => _formatBytes(totalSizeBytes);
  String get formattedAvailableSpace => _formatBytes(availableSpaceBytes);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

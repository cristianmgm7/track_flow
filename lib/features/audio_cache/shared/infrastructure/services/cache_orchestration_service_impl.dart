import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cache_metadata.dart';
import '../../domain/entities/cache_reference.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_metadata_repository.dart';
import '../../domain/repositories/cache_storage_repository.dart';
import '../../domain/services/cache_orchestration_service.dart';
import '../../domain/value_objects/conflict_policy.dart';

@LazySingleton(as: CacheOrchestrationService)
class CacheOrchestrationServiceImpl implements CacheOrchestrationService {
  final CacheMetadataRepository _metadataRepository;
  final CacheStorageRepository _storageRepository;

  // Active downloads tracking
  final Map<String, StreamSubscription> _activeDownloads = {};
  final StreamController<List<DownloadProgress>> _activeDownloadsController =
      StreamController<List<DownloadProgress>>.broadcast();

  CacheOrchestrationServiceImpl({
    required CacheMetadataRepository metadataRepository,
    required CacheStorageRepository storageRepository,
  }) : _metadataRepository = metadataRepository,
       _storageRepository = storageRepository;

  @override
  Future<Either<CacheFailure, Unit>> cacheAudio(
    String trackId,
    String audioUrl,
    String referenceId, {
    ConflictPolicy policy = ConflictPolicy.lastWins,
  }) async {
    try {
      // Check if already cached
      final existingAudioResult = await _storageRepository.getCachedAudio(
        trackId,
      );

      return await existingAudioResult.fold(
        (failure) async {
          // Not cached, proceed with download
          return await _downloadAndCache(trackId, audioUrl, referenceId);
        },
        (existingAudio) async {
          if (existingAudio != null) {
            // Already cached, apply conflict policy
            return await _handleCacheConflict(
              trackId,
              audioUrl,
              referenceId,
              existingAudio,
              policy,
            );
          } else {
            // Not cached, proceed with download
            return await _downloadAndCache(trackId, audioUrl, referenceId);
          }
        },
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to cache audio: $e',
          field: 'trackId',
          value: trackId,
        ),
      );
    }
  }

  Future<Either<CacheFailure, Unit>> _downloadAndCache(
    String trackId,
    String audioUrl,
    String referenceId,
  ) async {
    // Mark as downloading in metadata
    final downloadingResult = await _metadataRepository.markAsDownloading(
      trackId,
    );

    return await downloadingResult.fold((failure) => Left(failure), (_) async {
      // Start download with progress tracking
      final downloadResult = await _storageRepository.downloadAndStoreAudio(
        trackId,
        audioUrl,
        progressCallback: (progress) {
          // Update active downloads
          _updateActiveDownloads(trackId, progress);
        },
      );

      return await downloadResult.fold(
        (failure) async {
          // Mark as failed and increment attempts
          await _metadataRepository.incrementDownloadAttempts(
            trackId,
            failure.message,
          );
          return Left(failure);
        },
        (cachedAudio) async {
          // Create metadata
          final metadata = CacheMetadata(
            trackId: trackId,
            referenceCount: 1,
            lastAccessed: DateTime.now(),
            references: [referenceId],
            status: CacheStatus.cached,
            downloadAttempts: 0,
            originalUrl: audioUrl,
          );

          // Save metadata and add reference
          final metadataResult = await _metadataRepository.saveMetadata(
            metadata,
          );
          final referenceResult = await _metadataRepository.addReference(
            trackId,
            referenceId,
          );

          return await metadataResult.fold(
            (failure) => Left(failure),
            (_) => referenceResult.fold((failure) => Left(failure), (_) async {
              await _metadataRepository.markAsCompleted(trackId);
              _removeFromActiveDownloads(trackId);
              return const Right(unit);
            }),
          );
        },
      );
    });
  }

  Future<Either<CacheFailure, Unit>> _handleCacheConflict(
    String trackId,
    String audioUrl,
    String referenceId,
    CachedAudio existingAudio,
    ConflictPolicy policy,
  ) async {
    switch (policy) {
      case ConflictPolicy.firstWins:
        // Just add reference to existing cache
        final result = await _metadataRepository.addReference(
          trackId,
          referenceId,
        );
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(unit),
        );

      case ConflictPolicy.lastWins:
        // Remove existing, download new
        await _storageRepository.deleteAudioFile(trackId);
        return await _downloadAndCache(trackId, audioUrl, referenceId);

      case ConflictPolicy.higherQuality:
        // For now, just add reference (quality comparison would need URL analysis)
        final result = await _metadataRepository.addReference(
          trackId,
          referenceId,
        );
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(unit),
        );

      case ConflictPolicy.userDecision:
        // For MVP, default to adding reference
        final result = await _metadataRepository.addReference(
          trackId,
          referenceId,
        );
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(unit),
        );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId,
  ) async {
    // Update last accessed
    await _metadataRepository.updateLastAccessed(trackId);

    return await _storageRepository.getCachedAudioPath(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> removeFromCache(
    String trackId,
    String referenceId,
  ) async {
    final referenceResult = await _metadataRepository.removeReference(
      trackId,
      referenceId,
    );
    return await referenceResult.fold((failure) => Left(failure), (
      updatedReference,
    ) async {
      if (updatedReference == null) {
        // No more references, safe to delete file
        return await _storageRepository.deleteAudioFile(trackId);
      } else {
        // Still has references, keep file
        return const Right(unit);
      }
    });
  }

  @override
  Future<Either<CacheFailure, CacheStatus>> getCacheStatus(
    String trackId,
  ) async {
    final metadataResult = await _metadataRepository.getMetadata(trackId);

    return metadataResult.fold((failure) => Left(failure), (metadata) {
      if (metadata != null) {
        return Right(metadata.status);
      } else {
        return const Right(CacheStatus.notCached);
      }
    });
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> getCacheReference(
    String trackId,
  ) async {
    return await _metadataRepository.getReference(trackId);
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    return _storageRepository.watchDownloadProgress(trackId);
  }

  @override
  Stream<CacheStatus> watchCacheStatus(String trackId) {
    return _metadataRepository
        .watchMetadata(trackId)
        .map((metadata) => metadata?.status ?? CacheStatus.notCached);
  }

  @override
  Stream<List<DownloadProgress>> watchActiveDownloads() {
    return _activeDownloadsController.stream;
  }

  @override
  Future<Either<CacheFailure, Unit>> cacheMultipleAudios(
    Map<String, String> trackUrlPairs,
    String referenceId, {
    ConflictPolicy policy = ConflictPolicy.lastWins,
  }) async {
    try {
      final List<String> successfulTracks = [];
      final List<String> failedTracks = [];

      for (final entry in trackUrlPairs.entries) {
        final trackId = entry.key;
        final audioUrl = entry.value;

        final result = await cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: policy,
        );

        result.fold(
          (failure) => failedTracks.add(trackId),
          (_) => successfulTracks.add(trackId),
        );
      }

      if (failedTracks.isNotEmpty) {
        return Left(
          ValidationCacheFailure(
            message: 'Some tracks failed to cache: ${failedTracks.join(', ')}',
            field: 'trackIds',
            value: failedTracks,
          ),
        );
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to cache multiple audios: $e',
          field: 'trackUrlPairs',
          value: trackUrlPairs,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> removeMultipleFromCache(
    List<String> trackIds,
    String referenceId,
  ) async {
    try {
      for (final trackId in trackIds) {
        final result = await removeFromCache(trackId, referenceId);
        result.fold(
          (failure) {
            // Log failure but continue with other tracks
          },
          (_) {
            // Success
          },
        );
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to remove multiple from cache: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, CacheStatus>>> getMultipleCacheStatus(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, CacheStatus> statusMap = {};

      for (final trackId in trackIds) {
        final result = await getCacheStatus(trackId);
        result.fold(
          (failure) => statusMap[trackId] = CacheStatus.failed,
          (status) => statusMap[trackId] = status,
        );
      }

      return Right(statusMap);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get multiple cache status: $e',
          field: 'trackIds',
          value: trackIds,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    return await _storageRepository.getAllCachedAudios();
  }

  @override
  Future<Either<CacheFailure, StorageStats>> getStorageStats() async {
    try {
      final audiosResult = await _storageRepository.getAllCachedAudios();
      final usageResult = await _storageRepository.getTotalStorageUsage();
      final availableResult =
          await _storageRepository.getAvailableStorageSpace();
      final corruptedResult = await _storageRepository.getCorruptedFiles();
      final orphanedResult = await _storageRepository.getOrphanedFiles();

      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async => await usageResult.fold(
          (failure) => Left(failure),
          (totalSize) async => await availableResult.fold(
            (failure) => Left(failure),
            (availableSpace) async => await corruptedResult.fold(
              (failure) => Left(failure),
              (corruptedFiles) async => await orphanedResult.fold(
                (failure) => Left(failure),
                (orphanedFiles) async {
                  final totalSpace = totalSize + availableSpace;
                  final usedPercentage =
                      totalSpace > 0 ? totalSize / totalSpace : 0.0;

                  return Right(
                    StorageStats(
                      totalCachedFiles: audios.length,
                      totalSizeBytes: totalSize,
                      availableSpaceBytes: availableSpace,
                      usedPercentage: usedPercentage,
                      corruptedFiles: corruptedFiles.length,
                      orphanedFiles: orphanedFiles.length,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get storage stats: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CleanupResult>> cleanupCache({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
  }) async {
    try {
      final cleanupDetails = await _storageRepository.performCleanup(
        removeCorrupted: removeCorrupted,
        removeOrphaned: removeOrphaned,
        removeTemporary: true,
      );

      return cleanupDetails.fold((failure) => Left(failure), (details) {
        return Right(
          CleanupResult(
            removedFiles: details.totalFilesRemoved,
            freedSpaceBytes: details.totalSpaceFreed,
            corruptedRemoved: details.corruptedFilesRemoved,
            orphanedRemoved: details.orphanedFilesRemoved,
            errors: details.errors,
          ),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId) async {
    _removeFromActiveDownloads(trackId);
    return await _storageRepository.cancelDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> retryDownload(String trackId) async {
    final metadataResult = await _metadataRepository.getMetadata(trackId);

    return await metadataResult.fold((failure) => Left(failure), (
      metadata,
    ) async {
      if (metadata != null &&
          metadata.shouldRetry &&
          metadata.originalUrl != null) {
        // Get reference to determine which reference to use for retry
        final referenceResult = await _metadataRepository.getReference(trackId);

        return await referenceResult.fold((failure) => Left(failure), (
          reference,
        ) async {
          if (reference != null && reference.referenceIds.isNotEmpty) {
            // Use first reference for retry
            return await cacheAudio(
              trackId,
              metadata.originalUrl!,
              reference.referenceIds.first,
            );
          } else {
            return Left(
              ValidationCacheFailure(
                message: 'No reference found for retry',
                field: 'trackId',
                value: trackId,
              ),
            );
          }
        });
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'Track cannot be retried or original URL not found',
            field: 'trackId',
            value: trackId,
          ),
        );
      }
    });
  }

  void _updateActiveDownloads(String trackId, DownloadProgress progress) {
    // This would update the active downloads list and emit to stream
    // For now, simplified implementation
    _activeDownloadsController.add([progress]);
  }

  void _removeFromActiveDownloads(String trackId) {
    _activeDownloads[trackId]?.cancel();
    _activeDownloads.remove(trackId);

    // Update the active downloads stream
    _activeDownloadsController.add([]);
  }

  void dispose() {
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();
    _activeDownloadsController.close();
  }
}

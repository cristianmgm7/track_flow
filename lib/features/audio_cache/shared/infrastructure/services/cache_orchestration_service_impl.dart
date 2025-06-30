import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../../domain/entities/cache_reference.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_storage_repository.dart';
import '../../domain/services/cache_orchestration_service.dart';
import '../../domain/value_objects/conflict_policy.dart';
import '../../data/models/cached_audio_document_unified.dart';

@LazySingleton(as: CacheOrchestrationService)
class CacheOrchestrationServiceImpl implements CacheOrchestrationService {
  final CacheStorageRepository _storageRepository;
  final Isar _isar;

  // Active downloads tracking
  final Map<String, StreamSubscription> _activeDownloads = {};
  final StreamController<List<DownloadProgress>> _activeDownloadsController =
      StreamController<List<DownloadProgress>>.broadcast();

  CacheOrchestrationServiceImpl({
    required CacheStorageRepository storageRepository,
    required Isar isar,
  }) : _storageRepository = storageRepository,
       _isar = isar;

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
    try {
      // Create or update unified document as downloading
      final existingDocument =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      final document =
          existingDocument ?? CachedAudioDocumentUnified()
            ..trackId = trackId
            ..status = CacheStatus.downloading
            ..referenceCount = 0
            ..lastAccessed = DateTime.now()
            ..references = []
            ..downloadAttempts = 0
            ..originalUrl = audioUrl;

      document.markAsDownloading();
      document.addReference(referenceId);

      await _isar.writeTxn(() async {
        await _isar.cachedAudioDocumentUnifieds.put(document);
      });

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
          document.markAsFailed(failure.message);
          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.put(document);
          });
          return Left(failure);
        },
        (cachedAudio) async {
          // Update document with file information and mark as completed
          document
            ..filePath = cachedAudio.filePath
            ..fileSizeBytes = cachedAudio.fileSizeBytes
            ..cachedAt = cachedAudio.cachedAt
            ..checksum = cachedAudio.checksum
            ..quality = cachedAudio.quality
            ..markAsCompleted();

          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.put(document);
          });

          _removeFromActiveDownloads(trackId);
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to download and cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Either<CacheFailure, Unit>> _handleCacheConflict(
    String trackId,
    String audioUrl,
    String referenceId,
    CachedAudio existingAudio,
    ConflictPolicy policy,
  ) async {
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document == null) {
        return await _downloadAndCache(trackId, audioUrl, referenceId);
      }

      switch (policy) {
        case ConflictPolicy.firstWins:
          // Just add reference to existing cache
          document.addReference(referenceId);
          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.put(document);
          });
          return const Right(unit);

        case ConflictPolicy.lastWins:
          // Remove existing, download new
          await _storageRepository.deleteAudioFile(trackId);
          return await _downloadAndCache(trackId, audioUrl, referenceId);

        case ConflictPolicy.higherQuality:
          // For now, just add reference (quality comparison would need URL analysis)
          document.addReference(referenceId);
          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.put(document);
          });
          return const Right(unit);

        case ConflictPolicy.userDecision:
          // For MVP, default to adding reference
          document.addReference(referenceId);
          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.put(document);
          });
          return const Right(unit);
      }
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to handle cache conflict: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId,
  ) async {
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document != null && document.isCached) {
        // Update last accessed timestamp
        await _isar.writeTxn(() async {
          document.updateLastAccessed();
          await _isar.cachedAudioDocumentUnifieds.put(document);
        });

        return Right(document.filePath);
      } else {
        return Left(
          StorageCacheFailure(
            message: 'Audio not cached for track: $trackId',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached audio path: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> removeFromCache(
    String trackId,
    String referenceId,
  ) async {
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document == null) {
        return const Right(unit); // Already removed
      }

      // Remove reference
      document.removeReference(referenceId);

      if (document.canDelete) {
        // No more references, delete file and document
        await _isar.writeTxn(() async {
          // Delete physical file
          final file = File(document.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          // Delete document
          await _isar.cachedAudioDocumentUnifieds.delete(document.isarId);
        });
      } else {
        // Still has references, just update document
        await _isar.writeTxn(() async {
          await _isar.cachedAudioDocumentUnifieds.put(document);
        });
      }

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to remove from cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheStatus>> getCacheStatus(
    String trackId,
  ) async {
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document != null) {
        return Right(document.status);
      } else {
        return const Right(CacheStatus.notCached);
      }
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache status: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> getCacheReference(
    String trackId,
  ) async {
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document != null) {
        // Create CacheReference from unified document
        final cacheReference = CacheReference(
          trackId: trackId,
          referenceIds: List<String>.from(document.references),
          createdAt: document.cachedAt,
          lastAccessed: document.lastAccessed,
        );
        return Right(cacheReference);
      } else {
        return const Right(null);
      }
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache reference: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    return _storageRepository.watchDownloadProgress(trackId);
  }

  @override
  Stream<CacheStatus> watchCacheStatus(String trackId) {
    return _isar.cachedAudioDocumentUnifieds
        .where()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .map((documents) {
          if (documents.isNotEmpty) {
            return documents.first.status;
          } else {
            return CacheStatus.notCached;
          }
        });
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

      // Initialize all as not cached
      for (final trackId in trackIds) {
        statusMap[trackId] = CacheStatus.notCached;
      }

      // Get all documents - using individual queries for now
      for (final trackId in trackIds) {
        final document =
            await _isar.cachedAudioDocumentUnifieds
                .where()
                .trackIdEqualTo(trackId)
                .findFirst();

        if (document != null) {
          statusMap[trackId] = document.status;
        }
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
    try {
      final document =
          await _isar.cachedAudioDocumentUnifieds
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (document != null &&
          document.shouldRetry &&
          document.originalUrl != null &&
          document.references.isNotEmpty) {
        // Use first reference for retry
        return await cacheAudio(
          trackId,
          document.originalUrl!,
          document.references.first,
        );
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'Track cannot be retried or original URL not found',
            field: 'trackId',
            value: trackId,
          ),
        );
      }
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to retry download: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
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

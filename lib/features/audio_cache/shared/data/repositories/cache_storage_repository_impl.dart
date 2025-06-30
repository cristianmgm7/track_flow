import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_storage_repository.dart';
import '../../domain/value_objects/cache_key.dart';
import '../datasources/cache_storage_local_data_source.dart';
import '../datasources/cache_storage_remote_data_source.dart';
import '../models/cached_audio_document_unified.dart';

@LazySingleton(as: CacheStorageRepository)
class CacheStorageRepositoryImpl implements CacheStorageRepository {
  final CacheStorageLocalDataSource _localDataSource;
  final CacheStorageRemoteDataSource _remoteDataSource;
  static const String _cacheSubDirectory = 'audio_cache';

  // Active downloads tracking for progress and cancellation
  final Map<String, String> _activeDownloads = {}; // trackId -> downloadId
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};

  CacheStorageRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
    required CacheStorageRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      final cacheKey = _localDataSource.generateCacheKey(trackId, audioUrl);
      final filePathResult = await _localDataSource.getFilePathFromCacheKey(
        cacheKey,
      );

      return await filePathResult.fold((failure) => Left(failure), (
        filePath,
      ) async {
        // Create progress controller for this download
        final progressController =
            StreamController<DownloadProgress>.broadcast();
        _progressControllers[trackId] = progressController;

        // Download using remote data source (Firebase Storage)
        String? downloadId;
        final downloadResult = await _remoteDataSource.downloadAudio(
          audioUrl: audioUrl,
          localFilePath: filePath,
          onProgress: (progress) {
            // Store download ID for cancellation tracking
            if (downloadId == null) {
              downloadId =
                  progress
                      .trackId; // This is the download ID from remote source
              _activeDownloads[trackId] = downloadId!;
            }

            // Map download ID back to trackId for consistency
            final trackProgress = progress.copyWith(trackId: trackId);
            progressCallback?.call(trackProgress);
            progressController.add(trackProgress);
          },
        );

        return downloadResult.fold(
          (failure) {
            final failedProgress = DownloadProgress.failed(
              trackId,
              failure.message,
            );
            progressCallback?.call(failedProgress);
            progressController.add(failedProgress);
            _cleanupDownload(trackId);
            return Left(failure);
          },
          (downloadedFile) async {
            // Verify file and calculate checksum
            final fileSize = await downloadedFile.length();
            final bytes = await downloadedFile.readAsBytes();
            final checksum = sha1.convert(bytes).toString();

            // Create unified document with both file and metadata information
            final unifiedDocument =
                CachedAudioDocumentUnified()
                  ..trackId = trackId
                  ..filePath = filePath
                  ..fileSizeBytes = fileSize
                  ..cachedAt = DateTime.now()
                  ..checksum = checksum
                  ..quality = AudioQuality.medium
                  ..status = CacheStatus.cached
                  ..referenceCount = 1
                  ..lastAccessed = DateTime.now()
                  ..references = ['individual']
                  ..downloadAttempts = 0
                  ..lastDownloadAttempt = null
                  ..failureReason = null
                  ..originalUrl = audioUrl;

            // Store unified document in local database
            final storeResult = await _localDataSource.storeUnifiedCachedAudio(
              unifiedDocument,
            );

            return await storeResult.fold(
              (failure) {
                _cleanupDownload(trackId);
                return Left(failure);
              },
              (unifiedDoc) async {
                final completedProgress = DownloadProgress.completed(
                  trackId,
                  fileSize,
                );
                progressCallback?.call(completedProgress);
                progressController.add(completedProgress);

                // Clean up
                _cleanupDownload(trackId);

                // Convert back to CachedAudio for backward compatibility
                final cachedAudio = unifiedDoc.toCachedAudio();
                return Right(cachedAudio);
              },
            );
          },
        );
      });
    } catch (e) {
      final failedProgress = DownloadProgress.failed(trackId, e.toString());
      progressCallback?.call(failedProgress);

      // Emit to progress controller if it exists
      _progressControllers[trackId]?.add(failedProgress);
      _cleanupDownload(trackId);

      return Left(
        DownloadCacheFailure(
          message: 'Failed to download and store audio: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId,
  ) async {
    return await _localDataSource.getCachedAudioPath(trackId);
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(String trackId) async {
    return await _localDataSource.audioExists(trackId);
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    String trackId,
  ) async {
    return await _localDataSource.getCachedAudio(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId) async {
    return await _localDataSource.deleteAudioFile(trackId);
  }

  @override
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  ) async {
    return await _localDataSource.verifyFileIntegrity(
      trackId,
      expectedChecksum,
    );
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> downloadMultipleAudios(
    Map<String, String> trackUrlPairs, {
    void Function(String trackId, DownloadProgress)? progressCallback,
  }) async {
    try {
      final List<CachedAudio> downloadedAudios = [];

      for (final entry in trackUrlPairs.entries) {
        final trackId = entry.key;
        final audioUrl = entry.value;

        final result = await downloadAndStoreAudio(
          trackId,
          audioUrl,
          progressCallback: (progress) {
            progressCallback?.call(trackId, progress);
          },
        );

        result.fold(
          (failure) {
            // Log failure but continue with other downloads
          },
          (audio) {
            downloadedAudios.add(audio);
          },
        );
      }

      return Right(downloadedAudios);
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to download multiple audios: $e',
          trackId: 'multiple',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, CachedAudio>>>
  getMultipleCachedAudios(List<String> trackIds) async {
    return await _localDataSource
        .getMultipleCachedAudios(trackIds)
        .then(
          (result) => result.fold((failure) => Left(failure), (audios) {
            final Map<String, CachedAudio> audioMap = {};
            for (final audio in audios) {
              audioMap[audio.trackId] = audio;
            }
            return Right(audioMap);
          }),
        );
  }

  @override
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(
    List<String> trackIds,
  ) async {
    return await _localDataSource.deleteMultipleAudioFiles(trackIds);
  }

  @override
  Future<Either<CacheFailure, Map<String, bool>>> checkMultipleAudioExists(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, bool> existsMap = {};

      for (final trackId in trackIds) {
        final result = await _localDataSource.audioExists(trackId);
        result.fold(
          (failure) => existsMap[trackId] = false,
          (exists) => existsMap[trackId] = exists,
        );
      }

      return Right(existsMap);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check multiple audio exists: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    return await _localDataSource.getAllCachedAudios();
  }

  @override
  Future<Either<CacheFailure, int>> getTotalStorageUsage() async {
    final totalSize = await _localDataSource.getTotalStorageUsage();
    return totalSize.fold(
      (failure) => Left(failure),
      (size) => Right(size.toInt()),
    );
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorageSpace() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd get the actual available space on the device
      const totalSpace = 1024 * 1024 * 1024 * 10; // 10GB default
      final usedSpace = await getTotalStorageUsage();

      return usedSpace.fold(
        (failure) => Left(failure),
        (used) => Right(totalSpace - used),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get available storage space: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getCacheDirectorySize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        final files = cacheDir.listSync(recursive: true).whereType<File>();
        for (final file in files) {
          totalSize += await file.length();
        }
      }

      return Right(totalSize);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache directory size: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles() async {
    return await _localDataSource.getCorruptedFiles();
  }

  @override
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles() async {
    return await _localDataSource.getOrphanedFiles();
  }

  @override
  Future<Either<CacheFailure, int>> removeCorruptedFiles() async {
    try {
      final corruptedResult = await _localDataSource.getCorruptedFiles();

      return await corruptedResult.fold((failure) => Left(failure), (
        corruptedTrackIds,
      ) async {
        final deletedResult = await _localDataSource.deleteMultipleAudioFiles(
          corruptedTrackIds,
        );

        return deletedResult.fold(
          (failure) => Left(failure),
          (deletedTrackIds) => Right(deletedTrackIds.length),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to remove corrupted files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> removeOrphanedFiles() async {
    try {
      final orphanedResult = await _localDataSource.getOrphanedFiles();

      return await orphanedResult.fold((failure) => Left(failure), (
        orphanedPaths,
      ) async {
        int removedCount = 0;

        for (final path in orphanedPaths) {
          try {
            final file = File(path);
            if (await file.exists()) {
              await file.delete();
              removedCount++;
            }
          } catch (e) {
            // Log error but continue with other files
          }
        }

        return Right(removedCount);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to remove orphaned files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles() async {
    try {
      final cacheDir = await _getCacheDirectory();
      int removedCount = 0;

      if (await cacheDir.exists()) {
        final files = cacheDir.listSync().whereType<File>();

        for (final file in files) {
          // Remove temp files (e.g., .tmp, .part extensions)
          if (file.path.endsWith('.tmp') ||
              file.path.endsWith('.part') ||
              file.path.endsWith('.download')) {
            try {
              await file.delete();
              removedCount++;
            } catch (e) {
              // Log error but continue
            }
          }
        }
      }

      return Right(removedCount);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup temporary files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> freeUpSpace(int targetFreeBytes) async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        // Sort by last accessed (oldest first)
        audios.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

        int freedBytes = 0;
        final trackIdsToDelete = <String>[];

        for (final audio in audios) {
          if (freedBytes >= targetFreeBytes) break;

          trackIdsToDelete.add(audio.trackId);
          freedBytes += audio.fileSizeBytes.toInt();
        }

        if (trackIdsToDelete.isNotEmpty) {
          await _localDataSource.deleteMultipleAudioFiles(trackIdsToDelete);
        }

        return Right(freedBytes);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to free up space: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CleanupDetails>> performCleanup({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool removeTemporary = true,
    int? targetFreeBytes,
  }) async {
    try {
      int corruptedRemoved = 0;
      int orphanedRemoved = 0;
      int temporaryRemoved = 0;
      int oldestRemoved = 0;
      final List<String> errors = [];

      if (removeCorrupted) {
        final result = await removeCorruptedFiles();
        result.fold(
          (failure) =>
              errors.add('Corrupted cleanup failed: ${failure.message}'),
          (count) => corruptedRemoved = count,
        );
      }

      if (removeOrphaned) {
        final result = await removeOrphanedFiles();
        result.fold(
          (failure) =>
              errors.add('Orphaned cleanup failed: ${failure.message}'),
          (count) => orphanedRemoved = count,
        );
      }

      if (removeTemporary) {
        final result = await cleanupTemporaryFiles();
        result.fold(
          (failure) =>
              errors.add('Temporary cleanup failed: ${failure.message}'),
          (count) => temporaryRemoved = count,
        );
      }

      if (targetFreeBytes != null) {
        final result = await freeUpSpace(targetFreeBytes);
        result.fold(
          (failure) => errors.add('Space cleanup failed: ${failure.message}'),
          (freedBytes) => oldestRemoved = freedBytes,
        );
      }

      final totalFilesRemoved =
          corruptedRemoved + orphanedRemoved + temporaryRemoved;
      final totalSpaceFreed = oldestRemoved; // Simplified calculation

      return Right(
        CleanupDetails(
          corruptedFilesRemoved: corruptedRemoved,
          orphanedFilesRemoved: orphanedRemoved,
          temporaryFilesRemoved: temporaryRemoved,
          oldestFilesRemoved: 0, // We're counting bytes freed, not files
          totalSpaceFreed: totalSpaceFreed,
          totalFilesRemoved: totalFilesRemoved,
          errors: errors,
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to perform cleanup: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId) async {
    try {
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        final result = await _remoteDataSource.cancelDownload(downloadId);
        return result.fold((failure) => Left(failure), (_) {
          // Emit cancelled progress
          final cancelledProgress = DownloadProgress.failed(
            trackId,
            'Download cancelled by user',
          );
          _progressControllers[trackId]?.add(cancelledProgress);

          _cleanupDownload(trackId);
          return const Right(unit);
        });
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'No active download found for track',
            field: 'trackId',
            value: trackId,
          ),
        );
      }
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to cancel download: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId) async {
    try {
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        // For Firebase Storage, we need to cancel and store progress for later resume
        final result = await _remoteDataSource.cancelDownload(downloadId);
        return result.fold((failure) => Left(failure), (_) {
          // Mark as paused in progress controller
          final pausedProgress = DownloadProgress(
            trackId: trackId,
            state:
                DownloadState
                    .downloading, // Keep as downloading but store pause state internally
            downloadedBytes: 0, // We'd need to store this from last progress
            totalBytes: 0,
          );
          _progressControllers[trackId]?.add(pausedProgress);

          // Don't cleanup yet - keep for resume
          return const Right(unit);
        });
      } else {
        return Left(
          ValidationCacheFailure(
            message: 'No active download found for track',
            field: 'trackId',
            value: trackId,
          ),
        );
      }
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to pause download: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId) async {
    try {
      // For Firebase Storage, resuming means starting a new download
      // In a full implementation, we'd need to store the original URL and progress
      // For now, return an error indicating resume is not supported with current implementation
      return Left(
        ValidationCacheFailure(
          message:
              'Download resuming not supported with current Firebase Storage implementation. Please restart download.',
          field: 'trackId',
          value: trackId,
        ),
      );
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to resume download: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(
    String trackId,
  ) async {
    try {
      // Check if download is currently active
      final downloadId = _activeDownloads[trackId];
      if (downloadId != null) {
        // Return a basic progress indicating it's active
        // In a full implementation, we'd store last known progress
        return Right(
          DownloadProgress(
            trackId: trackId,
            state: DownloadState.downloading,
            downloadedBytes: 0,
            totalBytes: 0,
          ),
        );
      }

      // Check if file already exists (completed)
      final existsResult = await audioExists(trackId);
      return existsResult.fold((failure) => Left(failure), (exists) {
        if (exists) {
          // File exists, so download was completed
          return const Right(
            null, // Could return completed progress here
          );
        } else {
          // No active download and file doesn't exist
          return const Right(null);
        }
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get download progress: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<DownloadProgress>>>
  getActiveDownloads() async {
    try {
      final activeDownloads = <DownloadProgress>[];

      for (final entry in _activeDownloads.entries) {
        final trackId = entry.key;

        // Create a basic progress object for each active download
        activeDownloads.add(
          DownloadProgress(
            trackId: trackId,
            state: DownloadState.downloading,
            downloadedBytes: 0, // We'd need to store actual progress
            totalBytes: 0,
          ),
        );
      }

      return Right(activeDownloads);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get active downloads: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    // Return existing controller stream or create a new one
    final controller = _progressControllers[trackId];
    if (controller != null) {
      return controller.stream;
    } else {
      // Create a new controller for future downloads
      final newController = StreamController<DownloadProgress>.broadcast();
      _progressControllers[trackId] = newController;
      return newController.stream;
    }
  }

  @override
  Stream<List<DownloadProgress>> watchActiveDownloads() {
    // Create a combined stream of all active downloads
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      final activeDownloads = <DownloadProgress>[];
      for (final trackId in _activeDownloads.keys) {
        // For active downloads, we could track their last known progress
        // For now, just indicate they're active
        activeDownloads.add(
          DownloadProgress(
            trackId: trackId,
            state: DownloadState.downloading,
            downloadedBytes: 0,
            totalBytes: 0,
          ),
        );
      }
      return activeDownloads;
    }).distinct();
  }

  @override
  Stream<int> watchStorageUsage() {
    return _localDataSource.watchStorageUsage();
  }

  @override
  CacheKey generateCacheKey(String trackId, String audioUrl) {
    return _localDataSource.generateCacheKey(trackId, audioUrl);
  }

  @override
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(
    CacheKey key,
  ) async {
    return await _localDataSource.getFilePathFromCacheKey(key);
  }

  @override
  bool isValidCacheKey(CacheKey key) {
    return key.isComposite && key.trackId != null && key.checksum != null;
  }

  @override
  Future<Either<CacheFailure, int>> migrateCacheStructure() async {
    try {
      // Basic cache migration implementation
      // In a real app, this would handle version migrations, file structure changes, etc.

      int migratedFiles = 0;
      final cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        final files = cacheDir.listSync().whereType<File>();

        for (final file in files) {
          // Example: rename old cache files to new format
          if (file.path.contains('old_cache_')) {
            final newName = file.path.replaceAll('old_cache_', 'cache_');
            await file.rename(newName);
            migratedFiles++;
          }
        }
      }

      return Right(migratedFiles);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to migrate cache structure: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> rebuildCacheIndex() async {
    try {
      // Rebuild cache index by scanning files and updating database
      int rebuiltEntries = 0;

      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return const Right(0);
      }

      final files = cacheDir.listSync().whereType<File>();

      for (final file in files) {
        try {
          // Skip temporary files
          if (file.path.endsWith('.tmp') ||
              file.path.endsWith('.part') ||
              file.path.endsWith('.download')) {
            continue;
          }

          // Extract trackId from filename (assuming specific naming convention)
          final filename = file.path.split('/').last;
          if (filename.contains('_')) {
            final trackId = filename.split('_').first;

            // Check if this file has corresponding database entry
            final existsResult = await _localDataSource.audioExists(trackId);
            final exists = existsResult.fold(
              (failure) => false,
              (exists) => exists,
            );

            if (!exists) {
              // File exists but no database entry - create one
              final fileSize = await file.length();
              final bytes = await file.readAsBytes();
              final checksum = sha1.convert(bytes).toString();

              final cachedAudio = CachedAudio(
                trackId: trackId,
                filePath: file.path,
                fileSizeBytes: fileSize,
                cachedAt: DateTime.now(),
                checksum: checksum,
                quality: AudioQuality.medium,
                status: CacheStatus.cached,
              );

              await _localDataSource.storeCachedAudio(cachedAudio);
              rebuiltEntries++;
            }
          }
        } catch (e) {
          // Skip problematic files
          continue;
        }
      }

      return Right(rebuiltEntries);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to rebuild cache index: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheValidationResult>>
  validateCacheConsistency() async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();

      return await audiosResult.fold((failure) => Left(failure), (
        audios,
      ) async {
        int totalFiles = audios.length;
        int validFiles = 0;
        int corruptedFiles = 0;
        int orphanedFiles = 0;
        int missingMetadata = 0;
        int inconsistentSizes = 0;
        final List<String> issues = [];

        for (final audio in audios) {
          try {
            final file = File(audio.filePath);

            if (!await file.exists()) {
              orphanedFiles++;
              issues.add('File missing: ${audio.filePath}');
              continue;
            }

            final actualSize = await file.length();
            if (actualSize != audio.fileSizeBytes) {
              inconsistentSizes++;
              issues.add(
                'Size mismatch for ${audio.trackId}: expected ${audio.fileSizeBytes}, got $actualSize',
              );
              continue;
            }

            final integrityResult = await verifyFileIntegrity(
              audio.trackId,
              audio.checksum,
            );
            integrityResult.fold(
              (failure) {
                corruptedFiles++;
                issues.add('Integrity check failed for ${audio.trackId}');
              },
              (isValid) {
                if (isValid) {
                  validFiles++;
                } else {
                  corruptedFiles++;
                  issues.add('File corrupted: ${audio.trackId}');
                }
              },
            );
          } catch (e) {
            issues.add('Error validating ${audio.trackId}: $e');
          }
        }

        return Right(
          CacheValidationResult(
            totalFiles: totalFiles,
            validFiles: validFiles,
            corruptedFiles: corruptedFiles,
            orphanedFiles: orphanedFiles,
            missingMetadata: missingMetadata,
            inconsistentSizes: inconsistentSizes,
            issues: issues,
          ),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate cache consistency: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheSubDirectory');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Cleanup download tracking resources
  void _cleanupDownload(String trackId) {
    _activeDownloads.remove(trackId);
    _progressControllers[trackId]?.close();
    _progressControllers.remove(trackId);
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _activeDownloads.clear();
  }
}

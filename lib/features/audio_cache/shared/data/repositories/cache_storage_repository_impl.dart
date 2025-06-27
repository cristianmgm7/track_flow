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

@LazySingleton(as: CacheStorageRepository)
class CacheStorageRepositoryImpl implements CacheStorageRepository {
  final CacheStorageLocalDataSource _localDataSource;
  final HttpClient _httpClient;
  static const String _cacheSubDirectory = 'audio_cache';

  CacheStorageRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource,
       _httpClient = HttpClient();

  @override
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      final cacheKey = _localDataSource.generateCacheKey(trackId, audioUrl);
      final filePathResult = await _localDataSource.getFilePathFromCacheKey(cacheKey);
      
      return await filePathResult.fold(
        (failure) => Left(failure),
        (filePath) async {
          // Notify download started
          progressCallback?.call(
            DownloadProgress.queued(trackId),
          );

          // Download using HttpClient
          final uri = Uri.parse(audioUrl);
          final request = await _httpClient.getUrl(uri);
          final response = await request.close();

          if (response.statusCode == 200) {
            final file = File(filePath);
            final sink = file.openWrite();
            
            int downloadedBytes = 0;
            final contentLength = response.contentLength;
            
            await for (final chunk in response) {
              sink.add(chunk);
              downloadedBytes += chunk.length;
              
              if (contentLength > 0) {
                final progress = DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.downloading,
                  downloadedBytes: downloadedBytes,
                  totalBytes: contentLength,
                );
                progressCallback?.call(progress);
              }
            }
            
            await sink.close();
            final fileSize = await file.length();
            final bytes = await file.readAsBytes();
            final checksum = sha1.convert(bytes).toString();

            final cachedAudio = CachedAudio(
              trackId: trackId,
              filePath: filePath,
              fileSizeBytes: fileSize,
              cachedAt: DateTime.now(),
              checksum: checksum,
              quality: AudioQuality.medium, // Default quality
              status: CacheStatus.cached,
            );

            // Store in local database
            final storeResult = await _localDataSource.storeCachedAudio(cachedAudio);
            
            return storeResult.fold(
              (failure) => Left(failure),
              (audio) {
                progressCallback?.call(
                  DownloadProgress.completed(trackId, fileSize),
                );
                return Right(audio);
              },
            );
          } else {
            return Left(
              NetworkCacheFailure(
                message: 'Failed to download audio: HTTP ${response.statusCode}',
                statusCode: response.statusCode,
              ),
            );
          }
        },
      );
    } catch (e) {
      progressCallback?.call(
        DownloadProgress.failed(trackId, e.toString()),
      );
      
      return Left(
        DownloadCacheFailure(
          message: 'Failed to download and store audio: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId) async {
    return await _localDataSource.getCachedAudioPath(trackId);
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(String trackId) async {
    return await _localDataSource.audioExists(trackId);
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId) async {
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
    return await _localDataSource.verifyFileIntegrity(trackId, expectedChecksum);
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
  Future<Either<CacheFailure, Map<String, CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  ) async {
    return await _localDataSource.getMultipleCachedAudios(trackIds).then(
      (result) => result.fold(
        (failure) => Left(failure),
        (audios) {
          final Map<String, CachedAudio> audioMap = {};
          for (final audio in audios) {
            audioMap[audio.trackId] = audio;
          }
          return Right(audioMap);
        },
      ),
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
    return await _localDataSource.getTotalStorageUsage();
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorageSpace() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final stat = await cacheDir.stat();
      
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
      
      return await corruptedResult.fold(
        (failure) => Left(failure),
        (corruptedTrackIds) async {
          final deletedResult = await _localDataSource.deleteMultipleAudioFiles(
            corruptedTrackIds,
          );
          
          return deletedResult.fold(
            (failure) => Left(failure),
            (deletedTrackIds) => Right(deletedTrackIds.length),
          );
        },
      );
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
      
      return await orphanedResult.fold(
        (failure) => Left(failure),
        (orphanedPaths) async {
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
        },
      );
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
      
      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async {
          // Sort by last accessed (oldest first)
          audios.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));
          
          int freedBytes = 0;
          final trackIdsToDelete = <String>[];
          
          for (final audio in audios) {
            if (freedBytes >= targetFreeBytes) break;
            
            trackIdsToDelete.add(audio.trackId);
            freedBytes += audio.fileSizeBytes;
          }
          
          if (trackIdsToDelete.isNotEmpty) {
            await _localDataSource.deleteMultipleAudioFiles(trackIdsToDelete);
          }
          
          return Right(freedBytes);
        },
      );
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
          (failure) => errors.add('Corrupted cleanup failed: ${failure.message}'),
          (count) => corruptedRemoved = count,
        );
      }

      if (removeOrphaned) {
        final result = await removeOrphanedFiles();
        result.fold(
          (failure) => errors.add('Orphaned cleanup failed: ${failure.message}'),
          (count) => orphanedRemoved = count,
        );
      }

      if (removeTemporary) {
        final result = await cleanupTemporaryFiles();
        result.fold(
          (failure) => errors.add('Temporary cleanup failed: ${failure.message}'),
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

      final totalFilesRemoved = corruptedRemoved + orphanedRemoved + temporaryRemoved;
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
    // TODO: Implement download cancellation
    // This would require storing download operations and cancellation tokens
    return const Right(unit);
  }

  @override
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId) async {
    // TODO: Implement download pausing
    return const Right(unit);
  }

  @override
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId) async {
    // TODO: Implement download resuming
    return const Right(unit);
  }

  @override
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(String trackId) async {
    // TODO: Implement progress tracking storage
    return const Right(null);
  }

  @override
  Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads() async {
    // TODO: Implement active downloads tracking
    return const Right([]);
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    // TODO: Implement real-time progress watching
    return Stream.empty();
  }

  @override
  Stream<List<DownloadProgress>> watchActiveDownloads() {
    // TODO: Implement active downloads watching
    return Stream.value([]);
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
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key) async {
    return await _localDataSource.getFilePathFromCacheKey(key);
  }

  @override
  bool isValidCacheKey(CacheKey key) {
    return key.isComposite && key.trackId != null && key.checksum != null;
  }

  @override
  Future<Either<CacheFailure, int>> migrateCacheStructure() async {
    // TODO: Implement cache migration logic
    return const Right(0);
  }

  @override
  Future<Either<CacheFailure, int>> rebuildCacheIndex() async {
    // TODO: Implement cache index rebuilding
    return const Right(0);
  }

  @override
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheConsistency() async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();
      
      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async {
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
                issues.add('Size mismatch for ${audio.trackId}: expected ${audio.fileSizeBytes}, got $actualSize');
                continue;
              }

              final integrityResult = await verifyFileIntegrity(audio.trackId, audio.checksum);
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
        },
      );
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
}
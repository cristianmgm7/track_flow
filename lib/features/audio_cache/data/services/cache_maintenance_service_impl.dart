import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../cache_management/domain/services/cache_maintenance_service.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/cleanup_details.dart';
import '../../domain/entities/cache_validation_result.dart';
import '../../domain/failures/cache_failure.dart';

@LazySingleton(as: CacheMaintenanceService)
class CacheMaintenanceServiceImpl implements CacheMaintenanceService {
  static const String _cacheRootPath = 'trackflow/audio';

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
      int spaceFreed = 0;

      if (removeCorrupted) {
        final result = await removeCorruptedFiles();
        result.fold(
          (failure) => throw Exception(failure.message),
          (count) => corruptedRemoved = count,
        );
      }

      if (removeOrphaned) {
        final result = await removeOrphanedFiles();
        result.fold(
          (failure) => throw Exception(failure.message),
          (count) => orphanedRemoved = count,
        );
      }

      if (removeTemporary) {
        final result = await cleanupTemporaryFiles();
        result.fold(
          (failure) => throw Exception(failure.message),
          (count) => temporaryRemoved = count,
        );
      }

      if (targetFreeBytes != null) {
        final result = await freeUpSpace(targetFreeBytes);
        result.fold(
          (failure) => throw Exception(failure.message),
          (bytes) => spaceFreed = bytes,
        );
      }

      return Right(
        CleanupDetails(
          corruptedFilesRemoved: corruptedRemoved,
          orphanedFilesRemoved: orphanedRemoved,
          temporaryFilesRemoved: temporaryRemoved,
          oldestFilesRemoved: 0, // We're counting bytes freed, not files
          totalSpaceFreed: spaceFreed,
          totalFilesRemoved:
              corruptedRemoved + orphanedRemoved + temporaryRemoved,
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Cleanup failed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> removeCorruptedFiles() async {
    try {
      final corruptedFiles = await getCorruptedFiles();
      return await corruptedFiles.fold((failure) => Left(failure), (
        files,
      ) async {
        int removedCount = 0;
        for (final filePath in files) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
              removedCount++;
            }
          } catch (e) {
            // Continue with other files even if one fails
          }
        }
        return Right(removedCount);
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
      final orphanedFiles = await getOrphanedFiles();
      return await orphanedFiles.fold((failure) => Left(failure), (
        files,
      ) async {
        int removedCount = 0;
        for (final filePath in files) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
              removedCount++;
            }
          } catch (e) {
            // Continue with other files even if one fails
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
      final cacheDir = await getCacheDirectory();
      return await cacheDir.fold((failure) => Left(failure), (dir) async {
        int removedCount = 0;
        try {
          final files = dir.listSync();
          for (final entity in files) {
            if (entity is File &&
                (entity.path.contains('.tmp') ||
                    entity.path.contains('.download') ||
                    entity.path.contains('.part'))) {
              try {
                await entity.delete();
                removedCount++;
              } catch (e) {
                // Continue with other files
              }
            }
          }
        } catch (e) {
          // Handle directory listing errors
        }
        return Right(removedCount);
      });
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
      final allAudios = await getAllCachedAudios();
      return await allAudios.fold((failure) => Left(failure), (audios) async {
        // Sort by cached date (oldest first)
        audios.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

        int spaceFreed = 0;
        for (final audio in audios) {
          if (spaceFreed >= targetFreeBytes) break;

          try {
            final file = File(audio.filePath);
            if (await file.exists()) {
              final fileSize = await file.length();
              await file.delete();
              spaceFreed += fileSize;
            }
          } catch (e) {
            // Continue with other files
          }
        }
        return Right(spaceFreed);
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
  Future<Either<CacheFailure, CacheValidationResult>>
  validateCacheIntegrity() async {
    try {
      final allAudios = await getAllCachedAudios();
      return await allAudios.fold((failure) => Left(failure), (audios) async {
        int validFiles = 0;
        int corruptedFiles = 0;
        int missingFiles = 0;

        for (final audio in audios) {
          final file = File(audio.filePath);
          if (!await file.exists()) {
            missingFiles++;
          } else {
            // Validate file integrity if checksum is available
            if (audio.checksum.isNotEmpty) {
              final isValid = await validateFileIntegrity(
                audio.trackId,
                audio.checksum,
              );
              isValid.fold(
                (failure) => corruptedFiles++,
                (valid) => valid ? validFiles++ : corruptedFiles++,
              );
              // Note: isValid is already handled in the fold above
            } else {
              validFiles++; // Assume valid if no checksum
            }
          }
        }

        return Right(
          CacheValidationResult(
            totalFiles: audios.length,
            validFiles: validFiles,
            corruptedFiles: corruptedFiles,
            orphanedFiles: missingFiles,
            missingMetadata: 0,
            inconsistentSizes: 0,
          ),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Cache validation failed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getCacheDirectorySize() async {
    try {
      final cacheDir = await getCacheDirectory();
      return await cacheDir.fold((failure) => Left(failure), (dir) async {
        int totalSize = 0;
        try {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File) {
              totalSize += await entity.length();
            }
          }
        } catch (e) {
          // Handle directory listing errors
        }
        return Right(totalSize);
      });
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
    try {
      final allAudios = await getAllCachedAudios();
      return await allAudios.fold((failure) => Left(failure), (audios) async {
        List<String> corruptedFiles = [];

        for (final audio in audios) {
          final isValid = await validateFileIntegrity(
            audio.trackId,
            audio.checksum,
          );
          isValid.fold((failure) => corruptedFiles.add(audio.filePath), (
            valid,
          ) {
            if (!valid) corruptedFiles.add(audio.filePath);
          });
        }

        return Right(corruptedFiles);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get corrupted files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles() async {
    try {
      final cacheDir = await getCacheDirectory();
      return await cacheDir.fold((failure) => Left(failure), (dir) async {
        final allAudios = await getAllCachedAudios();
        return await allAudios.fold((failure) => Left(failure), (audios) async {
          List<String> orphanedFiles = [];
          Set<String> referencedPaths = audios.map((a) => a.filePath).toSet();

          try {
            await for (final entity in dir.list(recursive: true)) {
              if (entity is File && !referencedPaths.contains(entity.path)) {
                orphanedFiles.add(entity.path);
              }
            }
          } catch (e) {
            // Handle directory listing errors
          }

          return Right(orphanedFiles);
        });
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get orphaned files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getTotalStorageUsage() async {
    return getCacheDirectorySize();
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorageSpace() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final stat = await appDir.stat();
      return Right(stat.size);
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
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    try {
      final cacheDir = await getCacheDirectory();
      return await cacheDir.fold((failure) => Left(failure), (dir) async {
        List<CachedAudio> audios = [];

        try {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File && entity.path.endsWith('.mp3')) {
              // This is a simplified implementation
              // In a real app, you'd read metadata from a database or index file
              final stat = await entity.stat();
              audios.add(
                CachedAudio(
                  trackId: _extractTrackIdFromPath(entity.path),
                  filePath: entity.path,
                  fileSizeBytes: stat.size,
                  cachedAt: stat.modified,
                  checksum: '', // Would be loaded from metadata
                  quality: AudioQuality.medium,
                  status: CacheStatus.cached,
                ),
              );
            }
          }
        } catch (e) {
          // Handle directory listing errors
        }

        return Right(audios);
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get all cached audios: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> validateFileIntegrity(
    String trackId,
    String expectedChecksum,
  ) async {
    try {
      final allAudios = await getAllCachedAudios();
      return await allAudios.fold((failure) => Left(failure), (audios) async {
        final audio = audios.where((a) => a.trackId == trackId).firstOrNull;
        if (audio == null) {
          return Left(
            StorageCacheFailure(
              message: 'Track not found: $trackId',
              type: StorageFailureType.fileNotFound,
            ),
          );
        }

        final actualChecksum = await calculateFileChecksum(audio.filePath);
        return actualChecksum.fold(
          (failure) => Left(failure),
          (checksum) => Right(checksum == expectedChecksum),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'File integrity validation failed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> calculateFileChecksum(
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(
          StorageCacheFailure(
            message: 'File does not exist: $filePath',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      final bytes = await file.readAsBytes();
      final digest = sha1.convert(bytes);
      return Right(digest.toString());
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to calculate checksum: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Directory>> getCacheDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      // Use the same directory as CacheStorageLocalDataSourceImpl
      final cacheDir = Directory('${appDir.path}/$_cacheRootPath');

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      return Right(cacheDir);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache directory: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  /// Extract track ID from file path
  /// This is a simplified implementation - in a real app, you'd have a proper mapping
  String _extractTrackIdFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final nameWithoutExtension = fileName.replaceAll('.mp3', '');
    return nameWithoutExtension;
  }
}

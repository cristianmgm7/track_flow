import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/audio_storage_repository.dart';
import '../datasources/cache_storage_local_data_source.dart';
import '../models/cached_audio_document_unified.dart';

@LazySingleton(as: AudioStorageRepository)
class AudioStorageRepositoryImpl implements AudioStorageRepository {
  final CacheStorageLocalDataSource _localDataSource;
  final DirectoryService _directoryService;

  AudioStorageRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
    required DirectoryService directoryService,
  }) : _localDataSource = localDataSource,
       _directoryService = directoryService;

  @override
  Future<Either<CacheFailure, CachedAudio>> storeAudio(
    AudioTrackId trackId,
    TrackVersionId versionId,
    File audioFile,
  ) async {
    try {
      // Get cache directory using directory service
      final cacheDirResult = await _directoryService.getSubdirectory(
        DirectoryType.audioCache,
        trackId.value,
      );

      if (cacheDirResult.isLeft()) {
        return Left(StorageCacheFailure(
          message: 'Failed to get cache directory',
          type: StorageFailureType.diskError,
        ));
      }

      final trackDir = cacheDirResult.getOrElse(() => throw Exception('Unreachable'));

      // Extract file extension
      final ext = _extractExtension(audioFile.path);

      // Build final path
      final filename = '${versionId.value}$ext';
      final finalPath = '${trackDir.path}/$filename';

      // Copy file to cache
      final cachedFile = await audioFile.copy(finalPath);

      // Get file info
      final fileSize = await cachedFile.length();
      final checksumDigest = await sha1.bind(cachedFile.openRead()).first;
      final checksum = checksumDigest.toString();

      // Get relative path using directory service
      final relativePath = _directoryService.getRelativePath(
        finalPath,
        DirectoryType.audioCache,
      );

      final unifiedDocument =
          CachedAudioDocumentUnified()
            ..trackId = trackId.value
            ..versionId = versionId.value
            ..relativePath =
                relativePath // Guardar ruta relativa
            ..fileSizeBytes = fileSize
            ..cachedAt = DateTime.now()
            ..checksum = checksum
            ..quality = AudioQuality.medium
            ..status = CacheStatus.cached
            ..lastAccessed = DateTime.now()
            ..downloadAttempts = 0
            ..lastDownloadAttempt = null
            ..failureReason = null
            ..originalUrl = '';

      // Store unified document in local database
      final storeResult = await _localDataSource.storeUnifiedCachedAudio(
        unifiedDocument,
      );

      return storeResult.fold((failure) => Left(failure), (unifiedDoc) async {
        // Resolve absolute path from relative using DirectoryService
        final absolutePathResult = await _directoryService.getAbsolutePath(
          unifiedDoc.relativePath,
          DirectoryType.audioCache,
        );

        return absolutePathResult.fold(
          (failure) => Left(
            StorageCacheFailure(
              message: failure.message,
              type: StorageFailureType.diskError,
            ),
          ),
          (absolutePath) => Right(
            CachedAudio(
              trackId: unifiedDoc.trackId,
              versionId: unifiedDoc.versionId,
              filePath: absolutePath,
              fileSizeBytes: unifiedDoc.fileSizeBytes,
              cachedAt: unifiedDoc.cachedAt,
              checksum: unifiedDoc.checksum,
              quality: unifiedDoc.quality,
              status: unifiedDoc.status,
            ),
          ),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to store audio: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  String? _extractExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    if (ext.length > 5) return null;
    return ext;
  }


  // Removed unused helper; relative path conversion occurs at store time directly

  /// Validate and clean corrupted cache entries
  /// This should be called at app startup
  @override
  Future<Either<CacheFailure, int>> validateAndCleanCache() async {
    try {
      final docs = await _localDataSource.watchAllCachedAudios().first;
      int cleanedCount = 0;

      for (final doc in docs) {
        try {
          // Resolve absolute path and check existence
          final absPathResult = await _directoryService.getAbsolutePath(
            doc.relativePath,
            DirectoryType.audioCache,
          );

          final exists = await absPathResult.fold(
            (_) async => false,
            (absPath) async => await File(absPath).exists(),
          );

          if (!exists) {
            // Remove specific version entry from DB
            await _localDataSource.deleteAudioFile(
              doc.trackId,
              versionId: doc.versionId,
            );
            cleanedCount++;
          }
        } catch (e) {
          // Error validating file, remove specific version entry
          await _localDataSource.deleteAudioFile(
            doc.trackId,
            versionId: doc.versionId,
          );
          cleanedCount++;
        }
      }

      return Right(cleanedCount);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate and clean cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
  }) async {
    try {
      // Try to get from database first
      final result = await _localDataSource.getCachedAudioPath(
        trackId.value,
        versionId: versionId?.value,
      );

      return result.fold((failure) {
        // Fallback to file system search for legacy compatibility
        return _getCachedAudioPathFromFileSystem(trackId, versionId);
      }, (relativePath) async {
        // Resolve relative path to absolute via DirectoryService
        final absPathResult = await _directoryService.getAbsolutePath(
          relativePath,
          DirectoryType.audioCache,
        );
        return absPathResult.fold(
          (f) => Left(
            StorageCacheFailure(
              message: f.message,
              type: StorageFailureType.diskError,
            ),
          ),
          (absolutePath) => Right(absolutePath),
        );
      });
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached audio path: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Either<CacheFailure, String>> _getCachedAudioPathFromFileSystem(
    AudioTrackId trackId,
    TrackVersionId? versionId,
  ) async {
    try {
      // Generate expected file path based on new structure
      final trackDirResult = await _directoryService.getSubdirectory(
        DirectoryType.audioCache,
        trackId.value,
      );

      return await trackDirResult.fold(
        (failure) async => Left(
          StorageCacheFailure(
            message: failure.message,
            type: StorageFailureType.diskError,
          ),
        ),
        (trackDir) async {
          if (!await trackDir.exists()) {
            return Left(
              StorageCacheFailure(
                message: 'Track cache directory not found: ${trackId.value}',
                type: StorageFailureType.fileNotFound,
              ),
            );
          }

          // Try different extensions
          final extensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'];

          if (versionId != null) {
            // Look for specific version file
            for (final ext in extensions) {
              final filePath = '${trackDir.path}/${versionId.value}$ext';
              final file = File(filePath);
              if (await file.exists()) {
                return Right(filePath);
              }
            }
          } else {
            // Look for any cached file in track directory (legacy compatibility)
            try {
              final files = await trackDir.list().toList();
              for (final file in files) {
                if (file is File) {
                  final fileName = file.path.split('/').last;
                  // Check if it's an audio file
                  for (final ext in extensions) {
                    if (fileName.endsWith(ext)) {
                      return Right(file.path);
                    }
                  }
                }
              }
            } catch (e) {
              // Directory might not exist or have permission issues
              return Left(
                StorageCacheFailure(
                  message: 'Failed to access cache directory: $e',
                  type: StorageFailureType.diskError,
                ),
              );
            }
          }

          // File not found
          final versionMsg = versionId != null
              ? 'version ${versionId.value}'
              : 'track ${trackId.value}';
          return Left(
            StorageCacheFailure(
              message: 'Cached audio file not found for $versionMsg',
              type: StorageFailureType.fileNotFound,
            ),
          );
        },
      );
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
  Future<Either<CacheFailure, bool>> audioExists(AudioTrackId trackId) async {
    // Check DB first then verify file exists in FS
    final dbExists = await _localDataSource.audioExists(trackId.value);
    return dbExists.fold(
      (failure) => Left(failure),
      (present) async {
        if (!present) return const Right(false);
        final pathResult = await getCachedAudioPath(trackId);
        return pathResult.fold(
          (failure) => Left(failure),
          (absolutePath) async => Right(await File(absolutePath).exists()),
        );
      },
    );
  }

  // New method to check if specific version exists
  @override
  Future<Either<CacheFailure, bool>> audioVersionExists(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    return await _localDataSource.audioExists(
      trackId.value,
      versionId: versionId.value,
    );
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    AudioTrackId trackId,
  ) async {
    final result = await _localDataSource.getCachedAudio(trackId.value);
    return result.fold(
      (failure) => Left(failure),
      (doc) async {
        if (doc == null) return const Right(null);
        final absPathResult = await _directoryService.getAbsolutePath(
          doc.relativePath,
          DirectoryType.audioCache,
        );
        return absPathResult.fold(
          (f) => Left(
            StorageCacheFailure(
              message: f.message,
              type: StorageFailureType.diskError,
            ),
          ),
          (absolutePath) => Right(
            CachedAudio(
              trackId: doc.trackId,
              versionId: doc.versionId,
              filePath: absolutePath,
              fileSizeBytes: doc.fileSizeBytes,
              cachedAt: doc.cachedAt,
              checksum: doc.checksum,
              quality: doc.quality,
              status: doc.status,
            ),
          ),
        );
      },
    );
  }

  // New method to get cached audio by version
  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudioByVersion(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    final result = await _localDataSource.getCachedAudio(
      trackId.value,
      versionId: versionId.value,
    );
    return result.fold(
      (failure) => Left(failure),
      (doc) async {
        if (doc == null) return const Right(null);
        final absPathResult = await _directoryService.getAbsolutePath(
          doc.relativePath,
          DirectoryType.audioCache,
        );
        return absPathResult.fold(
          (f) => Left(
            StorageCacheFailure(
              message: f.message,
              type: StorageFailureType.diskError,
            ),
          ),
          (absolutePath) => Right(
            CachedAudio(
              trackId: doc.trackId,
              versionId: doc.versionId,
              filePath: absolutePath,
              fileSizeBytes: doc.fileSizeBytes,
              cachedAt: doc.cachedAt,
              checksum: doc.checksum,
              quality: doc.quality,
              status: doc.status,
            ),
          ),
        );
      },
    );
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(
    AudioTrackId trackId,
  ) async {
    try {
      // Remove files from FS under track directory
      final trackDirResult = await _directoryService.getSubdirectory(
        DirectoryType.audioCache,
        trackId.value,
      );

      await trackDirResult.fold(
        (_) async {},
        (trackDir) async {
          if (await trackDir.exists()) {
            await trackDir.delete(recursive: true);
          }
        },
      );

      // Remove DB entries
      return await _localDataSource.deleteAudioFile(trackId.value);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to delete audio file: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  // New method to delete specific version
  @override
  Future<Either<CacheFailure, Unit>> deleteAudioVersionFile(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    try {
      // Try to resolve file path and delete from FS
      final pathResult = await getCachedAudioPath(
        trackId,
        versionId: versionId,
      );

      await pathResult.fold(
        (_) async {},
        (absolutePath) async {
          final file = File(absolutePath);
          if (await file.exists()) {
            await file.delete();
          }
        },
      );

      // Remove DB entry
      return await _localDataSource.deleteAudioFile(
        trackId.value,
        versionId: versionId.value,
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to delete audio version file: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  // Removed batch operations to simplify repository

  @override
  Stream<int> watchStorageUsage() {
    return _localDataSource.watchAllCachedAudios().map((docs) {
      int totalSize = 0;
      for (final d in docs) {
        totalSize += d.fileSizeBytes;
      }
      return totalSize;
    });
  }

  @override
  Stream<List<CachedAudio>> watchAllCachedAudios() {
    return _localDataSource.watchAllCachedAudios().asyncMap((docs) async {
      final cachedAudios = <CachedAudio>[];
      for (final doc in docs) {
        final absPathResult = await _directoryService.getAbsolutePath(
          doc.relativePath,
          DirectoryType.audioCache,
        );
        await absPathResult.fold(
          (_) async {},
          (absolutePath) async {
            cachedAudios.add(
              CachedAudio(
                trackId: doc.trackId,
                versionId: doc.versionId,
                filePath: absolutePath,
                fileSizeBytes: doc.fileSizeBytes,
                cachedAt: doc.cachedAt,
                checksum: doc.checksum,
                quality: doc.quality,
                status: doc.status,
              ),
            );
          },
        );
      }
      return cachedAudios;
    });
  }

  @override
  Future<Either<CacheFailure, int>> getStorageUsage() async {
    try {
      final docs = await _localDataSource.watchAllCachedAudios().first;
      int totalSize = 0;
      for (final d in docs) {
        totalSize += d.fileSizeBytes;
      }
      return Right(totalSize);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get storage usage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorage() async {
    try {
      // Get system available storage
      // This is a simplified implementation - in production you'd want to
      // check actual disk space available
      const maxCacheSize = 1024 * 1024 * 1024; // 1GB max cache size

      final usageResult = await getStorageUsage();
      return usageResult.fold(
        (failure) => Left(failure),
        (currentUsage) => Right(maxCacheSize - currentUsage),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get available storage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<bool> watchTrackCacheStatus(
    AudioTrackId trackId, {
    TrackVersionId? versionId,
  }) {
    // Map DB presence to actual FS existence for the first matching doc
    return _localDataSource
        .watchTrackCacheStatus(
          trackId.value,
          versionId: versionId?.value,
        )
        .asyncMap((present) async {
          if (!present) return false;
          final docResult = await _localDataSource.getCachedAudio(
            trackId.value,
            versionId: versionId?.value,
          );
          return await docResult.fold(
            (_) async => false,
            (doc) async {
              if (doc == null) return false;
              final absPathResult = await _directoryService.getAbsolutePath(
                doc.relativePath,
                DirectoryType.audioCache,
              );
              return await absPathResult.fold(
                (_) async => false,
                (absolutePath) async => await File(absolutePath).exists(),
              );
            },
          );
        });
  }

  // No longer needed; extension is handled at download time
}

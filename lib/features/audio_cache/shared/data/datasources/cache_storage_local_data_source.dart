import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/value_objects/cache_key.dart';
import '../models/cached_audio_document.dart';

abstract class CacheStorageLocalDataSource {
  // Core file operations
  Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(CachedAudio audio);
  
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);
  
  Future<Either<CacheFailure, bool>> audioExists(String trackId);
  
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);
  
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);
  
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(String trackId, String expectedChecksum);
  
  // Batch operations
  Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(List<String> trackIds);
  
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds);
  
  // Storage management
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();
  
  Future<Either<CacheFailure, int>> getTotalStorageUsage();
  
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();
  
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();
  
  // Cache key operations
  CacheKey generateCacheKey(String trackId, String audioUrl);
  
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);
  
  // Reactive streams
  Stream<int> watchStorageUsage();
}

@LazySingleton(as: CacheStorageLocalDataSource)
class CacheStorageLocalDataSourceImpl implements CacheStorageLocalDataSource {
  final Isar _isar;
  static const String _cacheSubDirectory = 'audio_cache';

  CacheStorageLocalDataSourceImpl(this._isar);

  @override
  Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(CachedAudio audio) async {
    try {
      await _isar.writeTxn(() async {
        final document = CachedAudioDocument.fromEntity(audio);
        await _isar.cachedAudioDocuments.put(document);
      });

      return Right(audio);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to store cached audio: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId) async {
    try {
      final document = await _isar.cachedAudioDocuments
          .where()
          .trackIdEqualTo(trackId)
          .findFirst();

      if (document == null) {
        return Left(
          StorageCacheFailure(
            message: 'Audio file not found for track: $trackId',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      final file = File(document.filePath);
      if (!await file.exists()) {
        return Left(
          StorageCacheFailure(
            message: 'Audio file does not exist at path: ${document.filePath}',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      return Right(document.filePath);
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
  Future<Either<CacheFailure, bool>> audioExists(String trackId) async {
    try {
      final pathResult = await getCachedAudioPath(trackId);
      return pathResult.fold(
        (failure) => const Right(false),
        (path) async {
          final file = File(path);
          return Right(await file.exists());
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check if audio exists: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId) async {
    try {
      final document = await _isar.cachedAudioDocuments
          .where()
          .trackIdEqualTo(trackId)
          .findFirst();

      return Right(document?.toEntity());
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached audio: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId) async {
    try {
      // Get the file path first
      final pathResult = await getCachedAudioPath(trackId);
      
      await _isar.writeTxn(() async {
        // Delete from Isar
        final document = await _isar.cachedAudioDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();
        
        if (document != null) {
          await _isar.cachedAudioDocuments.delete(document.isarId);
        }
      });

      // Delete physical file if it exists
      await pathResult.fold(
        (failure) async {
          // File not found in database, that's okay
        },
        (path) async {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to delete audio file: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  ) async {
    try {
      final pathResult = await getCachedAudioPath(trackId);
      
      return await pathResult.fold(
        (failure) => Left(failure),
        (path) async {
          final file = File(path);
          if (!await file.exists()) {
            return const Right(false);
          }

          final bytes = await file.readAsBytes();
          final actualChecksum = sha1.convert(bytes).toString();
          
          return Right(actualChecksum == expectedChecksum);
        },
      );
    } catch (e) {
      return Left(
        CorruptedCacheFailure(
          message: 'Failed to verify file integrity: $e',
          trackId: trackId,
          checksum: expectedChecksum,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  ) async {
    try {
      final documents = await _isar.cachedAudioDocuments
          .where()
          .anyOf(trackIds, (q, trackId) => q.trackIdEqualTo(trackId))
          .findAll();

      final audios = documents.map((doc) => doc.toEntity()).toList();
      return Right(audios);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get multiple cached audios: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(
    List<String> trackIds,
  ) async {
    try {
      final deletedTrackIds = <String>[];

      for (final trackId in trackIds) {
        final result = await deleteAudioFile(trackId);
        result.fold(
          (failure) {
            // Log failure but continue with other files
          },
          (_) => deletedTrackIds.add(trackId),
        );
      }

      return Right(deletedTrackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to delete multiple audio files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    try {
      final documents = await _isar.cachedAudioDocuments.where().findAll();
      final audios = documents.map((doc) => doc.toEntity()).toList();
      return Right(audios);
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
  Future<Either<CacheFailure, int>> getTotalStorageUsage() async {
    try {
      final documents = await _isar.cachedAudioDocuments.where().findAll();
      final totalSize = documents.fold<int>(
        0,
        (sum, doc) => sum + doc.fileSizeBytes,
      );
      
      return Right(totalSize);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get total storage usage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles() async {
    try {
      final documents = await _isar.cachedAudioDocuments.where().findAll();
      final corruptedTrackIds = <String>[];

      for (final doc in documents) {
        final audio = doc.toEntity();
        if (audio.status == CacheStatus.corrupted) {
          corruptedTrackIds.add(audio.trackId);
        } else {
          // Verify integrity for cached files
          final integrityResult = await verifyFileIntegrity(
            audio.trackId,
            audio.checksum,
          );
          
          integrityResult.fold(
            (failure) {
              // Consider as corrupted if we can't verify
              corruptedTrackIds.add(audio.trackId);
            },
            (isValid) {
              if (!isValid) {
                corruptedTrackIds.add(audio.trackId);
              }
            },
          );
        }
      }

      return Right(corruptedTrackIds);
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
      // Get cache directory
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return const Right([]);
      }

      // Get all files in cache directory
      final files = cacheDir.listSync().whereType<File>().toList();
      
      // Get all tracked files from database
      final documents = await _isar.cachedAudioDocuments.where().findAll();
      final trackedPaths = documents.map((doc) => doc.filePath).toSet();

      // Find orphaned files
      final orphanedFiles = files
          .where((file) => !trackedPaths.contains(file.path))
          .map((file) => file.path)
          .toList();

      return Right(orphanedFiles);
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
  CacheKey generateCacheKey(String trackId, String audioUrl) {
    return CacheKey.fromTrackAndUrl(trackId, audioUrl);
  }

  @override
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = '${key.value}.mp3'; // Default to mp3 for now
      final filePath = '${cacheDir.path}/$fileName';
      
      return Right(filePath);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get file path from cache key: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<int> watchStorageUsage() {
    return _isar.cachedAudioDocuments
        .where()
        .watch(fireImmediately: true)
        .asyncMap((_) async {
          final result = await getTotalStorageUsage();
          return result.fold((failure) => 0, (size) => size);
        });
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
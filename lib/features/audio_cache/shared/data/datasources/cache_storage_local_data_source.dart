import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/value_objects/cache_key.dart';
import '../models/cached_audio_document_unified.dart';

abstract class CacheStorageLocalDataSource {
  Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(
    CachedAudio cachedAudio,
  );

  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);

  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);

  Future<Either<CacheFailure, bool>> audioExists(String trackId);

  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);

  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  );

  Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  );

  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(
    List<String> trackIds,
  );

  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();

  Future<Either<CacheFailure, int>> getTotalStorageUsage();

  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();

  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();

  Stream<int> watchStorageUsage();

  CacheKey generateCacheKey(String trackId, String audioUrl);

  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);

  Future<Either<CacheFailure, CachedAudioDocumentUnified>>
  storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc);
}

@LazySingleton(as: CacheStorageLocalDataSource)
class CacheStorageLocalDataSourceImpl implements CacheStorageLocalDataSource {
  final Isar _isar;

  CacheStorageLocalDataSourceImpl(this._isar);

  @override
  Future<Either<CacheFailure, CachedAudio>> storeCachedAudio(
    CachedAudio cachedAudio,
  ) async {
    try {
      // Convert to unified document
      final unifiedDoc =
          CachedAudioDocumentUnified()
            ..trackId = cachedAudio.trackId
            ..filePath = cachedAudio.filePath
            ..fileSizeBytes = cachedAudio.fileSizeBytes
            ..cachedAt = cachedAudio.cachedAt
            ..checksum = cachedAudio.checksum
            ..quality = cachedAudio.quality
            ..status = cachedAudio.status
            ..referenceCount = 1
            ..lastAccessed = DateTime.now()
            ..references = ['individual']
            ..downloadAttempts = 0
            ..lastDownloadAttempt = null
            ..failureReason = null
            ..originalUrl = '';

      await _isar.writeTxn(() async {
        await _isar.cachedAudioDocumentUnifieds.put(unifiedDoc);
      });

      return Right(cachedAudio);
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
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    String trackId,
  ) async {
    try {
      final unifiedDoc =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (unifiedDoc == null) {
        return const Right(null);
      }

      // Update last accessed
      await _isar.writeTxn(() async {
        unifiedDoc.lastAccessed = DateTime.now();
        await _isar.cachedAudioDocumentUnifieds.put(unifiedDoc);
      });

      return Right(unifiedDoc.toCachedAudio());
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
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId,
  ) async {
    try {
      final unifiedDoc =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (unifiedDoc == null) {
        return Left(
          StorageCacheFailure(
            message: 'Cached audio not found',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      return Right(unifiedDoc.filePath);
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
      final count =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .count();
      return Right(count > 0);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check audio exists: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId) async {
    try {
      final unifiedDoc =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (unifiedDoc != null) {
        // Delete file from disk
        final file = File(unifiedDoc.filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Delete from database
        await _isar.writeTxn(() async {
          await _isar.cachedAudioDocumentUnifieds.delete(unifiedDoc.isarId);
        });
      }

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
      final unifiedDoc =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (unifiedDoc == null) {
        return const Right(false);
      }

      final file = File(unifiedDoc.filePath);
      if (!await file.exists()) {
        return const Right(false);
      }

      final bytes = await file.readAsBytes();
      final actualChecksum = sha1.convert(bytes).toString();

      return Right(actualChecksum == expectedChecksum);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to verify file integrity: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  ) async {
    try {
      final List<CachedAudioDocumentUnified> unifiedDocs = [];

      // Query each track ID individually since Isar doesn't have trackIdIsIn
      for (final trackId in trackIds) {
        final doc =
            await _isar.cachedAudioDocumentUnifieds
                .filter()
                .trackIdEqualTo(trackId)
                .findFirst();
        if (doc != null) {
          unifiedDocs.add(doc);
        }
      }

      final cachedAudios =
          unifiedDocs.map((doc) => doc.toCachedAudio()).toList();
      return Right(cachedAudios);
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
          (failure) => null, // Skip failed deletions
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
      final unifiedDocs =
          await _isar.cachedAudioDocumentUnifieds.where().findAll();

      final cachedAudios =
          unifiedDocs.map((doc) => doc.toCachedAudio()).toList();
      return Right(cachedAudios);
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
      final unifiedDocs =
          await _isar.cachedAudioDocumentUnifieds.where().findAll();

      int totalSize = 0;
      for (final doc in unifiedDocs) {
        totalSize += doc.fileSizeBytes;
      }

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
      final corruptedTrackIds = <String>[];

      final unifiedDocs =
          await _isar.cachedAudioDocumentUnifieds.where().findAll();

      for (final doc in unifiedDocs) {
        final file = File(doc.filePath);
        if (!await file.exists()) {
          corruptedTrackIds.add(doc.trackId);
          continue;
        }

        final bytes = await file.readAsBytes();
        final actualChecksum = sha1.convert(bytes).toString();

        if (actualChecksum != doc.checksum) {
          corruptedTrackIds.add(doc.trackId);
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
      final orphanedPaths = <String>[];
      final cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        final files = cacheDir.listSync(recursive: true).whereType<File>();

        for (final file in files) {
          // Skip temporary files
          if (file.path.endsWith('.tmp') ||
              file.path.endsWith('.part') ||
              file.path.endsWith('.download')) {
            continue;
          }

          // Check if file has corresponding database entry
          final hasEntry =
              await _isar.cachedAudioDocumentUnifieds
                  .filter()
                  .filePathEqualTo(file.path)
                  .count() >
              0;

          if (!hasEntry) {
            orphanedPaths.add(file.path);
          }
        }
      }

      return Right(orphanedPaths);
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
  Stream<int> watchStorageUsage() {
    return _isar.cachedAudioDocumentUnifieds
        .where()
        .watch(fireImmediately: true)
        .map((docs) {
          int totalSize = 0;
          for (final doc in docs) {
            totalSize += doc.fileSizeBytes;
          }
          return totalSize;
        });
  }

  @override
  CacheKey generateCacheKey(String trackId, String audioUrl) {
    final urlHash = sha1.convert(audioUrl.codeUnits).toString();
    return CacheKey.composite(trackId, urlHash);
  }

  @override
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(
    CacheKey key,
  ) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filename = '${key.trackId}_${key.checksum}.mp3';
      return Right('${cacheDir.path}/$filename');
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
  Future<Either<CacheFailure, CachedAudioDocumentUnified>>
  storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.cachedAudioDocumentUnifieds.put(unifiedDoc);
      });

      return Right(unifiedDoc);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to store unified cached audio: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/audio_cache');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }
}

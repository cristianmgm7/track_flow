import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cached_audio_document_unified.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/value_objects/cache_key.dart';

abstract class CacheStorageLocalDataSource {
  Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(
    CachedAudioDocumentUnified cachedAudio,
  );

  Future<Either<CacheFailure, CachedAudioDocumentUnified?>> getCachedAudio(
    String trackId,
  );

  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);

  Future<Either<CacheFailure, bool>> audioExists(String trackId);

  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);

  CacheKey generateCacheKey(String trackId, String audioUrl);

  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);

  Future<Either<CacheFailure, CachedAudioDocumentUnified>>
  storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc);

  /// Watch cache status for a single track
  Stream<bool> watchTrackCacheStatus(String trackId);

  /// Streams used by cache_management; kept temporarily
  Stream<List<CachedAudioDocumentUnified>> watchAllCachedAudios();
}

@LazySingleton(as: CacheStorageLocalDataSource)
class CacheStorageLocalDataSourceImpl implements CacheStorageLocalDataSource {
  final Isar _isar;

  CacheStorageLocalDataSourceImpl(this._isar);

  @override
  Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(
    CachedAudioDocumentUnified cachedAudio,
  ) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.cachedAudioDocumentUnifieds.put(cachedAudio);
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
  Future<Either<CacheFailure, CachedAudioDocumentUnified?>> getCachedAudio(
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

      return Right(unifiedDoc);
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
      final unifiedDoc =
          await _isar.cachedAudioDocumentUnifieds
              .filter()
              .trackIdEqualTo(trackId)
              .findFirst();

      if (unifiedDoc == null) {
        return const Right(false);
      }

      final file = File(unifiedDoc.filePath);
      final exists = await file.exists();
      return Right(exists);
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
  Stream<List<CachedAudioDocumentUnified>> watchAllCachedAudios() {
    return _isar.cachedAudioDocumentUnifieds
        .where()
        .watch(fireImmediately: true)
        .map((docs) => docs.toList());
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

  /// Watch cache status for a single track
  @override
  Stream<bool> watchTrackCacheStatus(String trackId) {
    return _isar.cachedAudioDocumentUnifieds
        .filter()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .asyncMap((docs) async {
          if (docs.isEmpty) return false;
          final doc = docs.first;
          try {
            return await File(doc.filePath).exists();
          } catch (_) {
            return false;
          }
        });
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    // Store persistent audio files under Documents/trackflow/audio
    final cacheDir = Directory('${appDir.path}/trackflow/audio');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }
}

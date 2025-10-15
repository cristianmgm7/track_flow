import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../models/cached_audio_document_unified.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/value_objects/cache_key.dart';

abstract class CacheStorageLocalDataSource {
  Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(
    CachedAudioDocumentUnified cachedAudio,
  );

  Future<Either<CacheFailure, CachedAudioDocumentUnified?>> getCachedAudio(
    String trackId, {
    String? versionId,
  });

  Future<Either<CacheFailure, String>> getCachedAudioPath(
    String trackId, {
    String? versionId,
  });

  Future<Either<CacheFailure, bool>> audioExists(
    String trackId, {
    String? versionId,
  });

  Future<Either<CacheFailure, Unit>> deleteAudioVersion(
    String trackId, {
    String? versionId,
  });

  CacheKey generateCacheKey(String trackId, String audioUrl);

  Future<Either<CacheFailure, CachedAudioDocumentUnified>>
  storeUnifiedCachedAudio(CachedAudioDocumentUnified unifiedDoc);

  /// Watch cache status for a single track or specific version
  Stream<bool> watchTrackCacheStatus(String trackId, {String? versionId});

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
    String trackId, {
    String? versionId,
  }) async {
    try {
      final query = _isar.cachedAudioDocumentUnifieds.filter().trackIdEqualTo(
        trackId,
      );

      // If versionId is provided, filter by it too
      final unifiedDoc =
          versionId != null
              ? await query.versionIdEqualTo(versionId).findFirst()
              : await query.findFirst();

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
    String trackId, {
    String? versionId,
  }) async {
    try {
      final query = _isar.cachedAudioDocumentUnifieds.filter().trackIdEqualTo(
        trackId,
      );

      // If versionId is provided, filter by it too
      final unifiedDoc =
          versionId != null
              ? await query.versionIdEqualTo(versionId).findFirst()
              : await query.findFirst();

      if (unifiedDoc == null) {
        return Left(
          StorageCacheFailure(
            message:
                'Cached audio not found for track $trackId${versionId != null ? ' and version $versionId' : ''}',
            type: StorageFailureType.fileNotFound,
          ),
        );
      }

      // Return RELATIVE path only; repository resolves to absolute
      return Right(unifiedDoc.relativePath);
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
  Future<Either<CacheFailure, bool>> audioExists(
    String trackId, {
    String? versionId,
  }) async {
    try {
      final query = _isar.cachedAudioDocumentUnifieds.filter().trackIdEqualTo(
        trackId,
      );

      // If versionId is provided, filter by it too
      final unifiedDoc =
          versionId != null
              ? await query.versionIdEqualTo(versionId).findFirst()
              : await query.findFirst();

      // Only check DB presence here; FS checks are handled by repository
      return Right(unifiedDoc != null);
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
  Future<Either<CacheFailure, Unit>> deleteAudioVersion(
    String trackId, {
    String? versionId,
  }) async {
    try {
      if (versionId != null) {
        // Delete specific version
        final unifiedDoc =
            await _isar.cachedAudioDocumentUnifieds
                .filter()
                .trackIdEqualTo(trackId)
                .versionIdEqualTo(versionId)
                .findFirst();

        if (unifiedDoc != null) {
          await _isar.writeTxn(() async {
            await _isar.cachedAudioDocumentUnifieds.delete(unifiedDoc.isarId);
          });
        }
      } else {
        // Delete all docs for trackId from DB; repository handles FS removal
        final docs = await _isar.cachedAudioDocumentUnifieds
            .filter()
            .trackIdEqualTo(trackId)
            .findAll();
        if (docs.isNotEmpty) {
          await _isar.writeTxn(() async {
            for (final d in docs) {
              await _isar.cachedAudioDocumentUnifieds.delete(d.isarId);
            }
          });
        }
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

  // getFilePathFromCacheKey removed: path construction is handled by DirectoryService in repository

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

  /// Watch cache status for a single track or specific version
  @override
  Stream<bool> watchTrackCacheStatus(String trackId, {String? versionId}) {
    final query = _isar.cachedAudioDocumentUnifieds.filter().trackIdEqualTo(
      trackId,
    );

    // If versionId is provided, filter by it too
    final stream =
        versionId != null
            ? query.versionIdEqualTo(versionId).watch(fireImmediately: true)
            : query.watch(fireImmediately: true);

    // Reflect DB presence only; FS verification handled by repository/UI if needed
    return stream.map((docs) => docs.isNotEmpty);
  }
}

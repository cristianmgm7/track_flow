import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../audio_cache/domain/entities/cached_audio.dart';
import '../../../audio_cache/domain/failures/cache_failure.dart';
import '../../../audio_cache/data/models/cached_audio_document_unified.dart';
import '../../../audio_cache/data/datasources/cache_storage_local_data_source.dart'
    as storage;

/// Thin data source for cache management feature.
/// Delegates to the audio_cache local storage data source.
///

abstract class CacheManagementLocalDataSource {
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();

  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);

  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  );

  Future<Either<CacheFailure, bool>> audioExists(String trackId);

  Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(
    CachedAudioDocumentUnified cachedAudio,
  );

  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);
}

@LazySingleton(as: CacheManagementLocalDataSource)
class CacheManagementLocalDataSourceImpl
    implements CacheManagementLocalDataSource {
  final storage.CacheStorageLocalDataSource _delegate;

  CacheManagementLocalDataSourceImpl({
    required storage.CacheStorageLocalDataSource local,
  }) : _delegate = local;

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios() async {
    try {
      final docs = await _delegate.watchAllCachedAudios().first;
      return Right(docs.map((d) => d.toCachedAudio()).toList());
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: e.toString(),
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    String trackId,
  ) async {
    final result = await _delegate.getCachedAudio(trackId);
    return result.fold(
      (failure) => Left(failure),
      (doc) => Right(doc?.toCachedAudio()),
    );
  }

  @override
  Future<Either<CacheFailure, bool>> verifyFileIntegrity(
    String trackId,
    String expectedChecksum,
  ) {
    // This method was removed from the local DS; verify via repository/service in management layer instead
    return Future.value(const Right(false));
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(String trackId) {
    return _delegate.audioExists(trackId);
  }

  @override
  Future<Either<CacheFailure, CachedAudioDocumentUnified>> storeCachedAudio(
    CachedAudioDocumentUnified cachedAudio,
  ) {
    return _delegate.storeCachedAudio(cachedAudio);
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId) {
    return _delegate.deleteAudioFile(trackId);
  }
}

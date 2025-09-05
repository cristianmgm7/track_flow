import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/audio_storage_repository.dart';
import '../datasources/cache_storage_local_data_source.dart';
import '../models/cached_audio_document_unified.dart';

@LazySingleton(as: AudioStorageRepository)
class AudioStorageRepositoryImpl implements AudioStorageRepository {
  final CacheStorageLocalDataSource _localDataSource;

  AudioStorageRepositoryImpl({
    required CacheStorageLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<CacheFailure, CachedAudio>> storeAudio(
    AudioTrackId trackId,
    File audioFile, {
    String? referenceId,
    bool canDelete = true,
  }) async {
    try {
      // The file is already in its final cache location
      final destinationFile = audioFile;

      // Verify file and calculate checksum (streaming)
      final fileSize = await destinationFile.length();
      final checksumDigest = await sha1.bind(destinationFile.openRead()).first;
      final checksum = checksumDigest.toString();

      // Create unified document with both file and metadata information
      final unifiedDocument =
          CachedAudioDocumentUnified()
            ..trackId = trackId.value
            ..filePath = destinationFile.path
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

      return storeResult.fold((failure) => Left(failure), (unifiedDoc) {
        // Convert back to CachedAudio for return
        final cachedAudio = unifiedDoc.toCachedAudio();
        return Right(cachedAudio);
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

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(
    AudioTrackId trackId,
  ) async {
    return await _localDataSource.getCachedAudioPath(trackId.value);
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(AudioTrackId trackId) async {
    return await _localDataSource.audioExists(trackId.value);
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(
    AudioTrackId trackId,
  ) async {
    final result = await _localDataSource.getCachedAudio(trackId.value);
    return result.fold(
      (failure) => Left(failure),
      (doc) => Right(doc?.toCachedAudio()),
    );
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(
    AudioTrackId trackId,
  ) async {
    return await _localDataSource.deleteAudioFile(trackId.value);
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
    return _localDataSource.watchAllCachedAudios().map(
      (docs) => docs.map((d) => d.toCachedAudio()).toList(),
    );
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
  Stream<bool> watchTrackCacheStatus(AudioTrackId trackId) {
    return _localDataSource.watchTrackCacheStatus(trackId.value);
  }

  // No longer needed; extension is handled at download time
}

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
      // Generate storage path for the audio file
      // Preserve original extension from the downloaded file if possible
      final originalPath = audioFile.path;
      final detectedExt = _extractExtension(originalPath) ?? '.mp3';
      final cacheKey = _localDataSource.generateCacheKey(trackId.value, '');
      final filePathResult = await _localDataSource.getFilePathFromCacheKey(
        cacheKey,
      );

      return await filePathResult.fold((failure) => Left(failure), (
        destinationPath,
      ) async {
        // If destination path has a different extension, adjust it
        String finalDestinationPath = destinationPath.replaceAll(
          RegExp(r'\.[^/.]+$'),
          detectedExt,
        );

        // Copy the file to the cache location
        final destinationFile = await audioFile.copy(finalDestinationPath);

        // Verify file and calculate checksum
        final fileSize = await destinationFile.length();
        final bytes = await destinationFile.readAsBytes();
        final checksum = sha1.convert(bytes).toString();

        // Create unified document with both file and metadata information
        final unifiedDocument =
            CachedAudioDocumentUnified()
              ..trackId = trackId.value
              ..filePath = finalDestinationPath
              ..fileSizeBytes = fileSize
              ..cachedAt = DateTime.now()
              ..checksum = checksum
              ..quality = AudioQuality.medium
              ..status = CacheStatus.cached
              ..referenceCount = 1
              ..lastAccessed = DateTime.now()
              ..references = [
                if (referenceId != null) referenceId else 'individual',
              ]
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

  @override
  Future<Either<CacheFailure, Map<AudioTrackId, CachedAudio>>>
  getMultipleCachedAudios(List<AudioTrackId> trackIds) async {
    return await _localDataSource
        .getMultipleCachedAudios(trackIds.map((id) => id.value).toList())
        .then(
          (result) => result.fold((failure) => Left(failure), (audios) {
            final Map<AudioTrackId, CachedAudio> audioMap = {};
            for (final audioDoc in audios) {
              audioMap[AudioTrackId.fromUniqueString(audioDoc.trackId)] =
                  audioDoc.toCachedAudio();
            }
            return Right(audioMap);
          }),
        );
  }

  @override
  Future<Either<CacheFailure, List<AudioTrackId>>> deleteMultipleAudioFiles(
    List<AudioTrackId> trackIds,
  ) async {
    final result = await _localDataSource.deleteMultipleAudioFiles(
      trackIds.map((id) => id.value).toList(),
    );
    return result.fold(
      (failure) => Left(failure),
      (deletedIds) => Right(
        deletedIds.map((id) => AudioTrackId.fromUniqueString(id)).toList(),
      ),
    );
  }

  @override
  Future<Either<CacheFailure, Map<AudioTrackId, bool>>>
  checkMultipleAudioExists(List<AudioTrackId> trackIds) async {
    try {
      final Map<AudioTrackId, bool> existsMap = {};

      for (final trackId in trackIds) {
        final result = await _localDataSource.audioExists(trackId.value);
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
  Stream<int> watchStorageUsage() {
    return _localDataSource.watchStorageUsage();
  }

  @override
  Future<Either<CacheFailure, int>> getStorageUsage() async {
    try {
      final audiosResult = await _localDataSource.getAllCachedAudios();
      return audiosResult.fold((failure) => Left(failure), (audios) {
        final totalSize = audios.fold<int>(
          0,
          (sum, audio) => sum + audio.fileSizeBytes,
        );
        return Right(totalSize);
      });
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

  String? _extractExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    // basic sanity to avoid query strings or very long suffixes
    if (ext.length > 5) return null;
    return ext;
  }
}

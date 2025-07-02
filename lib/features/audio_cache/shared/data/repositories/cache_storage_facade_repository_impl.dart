import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/entities/cache_validation_result.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_storage_facade_repository.dart';
import '../../domain/repositories/audio_download_repository.dart';
import '../../domain/repositories/audio_storage_repository.dart';
import '../../domain/repositories/cache_key_repository.dart';
import '../../domain/repositories/cache_maintenance_repository.dart';
import '../../domain/value_objects/cache_key.dart';

@LazySingleton(as: CacheStorageFacadeRepository)
class CacheStorageFacadeRepositoryImpl implements CacheStorageFacadeRepository {
  final AudioDownloadRepository _downloadRepository;
  final AudioStorageRepository _storageRepository;
  final CacheKeyRepository _keyRepository;
  final CacheMaintenanceRepository _maintenanceRepository;

  CacheStorageFacadeRepositoryImpl(
    this._downloadRepository,
    this._storageRepository,
    this._keyRepository,
    this._maintenanceRepository,
  );

  // ===============================================
  // ACCESS TO SPECIALIZED REPOSITORIES
  // ===============================================

  @override
  AudioDownloadRepository get downloadRepository => _downloadRepository;

  @override
  AudioStorageRepository get storageRepository => _storageRepository;

  @override
  CacheKeyRepository get keyRepository => _keyRepository;

  @override
  CacheMaintenanceRepository get maintenanceRepository => _maintenanceRepository;

  // ===============================================
  // COMPOSITE OPERATIONS (combines specialized repositories)
  // ===============================================

  @override
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  }) async {
    try {
      // Step 1: Download the audio file
      final downloadResult = await _downloadRepository.downloadAudio(
        trackId,
        audioUrl,
        progressCallback: progressCallback,
      );

      return await downloadResult.fold(
        (failure) => Left(failure),
        (tempFilePath) async {
          // Step 2: Store the downloaded file
          final tempFile = File(tempFilePath);
          final storeResult = await _storageRepository.storeAudio(trackId, tempFile);

          return storeResult.fold(
            (failure) {
              // Clean up temp file on storage failure
              try {
                tempFile.deleteSync();
              } catch (e) {
                // Ignore cleanup errors
              }
              return Left(failure);
            },
            (cachedAudio) {
              // Clean up temp file after successful storage
              try {
                tempFile.deleteSync();
              } catch (e) {
                // Ignore cleanup errors
              }
              return Right(cachedAudio);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        DownloadCacheFailure(
          message: 'Failed to download and store audio: $e',
          trackId: trackId,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CachedAudio>>> downloadAndStoreMultipleAudios(
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
          message: 'Failed to download and store multiple audios: $e',
          trackId: 'multiple',
        ),
      );
    }
  }

  // ===============================================
  // DELEGATED METHODS (for backward compatibility)
  // ===============================================

  // Download operations (delegates to AudioDownloadRepository)
  @override
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId) {
    return _downloadRepository.cancelDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId) {
    return _downloadRepository.pauseDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId) {
    return _downloadRepository.resumeDownload(trackId);
  }

  @override
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(String trackId) {
    return _downloadRepository.getDownloadProgress(trackId);
  }

  @override
  Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads() {
    return _downloadRepository.getActiveDownloads();
  }

  @override
  Stream<DownloadProgress> watchDownloadProgress(String trackId) {
    return _downloadRepository.watchDownloadProgress(trackId);
  }

  @override
  Stream<List<DownloadProgress>> watchActiveDownloads() {
    return _downloadRepository.watchActiveDownloads();
  }

  // Storage operations (delegates to AudioStorageRepository)
  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId) {
    return _storageRepository.getCachedAudioPath(trackId);
  }

  @override
  Future<Either<CacheFailure, bool>> audioExists(String trackId) {
    return _storageRepository.audioExists(trackId);
  }

  @override
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId) {
    return _storageRepository.getCachedAudio(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId) {
    return _storageRepository.deleteAudioFile(trackId);
  }

  @override
  Future<Either<CacheFailure, Map<String, CachedAudio>>> getMultipleCachedAudios(
    List<String> trackIds,
  ) {
    return _storageRepository.getMultipleCachedAudios(trackIds);
  }

  @override
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(
    List<String> trackIds,
  ) {
    return _storageRepository.deleteMultipleAudioFiles(trackIds);
  }

  @override
  Future<Either<CacheFailure, Map<String, bool>>> checkMultipleAudioExists(
    List<String> trackIds,
  ) {
    return _storageRepository.checkMultipleAudioExists(trackIds);
  }

  @override
  Stream<int> watchStorageUsage() {
    return _storageRepository.watchStorageUsage();
  }

  // Cache key operations (delegates to CacheKeyRepository)
  @override
  CacheKey generateCacheKey(String trackId, String audioUrl) {
    return _keyRepository.generateCacheKey(trackId, audioUrl);
  }

  @override
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key) {
    return _keyRepository.getFilePathFromCacheKey(key);
  }

  @override
  bool isValidCacheKey(CacheKey key) {
    return _keyRepository.isValidCacheKey(key);
  }

  // Maintenance operations (delegates to CacheMaintenanceRepository)
  @override
  Future<Either<CacheFailure, int>> migrateCacheStructure() {
    return _maintenanceRepository.migrateCacheStructure();
  }

  @override
  Future<Either<CacheFailure, int>> rebuildCacheIndex() {
    return _maintenanceRepository.rebuildCacheIndex();
  }

  @override
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheConsistency() {
    return _maintenanceRepository.validateCacheConsistency();
  }
}
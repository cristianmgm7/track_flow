import 'package:dartz/dartz.dart';
import '../entities/cached_audio.dart';
import '../entities/download_progress.dart';
import '../entities/cache_validation_result.dart';
import '../failures/cache_failure.dart';
import '../value_objects/cache_key.dart';
import 'audio_download_repository.dart';
import 'audio_storage_repository.dart';
import 'cache_key_repository.dart';
import 'cache_maintenance_repository.dart';

/// Facade repository that combines specialized cache repositories
/// Maintains backward compatibility while providing access to specialized repositories
/// DEPRECATED: Use specialized repositories directly for new code
@Deprecated('Use specialized repositories directly (AudioDownloadRepository, AudioStorageRepository, etc.)')
abstract class CacheStorageFacadeRepository {
  // ===============================================
  // ACCESS TO SPECIALIZED REPOSITORIES
  // ===============================================

  /// Access to download operations
  AudioDownloadRepository get downloadRepository;

  /// Access to storage operations
  AudioStorageRepository get storageRepository;

  /// Access to cache key operations
  CacheKeyRepository get keyRepository;

  /// Access to maintenance operations
  CacheMaintenanceRepository get maintenanceRepository;

  // ===============================================
  // COMPOSITE OPERATIONS (uses specialized repositories internally)
  // ===============================================

  /// Download and store audio file (combines download + storage)
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId,
    String audioUrl, {
    void Function(DownloadProgress)? progressCallback,
  });

  /// Download multiple audios and store them (combines download + storage)
  Future<Either<CacheFailure, List<CachedAudio>>> downloadAndStoreMultipleAudios(
    Map<String, String> trackUrlPairs, {
    void Function(String trackId, DownloadProgress)? progressCallback,
  });

  // ===============================================
  // DELEGATED METHODS (for backward compatibility)
  // ===============================================

  // Download operations (delegates to AudioDownloadRepository)
  Future<Either<CacheFailure, Unit>> cancelDownload(String trackId);
  Future<Either<CacheFailure, Unit>> pauseDownload(String trackId);
  Future<Either<CacheFailure, Unit>> resumeDownload(String trackId);
  Future<Either<CacheFailure, DownloadProgress?>> getDownloadProgress(String trackId);
  Future<Either<CacheFailure, List<DownloadProgress>>> getActiveDownloads();
  Stream<DownloadProgress> watchDownloadProgress(String trackId);
  Stream<List<DownloadProgress>> watchActiveDownloads();

  // Storage operations (delegates to AudioStorageRepository)
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId);
  Future<Either<CacheFailure, bool>> audioExists(String trackId);
  Future<Either<CacheFailure, CachedAudio?>> getCachedAudio(String trackId);
  Future<Either<CacheFailure, Unit>> deleteAudioFile(String trackId);
  Future<Either<CacheFailure, Map<String, CachedAudio>>> getMultipleCachedAudios(List<String> trackIds);
  Future<Either<CacheFailure, List<String>>> deleteMultipleAudioFiles(List<String> trackIds);
  Future<Either<CacheFailure, Map<String, bool>>> checkMultipleAudioExists(List<String> trackIds);
  Stream<int> watchStorageUsage();

  // Cache key operations (delegates to CacheKeyRepository)
  CacheKey generateCacheKey(String trackId, String audioUrl);
  Future<Either<CacheFailure, String>> getFilePathFromCacheKey(CacheKey key);
  bool isValidCacheKey(CacheKey key);

  // Maintenance operations (delegates to CacheMaintenanceRepository)
  Future<Either<CacheFailure, int>> migrateCacheStructure();
  Future<Either<CacheFailure, int>> rebuildCacheIndex();
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheConsistency();
}
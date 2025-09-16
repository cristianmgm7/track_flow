import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../audio_cache/domain/entities/cached_audio.dart';
import '../../../audio_cache/domain/entities/cleanup_details.dart';
import '../../../audio_cache/domain/entities/cache_validation_result.dart';
import '../../../audio_cache/domain/failures/cache_failure.dart';

abstract class CacheMaintenanceService {
  /// Reactive: watch all cached audios from the local index (Isar)
  Stream<List<CachedAudio>> watchCachedAudios();
  Future<Either<CacheFailure, CleanupDetails>> performCleanup({
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool removeTemporary = true,
    int? targetFreeBytes,
  });

  Future<Either<CacheFailure, int>> removeCorruptedFiles();
  Future<Either<CacheFailure, int>> removeOrphanedFiles();
  Future<Either<CacheFailure, int>> cleanupTemporaryFiles();
  Future<Either<CacheFailure, int>> freeUpSpace(int targetFreeBytes);
  Future<Either<CacheFailure, CacheValidationResult>> validateCacheIntegrity();
  Future<Either<CacheFailure, int>> getCacheDirectorySize();
  Future<Either<CacheFailure, List<String>>> getCorruptedFiles();
  Future<Either<CacheFailure, List<String>>> getOrphanedFiles();
  Future<Either<CacheFailure, int>> getTotalStorageUsage();
  Future<Either<CacheFailure, int>> getAvailableStorageSpace();
  Future<Either<CacheFailure, List<CachedAudio>>> getAllCachedAudios();
  Future<Either<CacheFailure, bool>> validateFileIntegrity(
    String trackId,
    String expectedChecksum,
  );
  Future<Either<CacheFailure, String>> calculateFileChecksum(String filePath);
  Future<Either<CacheFailure, Directory>> getCacheDirectory();
}

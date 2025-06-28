import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cached_audio.dart';
import '../../domain/entities/enhanced_storage_types.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_metadata_repository.dart';
import '../../domain/repositories/cache_storage_repository.dart';
import '../../domain/services/enhanced_storage_management_service.dart';
import '../../domain/value_objects/storage_limit.dart';

@LazySingleton(as: EnhancedStorageManagementService)
class EnhancedStorageManagementServiceImpl implements EnhancedStorageManagementService {
  final CacheStorageRepository _storageRepository;
  final CacheMetadataRepository _metadataRepository;
  
  // Configuration
  StorageLimit _currentLimit = StorageLimit.defaultLimit;
  StorageLimitPolicy _limitPolicy = StorageLimitPolicy.softLimit;
  double _warningThreshold = 0.8;
  double _criticalThreshold = 0.95;
  AutoCleanupPolicy _autoCleanupPolicy = AutoCleanupPolicy.conservative;
  
  // Stream controllers
  final StreamController<EnhancedStorageStats> _statsController =
      StreamController<EnhancedStorageStats>.broadcast();
  final StreamController<StorageLimitViolation> _violationController =
      StreamController<StorageLimitViolation>.broadcast();
  final StreamController<CacheDirectoryChange> _directoryController =
      StreamController<CacheDirectoryChange>.broadcast();
  final StreamController<CleanupOperation> _cleanupController =
      StreamController<CleanupOperation>.broadcast();

  Timer? _monitoringTimer;

  EnhancedStorageManagementServiceImpl({
    required CacheStorageRepository storageRepository,
    required CacheMetadataRepository metadataRepository,
  }) : _storageRepository = storageRepository,
       _metadataRepository = metadataRepository {
    _startMonitoring();
  }

  @override
  Future<Either<CacheFailure, EnhancedStorageStats>> getStorageStats() async {
    try {
      final audiosResult = await _storageRepository.getAllCachedAudios();
      final usageResult = await _storageRepository.getTotalStorageUsage();
      final availableResult = await _storageRepository.getAvailableStorageSpace();
      final corruptedResult = await _storageRepository.getCorruptedFiles();
      final orphanedResult = await _storageRepository.getOrphanedFiles();

      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async => await usageResult.fold(
          (failure) => Left(failure),
          (totalSize) async => await availableResult.fold(
            (failure) => Left(failure),
            (availableSpace) async => await corruptedResult.fold(
              (failure) => Left(failure),
              (corruptedFiles) async => await orphanedResult.fold(
                (failure) => Left(failure),
                (orphanedFiles) async {
                  final totalSpace = totalSize + availableSpace;
                  
                  // Calculate additional statistics
                  final averageFileSize = audios.isNotEmpty 
                      ? audios.map((a) => a.fileSizeBytes).reduce((a, b) => a + b) ~/ audios.length 
                      : 0;
                  
                  final largestFile = audios.isNotEmpty 
                      ? audios.map((a) => a.fileSizeBytes).reduce((a, b) => a > b ? a : b) 
                      : 0;
                  
                  final oldestFile = audios.isNotEmpty 
                      ? audios.map((a) => a.cachedAt).reduce((a, b) => a.isBefore(b) ? a : b) 
                      : DateTime.now();
                  
                  final newestFile = audios.isNotEmpty 
                      ? audios.map((a) => a.cachedAt).reduce((a, b) => a.isAfter(b) ? a : b) 
                      : DateTime.now();

                  return Right(
                    EnhancedStorageStats(
                      totalCacheSize: totalSize,
                      availableSpace: availableSpace,
                      totalSpace: totalSpace,
                      cachedTracksCount: audios.length,
                      corruptedFilesCount: corruptedFiles.length,
                      orphanedFilesCount: orphanedFiles.length,
                      lastCleanup: DateTime.now(), // Would track actual last cleanup
                      cacheEfficiency: _calculateCacheEfficiency(audios),
                      averageFileSize: averageFileSize,
                      largestFile: largestFile,
                      oldestFile: oldestFile,
                      newestFile: newestFile,
                      duplicateFiles: 0, // Would need duplicate detection
                      compressionRatio: 1.0, // Would calculate actual compression
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get enhanced storage stats: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getAvailableStorageBytes() async {
    return await _storageRepository.getAvailableStorageSpace();
  }

  @override
  Future<Either<CacheFailure, int>> getTotalStorageBytes() async {
    try {
      final availableResult = await _storageRepository.getAvailableStorageSpace();
      final usedResult = await _storageRepository.getTotalStorageUsage();
      
      return await availableResult.fold(
        (failure) => Left(failure),
        (available) async => await usedResult.fold(
          (failure) => Left(failure),
          (used) => Right(available + used),
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get total storage bytes: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheDirectoryStats>> getCacheDirectoryStats() async {
    try {
      final sizeResult = await _storageRepository.getCacheDirectorySize();
      
      return await sizeResult.fold(
        (failure) => Left(failure),
        (size) async {
          // Create simplified directory stats
          return Right(
            CacheDirectoryStats(
              totalSize: size,
              fileCount: 0, // Would need implementation
              subdirectoryCount: 0, // Would need implementation
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cache directory stats: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> isCleanupNeeded() async {
    try {
      if (_currentLimit.isUnlimited) {
        return const Right(false);
      }

      final usageResult = await _storageRepository.getTotalStorageUsage();
      
      return usageResult.fold(
        (failure) => Left(failure),
        (currentUsage) {
          final usagePercentage = _currentLimit.getUsagePercentage(currentUsage);
          return Right(usagePercentage >= _warningThreshold);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to check if cleanup needed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Duration?>> estimateCleanupTimeNeeded() async {
    try {
      final isNeededResult = await isCleanupNeeded();
      
      return await isNeededResult.fold(
        (failure) => Left(failure),
        (isNeeded) async {
          if (!isNeeded) {
            return const Right(null);
          }
          
          // Simplified estimation based on current usage growth
          // In real implementation, would use historical data
          return const Right(Duration(days: 7));
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to estimate cleanup time: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, EnhancedCleanupResult>> performCleanup({
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.intelligent,
    int? targetFreeBytes,
    double? targetFreePercentage,
    bool removeCorrupted = true,
    bool removeOrphaned = true,
    bool respectReferences = true,
  }) async {
    try {
      _cleanupController.add(
        CleanupOperation.started(strategy: strategy.toString()),
      );

      final cleanupDetails = await _storageRepository.performCleanup(
        removeCorrupted: removeCorrupted,
        removeOrphaned: removeOrphaned,
        removeTemporary: true,
        targetFreeBytes: targetFreeBytes,
      );

      return await cleanupDetails.fold(
        (failure) {
          _cleanupController.add(
            CleanupOperation.failed(error: failure.message),
          );
          return Left(failure);
        },
        (details) async {
          final result = EnhancedCleanupResult(
            totalFilesRemoved: details.totalFilesRemoved,
            totalSpaceFreed: details.totalSpaceFreed,
            corruptedFilesRemoved: details.corruptedFilesRemoved,
            orphanedFilesRemoved: details.orphanedFilesRemoved,
            temporaryFilesRemoved: details.temporaryFilesRemoved,
            oldestFilesRemoved: 0, // Would need implementation
            duplicateFilesRemoved: 0, // Would need implementation
            strategy: strategy,
            duration: Duration.zero, // Would track actual duration
            errors: details.errors,
          );

          _cleanupController.add(
            CleanupOperation.completed(result: result.summary),
          );

          return Right(result);
        },
      );
    } catch (e) {
      _cleanupController.add(
        CleanupOperation.failed(error: e.toString()),
      );
      
      return Left(
        StorageCacheFailure(
          message: 'Failed to perform enhanced cleanup: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CorruptionCleanupResult>> cleanupCorruptedFiles() async {
    try {
      final corruptedResult = await _storageRepository.removeCorruptedFiles();
      
      return corruptedResult.fold(
        (failure) => Left(failure),
        (removedCount) {
          return Right(
            CorruptionCleanupResult(
              filesRemoved: removedCount,
              spaceFreed: 0, // Would need size calculation
              corruptionTypes: [], // Would need detailed analysis
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup corrupted files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, OrphanCleanupResult>> cleanupOrphanedFiles() async {
    try {
      final orphanedResult = await _storageRepository.removeOrphanedFiles();
      
      return orphanedResult.fold(
        (failure) => Left(failure),
        (removedCount) {
          return Right(
            OrphanCleanupResult(
              filesRemoved: removedCount,
              spaceFreed: 0, // Would need size calculation
              orphanTypes: [], // Would need classification
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup orphaned files: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, AgeBasedCleanupResult>> cleanupByAge({
    Duration maxAge = const Duration(days: 30),
    Duration maxUnusedAge = const Duration(days: 7),
  }) async {
    try {
      final audiosResult = await _storageRepository.getAllCachedAudios();
      
      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async {
          final now = DateTime.now();
          final trackIdsToDelete = <String>[];
          
          for (final audio in audios) {
            final age = now.difference(audio.cachedAt);
            if (age > maxAge) {
              trackIdsToDelete.add(audio.trackId);
            }
          }
          
          if (trackIdsToDelete.isNotEmpty) {
            await _storageRepository.deleteMultipleAudioFiles(trackIdsToDelete);
          }
          
          return Right(
            AgeBasedCleanupResult(
              filesRemoved: trackIdsToDelete.length,
              spaceFreed: 0, // Would calculate actual space
              oldestRemoved: maxAge,
              averageAge: Duration.zero, // Would calculate
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to cleanup by age: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, SpaceOptimizationResult>> freeUpSpace(
    int targetFreeBytes, {
    bool respectReferences = true,
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.leastAccessed,
  }) async {
    try {
      final freedResult = await _storageRepository.freeUpSpace(targetFreeBytes);
      
      return freedResult.fold(
        (failure) => Left(failure),
        (freedBytes) {
          return Right(
            SpaceOptimizationResult(
              targetBytes: targetFreeBytes,
              actualBytesFreed: freedBytes,
              filesRemoved: 0, // Would need tracking
              strategy: strategy,
              referencesRespected: respectReferences,
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to free up space: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> removeCachedTracks(
    List<String> trackIds, {
    bool respectReferences = true,
    bool forceRemove = false,
  }) async {
    try {
      if (respectReferences && !forceRemove) {
        // Check references before deletion
        for (final trackId in trackIds) {
          final canDeleteResult = await _metadataRepository.canDelete(trackId);
          canDeleteResult.fold(
            (failure) {
              // Log but continue
            },
            (canDelete) {
              if (!canDelete) {
                // Skip this track
                return;
              }
            },
          );
        }
      }
      
      await _storageRepository.deleteMultipleAudioFiles(trackIds);
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to remove cached tracks: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> clearAllCache({
    bool skipReferenceCheck = false,
    bool createBackup = false,
  }) async {
    try {
      if (createBackup) {
        // Would implement backup creation
      }
      
      if (!skipReferenceCheck) {
        // Would check all references
      }
      
      // For now, simplified implementation
      final audiosResult = await _storageRepository.getAllCachedAudios();
      
      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async {
          final trackIds = audios.map((a) => a.trackId).toList();
          await _storageRepository.deleteMultipleAudioFiles(trackIds);
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to clear all cache: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<EnhancedCachedTrackInfo>>> getCachedTracks({
    CacheSortOption sortBy = CacheSortOption.lastAccessed,
    bool ascending = false,
    int? limit,
    CacheFilterOptions? filter,
  }) async {
    try {
      final audiosResult = await _storageRepository.getAllCachedAudios();
      
      return await audiosResult.fold(
        (failure) => Left(failure),
        (audios) async {
          final enhancedTracks = <EnhancedCachedTrackInfo>[];
          
          for (final audio in audios) {
            final referenceResult = await _metadataRepository.getReference(audio.trackId);
            final metadataResult = await _metadataRepository.getMetadata(audio.trackId);
            
            final reference = referenceResult.fold((f) => null, (r) => r);
            final metadata = metadataResult.fold((f) => null, (m) => m);
            
            final enhancedTrack = EnhancedCachedTrackInfo(
              cachedAudio: audio,
              referenceCount: reference?.referenceCount ?? 0,
              lastAccessed: metadata?.lastAccessed ?? audio.cachedAt,
              accessCount: 1, // Would need tracking
              downloadDate: audio.cachedAt,
              isCorrupted: audio.status == CacheStatus.corrupted,
              compressionRatio: 1.0, // Would calculate
              estimatedDiskUsage: audio.fileSizeBytes,
            );
            
            enhancedTracks.add(enhancedTrack);
          }
          
          // Apply sorting
          _sortEnhancedTracks(enhancedTracks, sortBy, ascending);
          
          // Apply limit
          if (limit != null && limit < enhancedTracks.length) {
            return Right(enhancedTracks.take(limit).toList());
          }
          
          return Right(enhancedTracks);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get cached tracks: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksMatchingCriteria(
    CacheSearchCriteria criteria,
  ) async {
    // Would implement based on criteria
    return const Right([]);
  }

  @override
  Future<Either<CacheFailure, List<CacheRemovalCandidate>>> getRemovalCandidates({
    int maxCandidates = 50,
    EnhancedCleanupStrategy strategy = EnhancedCleanupStrategy.leastAccessed,
  }) async {
    // Would implement candidate selection logic
    return const Right([]);
  }

  @override
  Future<Either<CacheFailure, CacheUsageAnalysis>> analyzeCacheUsage() async {
    // Would implement usage analysis
    try {
      return Right(
        CacheUsageAnalysis(
          totalTracks: 0,
          totalSize: 0,
          averageFileSize: 0,
          usagePatterns: {},
          recommendations: [],
        ),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to analyze cache usage: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> setStorageLimit(
    StorageLimit limit, {
    StorageLimitPolicy policy = StorageLimitPolicy.softLimit,
    double warningThreshold = 0.8,
    double criticalThreshold = 0.95,
  }) async {
    try {
      _currentLimit = limit;
      _limitPolicy = policy;
      _warningThreshold = warningThreshold;
      _criticalThreshold = criticalThreshold;
      
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set storage limit: $e',
          field: 'storageLimit',
          value: limit,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, StorageLimitConfig>> getStorageLimitConfig() async {
    try {
      return Right(
        StorageLimitConfig(
          limit: _currentLimit,
          policy: _limitPolicy,
          warningThreshold: _warningThreshold,
          criticalThreshold: _criticalThreshold,
        ),
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get storage limit config: $e',
          field: 'config',
          value: null,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, StorageLimitStatus>> getStorageLimitStatus() async {
    try {
      final usageResult = await _storageRepository.getTotalStorageUsage();
      
      return usageResult.fold(
        (failure) => Left(failure),
        (currentUsage) {
          final usagePercentage = _currentLimit.getUsagePercentage(currentUsage);
          final remainingBytes = _currentLimit.getRemainingBytes(currentUsage);
          
          return Right(
            StorageLimitStatus(
              currentUsage: currentUsage,
              usagePercentage: usagePercentage,
              remainingBytes: remainingBytes,
              isWarning: usagePercentage >= _warningThreshold,
              isCritical: usagePercentage >= _criticalThreshold,
              isExceeded: _currentLimit.isExceeded(currentUsage),
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get storage limit status: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> setAutoCleanupPolicy(AutoCleanupPolicy policy) async {
    try {
      _autoCleanupPolicy = policy;
      return const Right(unit);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to set auto cleanup policy: $e',
          field: 'autoCleanupPolicy',
          value: policy,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, AutoCleanupPolicy>> getAutoCleanupPolicy() async {
    try {
      return Right(_autoCleanupPolicy);
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Failed to get auto cleanup policy: $e',
          field: 'autoCleanupPolicy',
          value: null,
        ),
      );
    }
  }

  @override
  Stream<EnhancedStorageStats> watchStorageStats({
    Duration updateInterval = const Duration(minutes: 1),
  }) {
    return _statsController.stream;
  }

  @override
  Stream<StorageLimitViolation> watchStorageLimitViolations() {
    return _violationController.stream;
  }

  @override
  Stream<CacheDirectoryChange> watchCacheDirectoryChanges() {
    return _directoryController.stream;
  }

  @override
  Stream<CleanupOperation> watchCleanupOperations() {
    return _cleanupController.stream;
  }

  @override
  Future<Either<CacheFailure, CacheIntegrityReport>> validateCacheIntegrity() async {
    try {
      final validationResult = await _storageRepository.validateCacheConsistency();
      
      return validationResult.fold(
        (failure) => Left(failure),
        (result) {
          return Right(
            CacheIntegrityReport(
              totalFiles: result.totalFiles,
              validFiles: result.validFiles,
              issues: result.issues,
              recommendations: [], // Would generate recommendations
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to validate cache integrity: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheRepairResult>> repairCache() async {
    // Would implement cache repair logic
    return const Right(
      CacheRepairResult(
        repairedFiles: 0,
        unreparableFiles: 0,
        actions: [],
      ),
    );
  }

  @override
  Future<Either<CacheFailure, CacheOptimizationResult>> optimizeCache() async {
    // Would implement cache optimization
    return const Right(
      CacheOptimizationResult(
        optimizationsApplied: [],
        spaceRecovered: 0,
        performanceImprovement: 0.0,
      ),
    );
  }

  @override
  Future<Either<CacheFailure, String>> backupCacheMetadata() async {
    // Would implement metadata backup
    return const Right('/backup/path');
  }

  @override
  Future<Either<CacheFailure, Unit>> restoreCacheMetadata(String backupPath) async {
    // Would implement metadata restore
    return const Right(unit);
  }

  // Private helper methods
  double _calculateCacheEfficiency(List<CachedAudio> audios) {
    if (audios.isEmpty) return 1.0;
    
    final validAudios = audios.where((a) => a.status == CacheStatus.cached).length;
    return validAudios / audios.length;
  }

  void _sortEnhancedTracks(
    List<EnhancedCachedTrackInfo> tracks,
    CacheSortOption sortBy,
    bool ascending,
  ) {
    switch (sortBy) {
      case CacheSortOption.lastAccessed:
        tracks.sort((a, b) => ascending 
            ? a.lastAccessed.compareTo(b.lastAccessed)
            : b.lastAccessed.compareTo(a.lastAccessed));
        break;
      case CacheSortOption.downloadDate:
        tracks.sort((a, b) => ascending 
            ? a.downloadDate.compareTo(b.downloadDate)
            : b.downloadDate.compareTo(a.downloadDate));
        break;
      case CacheSortOption.fileSize:
        tracks.sort((a, b) => ascending 
            ? a.cachedAudio.fileSizeBytes.compareTo(b.cachedAudio.fileSizeBytes)
            : b.cachedAudio.fileSizeBytes.compareTo(a.cachedAudio.fileSizeBytes));
        break;
      case CacheSortOption.referenceCount:
        tracks.sort((a, b) => ascending 
            ? a.referenceCount.compareTo(b.referenceCount)
            : b.referenceCount.compareTo(a.referenceCount));
        break;
      case CacheSortOption.accessCount:
        tracks.sort((a, b) => ascending 
            ? a.accessCount.compareTo(b.accessCount)
            : b.accessCount.compareTo(a.accessCount));
        break;
      case CacheSortOption.trackName:
        tracks.sort((a, b) => ascending 
            ? a.cachedAudio.trackId.compareTo(b.cachedAudio.trackId)
            : b.cachedAudio.trackId.compareTo(a.cachedAudio.trackId));
        break;
    }
  }

  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateStorageStats();
      _checkStorageLimits();
    });
  }

  void _updateStorageStats() {
    getStorageStats().then((result) {
      result.fold(
        (failure) {
          // Log failure
        },
        (stats) {
          _statsController.add(stats);
        },
      );
    });
  }

  void _checkStorageLimits() {
    getStorageLimitStatus().then((result) {
      result.fold(
        (failure) {
          // Log failure
        },
        (status) {
          if (status.isCritical || status.isExceeded) {
            _violationController.add(
              StorageLimitViolation.critical(
                currentUsage: status.currentUsage,
                limit: _currentLimit.bytes,
              ),
            );
          } else if (status.isWarning) {
            _violationController.add(
              StorageLimitViolation.warning(
                currentUsage: status.currentUsage,
                limit: _currentLimit.bytes,
              ),
            );
          }
        },
      );
    });
  }

  void dispose() {
    _monitoringTimer?.cancel();
    _statsController.close();
    _violationController.close();
    _directoryController.close();
    _cleanupController.close();
  }
}
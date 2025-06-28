import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cache_metadata.dart';
import '../../domain/entities/cache_reference.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../../domain/repositories/cache_metadata_repository.dart';
import '../datasources/cache_metadata_local_data_source.dart';

@LazySingleton(as: CacheMetadataRepository)
class CacheMetadataRepositoryImpl implements CacheMetadataRepository {
  final CacheMetadataLocalDataSource _localDataSource;

  CacheMetadataRepositoryImpl({
    required CacheMetadataLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<CacheFailure, CacheReference>> addReference(
    String trackId,
    String referenceId,
  ) async {
    return await _localDataSource.addReference(trackId, referenceId);
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> removeReference(
    String trackId,
    String referenceId,
  ) async {
    return await _localDataSource.removeReference(trackId, referenceId);
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> getReference(String trackId) async {
    return await _localDataSource.getReference(trackId);
  }

  @override
  Future<Either<CacheFailure, Map<String, CacheReference>>> getMultipleReferences(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, CacheReference> references = {};
      
      for (final trackId in trackIds) {
        final result = await _localDataSource.getReference(trackId);
        result.fold(
          (failure) {
            // Log failure but continue with other tracks
          },
          (reference) {
            if (reference != null) {
              references[trackId] = reference;
            }
          },
        );
      }
      
      return Right(references);
    } catch (e) {
      return Left(
        ReferenceCacheFailure(
          message: 'Failed to get multiple references: $e',
          trackId: '',
          referenceId: '',
          operation: 'getMultipleReferences',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> canDelete(String trackId) async {
    return await _localDataSource.canDelete(trackId);
  }

  @override
  Future<Either<CacheFailure, List<String>>> getDeletableTrackIds() async {
    return await _localDataSource.getDeletableTrackIds();
  }

  @override
  Future<Either<CacheFailure, Unit>> saveMetadata(CacheMetadata metadata) async {
    return await _localDataSource.saveMetadata(metadata);
  }

  @override
  Future<Either<CacheFailure, CacheMetadata?>> getMetadata(String trackId) async {
    return await _localDataSource.getMetadata(trackId);
  }

  @override
  Future<Either<CacheFailure, Map<String, CacheMetadata>>> getMultipleMetadata(
    List<String> trackIds,
  ) async {
    try {
      final Map<String, CacheMetadata> metadataMap = {};
      
      for (final trackId in trackIds) {
        final result = await _localDataSource.getMetadata(trackId);
        result.fold(
          (failure) {
            // Log failure but continue with other tracks
          },
          (metadata) {
            if (metadata != null) {
              metadataMap[trackId] = metadata;
            }
          },
        );
      }
      
      return Right(metadataMap);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get multiple metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> updateLastAccessed(String trackId) async {
    return await _localDataSource.updateLastAccessed(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> incrementDownloadAttempts(
    String trackId,
    String? failureReason,
  ) async {
    try {
      final metadataResult = await _localDataSource.getMetadata(trackId);
      
      return await metadataResult.fold(
        (failure) => Left(failure),
        (metadata) async {
          if (metadata != null) {
            final updatedMetadata = metadata.incrementDownloadAttempts(
              failureReason: failureReason,
            );
            return await _localDataSource.saveMetadata(updatedMetadata);
          } else {
            return Left(
              ValidationCacheFailure(
                message: 'Cannot increment download attempts: metadata not found',
                field: 'trackId',
                value: trackId,
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to increment download attempts: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsDownloading(String trackId) async {
    return await _localDataSource.markAsDownloading(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsCompleted(String trackId) async {
    return await _localDataSource.markAsCompleted(trackId);
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsCorrupted(String trackId) async {
    return await _localDataSource.markAsCorrupted(trackId);
  }

  @override
  Future<Either<CacheFailure, List<String>>> getAllCachedTrackIds() async {
    return await _localDataSource.getAllCachedTrackIds();
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksByStatus(CacheStatus status) async {
    return await _localDataSource.getTracksByStatus(status);
  }

  @override
  Future<Either<CacheFailure, List<String>>> getRetryableTrackIds() async {
    try {
      final failedTracksResult = await _localDataSource.getTracksByStatus(CacheStatus.failed);
      
      return await failedTracksResult.fold(
        (failure) => Left(failure),
        (failedTrackIds) async {
          final retryableTrackIds = <String>[];
          
          for (final trackId in failedTrackIds) {
            final metadataResult = await _localDataSource.getMetadata(trackId);
            metadataResult.fold(
              (failure) {
                // Skip this track
              },
              (metadata) {
                if (metadata?.shouldRetry == true) {
                  retryableTrackIds.add(trackId);
                }
              },
            );
          }
          
          return Right(retryableTrackIds);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get retryable track IDs: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getCorruptedTrackIds() async {
    return await _localDataSource.getTracksByStatus(CacheStatus.corrupted);
  }

  @override
  Future<Either<CacheFailure, List<String>>> getOrphanedTrackIds() async {
    return await _localDataSource.getDeletableTrackIds();
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksByReference(String referenceId) async {
    return await _localDataSource.getTracksByReference(referenceId);
  }

  @override
  Future<Either<CacheFailure, int>> getTotalTracksCount() async {
    try {
      final tracksResult = await _localDataSource.getAllCachedTrackIds();
      return tracksResult.fold(
        (failure) => Left(failure),
        (trackIds) => Right(trackIds.length),
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get total tracks count: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, int>> getTotalReferencesCount() async {
    try {
      final tracksResult = await _localDataSource.getAllCachedTrackIds();
      
      return await tracksResult.fold(
        (failure) => Left(failure),
        (trackIds) async {
          int totalReferences = 0;
          
          for (final trackId in trackIds) {
            final referenceResult = await _localDataSource.getReference(trackId);
            referenceResult.fold(
              (failure) {
                // Skip this track
              },
              (reference) {
                if (reference != null) {
                  totalReferences += reference.referenceCount;
                }
              },
            );
          }
          
          return Right(totalReferences);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get total references count: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Map<int, int>>> getReferenceCountDistribution() async {
    try {
      final tracksResult = await _localDataSource.getAllCachedTrackIds();
      
      return await tracksResult.fold(
        (failure) => Left(failure),
        (trackIds) async {
          final Map<int, int> distribution = {};
          
          for (final trackId in trackIds) {
            final referenceResult = await _localDataSource.getReference(trackId);
            referenceResult.fold(
              (failure) {
                // Skip this track
              },
              (reference) {
                if (reference != null) {
                  final count = reference.referenceCount;
                  distribution[count] = (distribution[count] ?? 0) + 1;
                }
              },
            );
          }
          
          return Right(distribution);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get reference count distribution: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CacheReference>>> getMostReferencedTracks({
    int limit = 10,
  }) async {
    try {
      final tracksResult = await _localDataSource.getAllCachedTrackIds();
      
      return await tracksResult.fold(
        (failure) => Left(failure),
        (trackIds) async {
          final List<CacheReference> references = [];
          
          for (final trackId in trackIds) {
            final referenceResult = await _localDataSource.getReference(trackId);
            referenceResult.fold(
              (failure) {
                // Skip this track
              },
              (reference) {
                if (reference != null) {
                  references.add(reference);
                }
              },
            );
          }
          
          // Sort by reference count (descending) and take limit
          references.sort((a, b) => b.referenceCount.compareTo(a.referenceCount));
          final limitedReferences = references.take(limit).toList();
          
          return Right(limitedReferences);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get most referenced tracks: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<CacheReference>>> getRecentlyAccessedTracks({
    int limit = 10,
  }) async {
    try {
      final tracksResult = await _localDataSource.getAllCachedTrackIds();
      
      return await tracksResult.fold(
        (failure) => Left(failure),
        (trackIds) async {
          final List<CacheReference> references = [];
          
          for (final trackId in trackIds) {
            final referenceResult = await _localDataSource.getReference(trackId);
            referenceResult.fold(
              (failure) {
                // Skip this track
              },
              (reference) {
                if (reference != null && reference.lastAccessed != null) {
                  references.add(reference);
                }
              },
            );
          }
          
          // Sort by last accessed (descending) and take limit
          references.sort((a, b) => 
            (b.lastAccessed ?? DateTime(0)).compareTo(a.lastAccessed ?? DateTime(0))
          );
          final limitedReferences = references.take(limit).toList();
          
          return Right(limitedReferences);
        },
      );
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get recently accessed tracks: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> saveMultipleMetadata(
    List<CacheMetadata> metadataList,
  ) async {
    try {
      for (final metadata in metadataList) {
        final result = await _localDataSource.saveMetadata(metadata);
        result.fold(
          (failure) {
            // For now, continue with other metadata
            // In a real implementation, you might want to rollback on failure
          },
          (_) {
            // Success
          },
        );
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to save multiple metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteMultipleMetadata(
    List<String> trackIds,
  ) async {
    try {
      return await _localDataSource.deleteMultipleMetadata(trackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to delete multiple metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> clearAllMetadata() async {
    try {
      return await _localDataSource.clearAllMetadata();
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to clear all metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Stream<CacheReference?> watchReference(String trackId) {
    return _localDataSource.watchReference(trackId);
  }

  @override
  Stream<CacheMetadata?> watchMetadata(String trackId) {
    return _localDataSource.watchMetadata(trackId);
  }

  @override
  Stream<List<CacheReference>> watchAllReferences() {
    return _localDataSource.watchAllReferences();
  }
}
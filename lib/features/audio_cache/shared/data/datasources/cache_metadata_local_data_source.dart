import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../../domain/entities/cache_metadata.dart';
import '../../domain/entities/cache_reference.dart';
import '../../domain/entities/cached_audio.dart';
import '../../domain/failures/cache_failure.dart';
import '../models/cache_metadata_document.dart';
import '../models/cache_reference_document.dart';

abstract class CacheMetadataLocalDataSource {
  // Reference counting operations
  Future<Either<CacheFailure, CacheReference>> addReference(
    String trackId,
    String referenceId,
  );
  
  Future<Either<CacheFailure, CacheReference?>> removeReference(
    String trackId,
    String referenceId,
  );
  
  Future<Either<CacheFailure, CacheReference?>> getReference(String trackId);
  
  Future<Either<CacheFailure, bool>> canDelete(String trackId);
  
  // Metadata operations
  Future<Either<CacheFailure, Unit>> saveMetadata(CacheMetadata metadata);
  
  Future<Either<CacheFailure, CacheMetadata?>> getMetadata(String trackId);
  
  Future<Either<CacheFailure, Unit>> updateLastAccessed(String trackId);
  
  Future<Either<CacheFailure, Unit>> markAsDownloading(String trackId);
  
  Future<Either<CacheFailure, Unit>> markAsCompleted(String trackId);
  
  Future<Either<CacheFailure, Unit>> markAsCorrupted(String trackId);
  
  // Query operations
  Future<Either<CacheFailure, List<String>>> getAllCachedTrackIds();
  
  Future<Either<CacheFailure, List<String>>> getTracksByStatus(CacheStatus status);
  
  Future<Either<CacheFailure, List<String>>> getDeletableTrackIds();
  
  Future<Either<CacheFailure, List<String>>> getTracksByReference(String referenceId);
  
  // Bulk operations
  Future<Either<CacheFailure, Unit>> deleteMultipleMetadata(List<String> trackIds);
  
  Future<Either<CacheFailure, Unit>> clearAllMetadata();
  
  // Reactive streams
  Stream<CacheReference?> watchReference(String trackId);
  
  Stream<CacheMetadata?> watchMetadata(String trackId);
  
  Stream<List<CacheReference>> watchAllReferences();
}

@LazySingleton(as: CacheMetadataLocalDataSource)
class CacheMetadataLocalDataSourceImpl implements CacheMetadataLocalDataSource {
  final Isar _isar;

  CacheMetadataLocalDataSourceImpl(this._isar);

  @override
  Future<Either<CacheFailure, CacheReference>> addReference(
    String trackId,
    String referenceId,
  ) async {
    try {
      late CacheReference reference;
      
      await _isar.writeTxn(() async {
        // Get existing reference or create new one
        final existingDoc = await _isar.cacheReferenceDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();

        if (existingDoc != null) {
          final existingRef = existingDoc.toEntity();
          reference = existingRef.addReference(referenceId);
        } else {
          reference = CacheReference(
            trackId: trackId,
            referenceIds: [referenceId],
            createdAt: DateTime.now(),
            lastAccessed: DateTime.now(),
          );
        }

        final document = CacheReferenceDocument.fromEntity(reference);
        await _isar.cacheReferenceDocuments.put(document);
      });

      return Right(reference);
    } catch (e) {
      return Left(
        ReferenceCacheFailure(
          message: 'Failed to add reference: $e',
          trackId: trackId,
          referenceId: referenceId,
          operation: 'addReference',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> removeReference(
    String trackId,
    String referenceId,
  ) async {
    try {
      CacheReference? updatedReference;

      await _isar.writeTxn(() async {
        final existingDoc = await _isar.cacheReferenceDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();

        if (existingDoc != null) {
          final existingRef = existingDoc.toEntity();
          updatedReference = existingRef.removeReference(referenceId);

          if (updatedReference!.canDelete) {
            // Remove the document if no references remain
            await _isar.cacheReferenceDocuments.delete(existingDoc.isarId);
            updatedReference = null;
          } else {
            // Update with remaining references
            final document = CacheReferenceDocument.fromEntity(updatedReference!);
            await _isar.cacheReferenceDocuments.put(document);
          }
        }
      });

      return Right(updatedReference);
    } catch (e) {
      return Left(
        ReferenceCacheFailure(
          message: 'Failed to remove reference: $e',
          trackId: trackId,
          referenceId: referenceId,
          operation: 'removeReference',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheReference?>> getReference(String trackId) async {
    try {
      final document = await _isar.cacheReferenceDocuments
          .where()
          .trackIdEqualTo(trackId)
          .findFirst();

      return Right(document?.toEntity());
    } catch (e) {
      return Left(
        ReferenceCacheFailure(
          message: 'Failed to get reference: $e',
          trackId: trackId,
          referenceId: '',
          operation: 'getReference',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, bool>> canDelete(String trackId) async {
    try {
      final reference = await getReference(trackId);
      return reference.fold(
        (failure) => Left(failure),
        (ref) => Right(ref?.canDelete ?? true),
      );
    } catch (e) {
      return Left(
        ReferenceCacheFailure(
          message: 'Failed to check if can delete: $e',
          trackId: trackId,
          referenceId: '',
          operation: 'canDelete',
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> saveMetadata(CacheMetadata metadata) async {
    try {
      await _isar.writeTxn(() async {
        final document = CacheMetadataDocument.fromEntity(metadata);
        await _isar.cacheMetadataDocuments.put(document);
      });

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to save metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, CacheMetadata?>> getMetadata(String trackId) async {
    try {
      final document = await _isar.cacheMetadataDocuments
          .where()
          .trackIdEqualTo(trackId)
          .findFirst();

      return Right(document?.toEntity());
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get metadata: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> updateLastAccessed(String trackId) async {
    try {
      await _isar.writeTxn(() async {
        // Update metadata last accessed
        final metadataDoc = await _isar.cacheMetadataDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();

        if (metadataDoc != null) {
          final metadata = metadataDoc.toEntity().updateLastAccessed();
          final updatedDoc = CacheMetadataDocument.fromEntity(metadata);
          await _isar.cacheMetadataDocuments.put(updatedDoc);
        }

        // Update reference last accessed
        final referenceDoc = await _isar.cacheReferenceDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();

        if (referenceDoc != null) {
          final reference = referenceDoc.toEntity().updateLastAccessed();
          final updatedRefDoc = CacheReferenceDocument.fromEntity(reference);
          await _isar.cacheReferenceDocuments.put(updatedRefDoc);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to update last accessed: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsDownloading(String trackId) async {
    return _updateMetadataStatus(trackId, (metadata) => metadata.markAsDownloading());
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsCompleted(String trackId) async {
    return _updateMetadataStatus(trackId, (metadata) => metadata.markAsCompleted());
  }

  @override
  Future<Either<CacheFailure, Unit>> markAsCorrupted(String trackId) async {
    return _updateMetadataStatus(trackId, (metadata) => metadata.markAsCorrupted());
  }

  Future<Either<CacheFailure, Unit>> _updateMetadataStatus(
    String trackId,
    CacheMetadata Function(CacheMetadata) updateFunction,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final document = await _isar.cacheMetadataDocuments
            .where()
            .trackIdEqualTo(trackId)
            .findFirst();

        if (document != null) {
          final metadata = document.toEntity();
          final updatedMetadata = updateFunction(metadata);
          final updatedDocument = CacheMetadataDocument.fromEntity(updatedMetadata);
          await _isar.cacheMetadataDocuments.put(updatedDocument);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to update metadata status: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getAllCachedTrackIds() async {
    try {
      final documents = await _isar.cacheMetadataDocuments.where().findAll();
      final trackIds = documents.map((doc) => doc.trackId).toList();
      return Right(trackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get all cached track IDs: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksByStatus(CacheStatus status) async {
    try {
      final documents = await _isar.cacheMetadataDocuments
          .filter()
          .statusEqualTo(status)
          .findAll();
      
      final trackIds = documents.map((doc) => doc.trackId).toList();
      return Right(trackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get tracks by status: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getDeletableTrackIds() async {
    try {
      final references = await _isar.cacheReferenceDocuments.where().findAll();
      final deletableTrackIds = references
          .where((ref) => ref.toEntity().canDelete)
          .map((ref) => ref.trackId)
          .toList();
      
      return Right(deletableTrackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get deletable track IDs: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, List<String>>> getTracksByReference(String referenceId) async {
    try {
      final references = await _isar.cacheReferenceDocuments.where().findAll();
      final trackIds = references
          .where((ref) => ref.referenceIds.contains(referenceId))
          .map((ref) => ref.trackId)
          .toList();
      
      return Right(trackIds);
    } catch (e) {
      return Left(
        StorageCacheFailure(
          message: 'Failed to get tracks by reference: $e',
          type: StorageFailureType.diskError,
        ),
      );
    }
  }

  @override
  Future<Either<CacheFailure, Unit>> deleteMultipleMetadata(List<String> trackIds) async {
    try {
      await _isar.writeTxn(() async {
        for (final trackId in trackIds) {
          // Delete metadata
          final metadataDoc = await _isar.cacheMetadataDocuments
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();
          if (metadataDoc != null) {
            await _isar.cacheMetadataDocuments.delete(metadataDoc.isarId);
          }
          
          // Delete reference
          final referenceDoc = await _isar.cacheReferenceDocuments
              .where()
              .trackIdEqualTo(trackId)
              .findFirst();
          if (referenceDoc != null) {
            await _isar.cacheReferenceDocuments.delete(referenceDoc.isarId);
          }
        }
      });

      return const Right(unit);
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
      await _isar.writeTxn(() async {
        // Clear all metadata and references
        await _isar.cacheMetadataDocuments.clear();
        await _isar.cacheReferenceDocuments.clear();
      });

      return const Right(unit);
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
    return _isar.cacheReferenceDocuments
        .where()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .map((documents) => documents.isNotEmpty ? documents.first.toEntity() : null);
  }

  @override
  Stream<CacheMetadata?> watchMetadata(String trackId) {
    return _isar.cacheMetadataDocuments
        .where()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .map((documents) => documents.isNotEmpty ? documents.first.toEntity() : null);
  }

  @override
  Stream<List<CacheReference>> watchAllReferences() {
    return _isar.cacheReferenceDocuments
        .where()
        .watch(fireImmediately: true)
        .map((documents) => documents.map((doc) => doc.toEntity()).toList());
  }
}
import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/features/track_version/data/models/track_version_document.dart';

abstract class TrackVersionLocalDataSource {
  Future<Either<Failure, TrackVersionDTO>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
    Duration? duration,
  });

  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, List<TrackVersionDTO>>> getVersionsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, TrackVersionDTO>> getById(TrackVersionId id);

  Future<Either<Failure, TrackVersionDTO>> getActiveVersion(
    AudioTrackId trackId,
  );

  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  });

  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId);

  Future<Either<Failure, Unit>> renameVersion({
    required TrackVersionId versionId,
    required String? newLabel,
  });

  // Sync operations
  Future<Either<Failure, Unit>> cacheVersion(TrackVersionDTO version);
  Future<Either<Failure, List<TrackVersionDTO>>> getAllVersions();
  Future<Either<Failure, TrackVersionDTO?>> getVersionById(String id);
  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrackId(
    String trackId,
  );
  Future<Either<Failure, Unit>> clearCache();
}

@LazySingleton(as: TrackVersionLocalDataSource)
class IsarTrackVersionLocalDataSource implements TrackVersionLocalDataSource {
  final Isar _isar;

  IsarTrackVersionLocalDataSource(this._isar);

  @override
  Future<Either<Failure, TrackVersionDTO>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
    Duration? duration,
  }) async {
    try {
      // Get existing versions for this track to calculate version number
      final existingVersions =
          await _isar.trackVersionDocuments
              .filter()
              .trackIdEqualTo(trackId.value)
              .sortByVersionNumberDesc()
              .findAll();

      final nextVersionNumber =
          existingVersions.isNotEmpty
              ? existingVersions.first.versionNumber + 1
              : 1;

      final dto = TrackVersionDTO(
        id: TrackVersionId().value,
        trackId: trackId.value,
        versionNumber: nextVersionNumber,
        label: label,
        fileLocalPath: file.path,
        fileRemoteUrl: null,
        durationMs: duration?.inMilliseconds,
        status: 'processing',
        createdAt: DateTime.now(),
        createdBy: UserId().value,
      );

      final document = TrackVersionDocument.forUpload(dto);
      await _isar.writeTxn(() async {
        await _isar.trackVersionDocuments.put(document);
      });

      return Right(dto);
    } catch (e) {
      return Left(CacheFailure('Failed to add version: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrack(
    AudioTrackId trackId,
  ) {
    try {
      // Read all then filter after DTO conversion to handle legacy wrapped IDs
      return _isar.trackVersionDocuments
          .where()
          .sortByVersionNumberDesc()
          .watch(fireImmediately: true)
          .map<Either<Failure, List<TrackVersionDTO>>>(
            (documents) => Right(
              documents
                  .map((doc) => doc.toDTO())
                  .where((dto) => dto.trackId == trackId.value)
                  .toList(),
            ),
          )
          .handleError(
            (e) => Left(CacheFailure('Failed to watch versions: $e')),
          );
    } catch (e) {
      return Stream.value(Left(CacheFailure('Failed to watch versions: $e')));
    }
  }

  @override
  Future<Either<Failure, List<TrackVersionDTO>>> getVersionsByTrack(
    AudioTrackId trackId,
  ) async {
    try {
      // Read all then filter after DTO conversion to handle legacy wrapped IDs
      final documents =
          await _isar.trackVersionDocuments
              .where()
              .sortByVersionNumberDesc()
              .findAll();

      final dtos =
          documents
              .map((doc) => doc.toDTO())
              .where((dto) => dto.trackId == trackId.value)
              .toList();
      return Right(dtos);
    } catch (e) {
      return Left(CacheFailure('Failed to get versions by track: $e'));
    }
  }

  @override
  Future<Either<Failure, TrackVersionDTO>> getById(TrackVersionId id) async {
    try {
      final document = await _isar.trackVersionDocuments.get(id.value.hashCode);
      if (document != null) {
        return Right(document.toDTO());
      }
      return Left(CacheFailure('Version not found'));
    } catch (e) {
      return Left(CacheFailure('Failed to get version by id: $e'));
    }
  }

  @override
  Future<Either<Failure, TrackVersionDTO>> getActiveVersion(
    AudioTrackId trackId,
  ) async {
    try {
      // Get the most recent version (highest version number) for this track
      final documents =
          await _isar.trackVersionDocuments
              .where()
              .sortByVersionNumberDesc()
              .findAll();

      final filtered =
          documents
              .map((doc) => doc.toDTO())
              .where((d) => d.trackId == trackId.value)
              .toList();

      if (filtered.isNotEmpty) {
        return Right(filtered.first);
      }
      return Left(CacheFailure('No versions found for track'));
    } catch (e) {
      return Left(CacheFailure('Failed to get active version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    // This is handled at the repository level by updating AudioTrack
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.trackVersionDocuments.delete(versionId.value.hashCode);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> renameVersion({
    required TrackVersionId versionId,
    required String? newLabel,
  }) async {
    try {
      final document = await _isar.trackVersionDocuments.get(
        versionId.value.hashCode,
      );
      if (document == null) {
        return Left(CacheFailure('Version not found'));
      }

      // Update the label
      document.label = newLabel;

      await _isar.writeTxn(() async {
        await _isar.trackVersionDocuments.put(document);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to rename version: $e'));
    }
  }

  // Sync operations implementation
  @override
  Future<Either<Failure, Unit>> cacheVersion(TrackVersionDTO version) async {
    try {
      final document = TrackVersionDocument.fromDTO(version);
      await _isar.writeTxn(() async {
        await _isar.trackVersionDocuments.put(document);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache version: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TrackVersionDTO>>> getAllVersions() async {
    try {
      final documents = await _isar.trackVersionDocuments.where().findAll();
      final dtos = documents.map((doc) => doc.toDTO()).toList();
      return Right(dtos);
    } catch (e) {
      return Left(CacheFailure('Failed to get all versions: $e'));
    }
  }

  @override
  Future<Either<Failure, TrackVersionDTO?>> getVersionById(String id) async {
    try {
      final document = await _isar.trackVersionDocuments.get(id.hashCode);
      return Right(document?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get version by id: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrackId(
    String trackId,
  ) {
    try {
      return _isar.trackVersionDocuments
          .filter()
          .trackIdEqualTo(trackId)
          .sortByVersionNumberDesc()
          .watch(fireImmediately: true)
          .map<Either<Failure, List<TrackVersionDTO>>>(
            (documents) => Right(documents.map((doc) => doc.toDTO()).toList()),
          )
          .handleError(
            (e) => Left(CacheFailure('Failed to watch versions: $e')),
          );
    } catch (e) {
      return Stream.value(Left(CacheFailure('Failed to watch versions: $e')));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.trackVersionDocuments.clear();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }
}

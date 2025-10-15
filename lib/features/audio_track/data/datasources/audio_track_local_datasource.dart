import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackLocalDataSource {
  Future<Either<Failure, Unit>> cacheTrack(AudioTrackDTO track);
  Future<Either<Failure, AudioTrackDTO?>> getTrackById(String id);

  /// Watch a single track by id from local cache
  Stream<Either<Failure, AudioTrackDTO?>> watchTrackById(String id);
  Future<Either<Failure, List<AudioTrackDTO>>> getAllTracks();
  Future<Either<Failure, Unit>> deleteTrack(String id);
  Future<Either<Failure, Unit>> deleteAllTracks();
  Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(
    String projectId,
  );

  /// Watch all tracks from projects where userId is owner or collaborator
  Stream<List<AudioTrackDTO>> watchAllAccessibleTracks(String userId);

  Future<Either<Failure, Unit>> clearCache();
  Future<Either<Failure, Unit>> updateTrackName(String trackId, String newName);
  Future<Either<Failure, Unit>> updateTrackUrl(String trackId, String newUrl);
  Future<Either<Failure, Unit>> setActiveVersion(
    String trackId,
    String versionId,
  );
}

@LazySingleton(as: AudioTrackLocalDataSource)
class IsarAudioTrackLocalDataSource implements AudioTrackLocalDataSource {
  final Isar _isar;

  IsarAudioTrackLocalDataSource(this._isar);

  @override
  Future<Either<Failure, Unit>> cacheTrack(AudioTrackDTO track) async {
    try {
      final trackDoc = AudioTrackDocument.fromDTO(track);
      await _isar.writeTxn(() async {
        await _isar.audioTrackDocuments.put(trackDoc);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache track: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioTrackDTO?>> getTrackById(String id) async {
    try {
      final trackDoc = await _isar.audioTrackDocuments.get(fastHash(id));
      return Right(trackDoc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get track by id: $e'));
    }
  }

  @override
  Stream<Either<Failure, AudioTrackDTO?>> watchTrackById(String id) {
    try {
      final stream = _isar.audioTrackDocuments
          .where()
          .filter()
          .idEqualTo(id)
          .watch(fireImmediately: true)
          .map<Either<Failure, AudioTrackDTO?>>((docs) {
            final doc = docs.isNotEmpty ? docs.first : null;
            return right<Failure, AudioTrackDTO?>(doc?.toDTO());
          });
      return stream.handleError(
        (e) => left(ServerFailure('Failed to watch track: $e')),
      );
    } catch (e) {
      return Stream.value(left(CacheFailure('Failed to watch track: $e')));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackDTO>>> getAllTracks() async {
    try {
      final tracks = await _isar.audioTrackDocuments.where().findAll();
      return Right(tracks.map((doc) => doc.toDTO()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get all tracks: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(String id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioTrackDocuments.delete(fastHash(id));
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllTracks() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioTrackDocuments.clear();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete all tracks: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(
    String projectId,
  ) {
    return _isar.audioTrackDocuments
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .watch(fireImmediately: true)
        .map(
          (docs) => right<Failure, List<AudioTrackDTO>>(
            docs.map((doc) => doc.toDTO()).toList(),
          ),
        )
        .handleError((e) => left(ServerFailure(e.toString())));
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioTrackDocuments.clear();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrackName(
    String trackId,
    String newName,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final track = await _isar.audioTrackDocuments.get(fastHash(trackId));
        if (track != null) {
          track.name = newName;
          await _isar.audioTrackDocuments.put(track);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update track name: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrackUrl(
    String trackId,
    String newUrl,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final track = await _isar.audioTrackDocuments.get(fastHash(trackId));
        if (track != null) {
          track.url = newUrl;
          await _isar.audioTrackDocuments.put(track);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update track url: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion(
    String trackId,
    String versionId,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final track = await _isar.audioTrackDocuments.get(fastHash(trackId));
        if (track != null) {
          track.activeVersionId = versionId;
          await _isar.audioTrackDocuments.put(track);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to set active version: $e'));
    }
  }

  @override
  Stream<List<AudioTrackDTO>> watchAllAccessibleTracks(String userId) {
    return _isar.audioTrackDocuments
        .where()
        .watch(fireImmediately: true)
        .asyncMap((tracks) async {
          // Filter tracks to only include those from accessible projects
          final accessibleTracks = <AudioTrackDocument>[];

          for (final track in tracks) {
            // Get the project for this track
            final project = await _isar.projectDocuments
                .filter()
                .idEqualTo(track.projectId)
                .isDeletedEqualTo(false)
                .findFirst();

            if (project != null) {
              // Check if user has access (is owner or collaborator)
              final hasAccess = project.ownerId == userId ||
                  project.collaboratorIds.contains(userId);

              if (hasAccess) {
                accessibleTracks.add(track);
              }
            }
          }

          return accessibleTracks.map((doc) => doc.toDTO()).toList();
        });
  }
}

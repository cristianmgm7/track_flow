import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class AudioTrackLocalDataSource {
  Future<Either<Failure, Unit>> cacheTrack(AudioTrackDTO track);
  Future<Either<Failure, AudioTrackDTO?>> getTrackById(AudioTrackId id);
  Future<Either<Failure, Unit>> deleteTrack(AudioTrackId id);
  Future<Either<Failure, Unit>> deleteAllTracks();
  Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(
    ProjectId projectId,
  );
  Future<Either<Failure, Unit>> clearCache();
  Future<Either<Failure, Unit>> updateTrackName(AudioTrackId trackId, String newName);
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
  Future<Either<Failure, AudioTrackDTO?>> getTrackById(AudioTrackId id) async {
    try {
      final trackDoc = await _isar.audioTrackDocuments.get(fastHash(id.value));
      return Right(trackDoc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get track by id: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(AudioTrackId id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioTrackDocuments.delete(fastHash(id.value));
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
    ProjectId projectId,
  ) {
    return _isar.audioTrackDocuments
        .where()
        .filter()
        .projectIdEqualTo(projectId.value)
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
  Future<Either<Failure, Unit>> updateTrackName(AudioTrackId trackId, String newName) async {
    try {
      await _isar.writeTxn(() async {
        final track = await _isar.audioTrackDocuments.get(fastHash(trackId.value));
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
}

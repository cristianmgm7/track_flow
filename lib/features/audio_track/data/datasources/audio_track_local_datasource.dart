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
  Future<Either<Failure, Unit>> deleteTrack(String id);
  Future<Either<Failure, Unit>> deleteAllTracks();
  Stream<Either<Failure, List<AudioTrackDTO>>> watchTracksByProject(
    String projectId,
  );
  Future<Either<Failure, Unit>> clearCache();
  Future<Either<Failure, Unit>> updateTrackName(String trackId, String newName);
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
  Future<Either<Failure, Unit>> updateTrackName(String trackId, String newName) async {
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
}

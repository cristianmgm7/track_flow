import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class AudioTrackRepository {
  Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id);

  /// Watch a single track by id. Emits updates when the track changes in local cache.
  Stream<Either<Failure, AudioTrack>> watchTrackById(AudioTrackId id);

  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  );

  /// Create a new track with metadata only (no file upload)
  Future<Either<Failure, AudioTrack>> createTrack(AudioTrack track);

  Future<Either<Failure, Unit>> deleteTrack(
    AudioTrackId trackId,
    ProjectId projectId,
  );

  Future<Either<Failure, Unit>> editTrackName({
    required AudioTrackId trackId,
    required ProjectId projectId,
    required String newName,
  });

  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  });

  /// Delete all tracks from local cache
  Future<Either<Failure, Unit>> deleteAllTracks();
}

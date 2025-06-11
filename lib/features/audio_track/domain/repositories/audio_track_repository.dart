import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'dart:io';

abstract class AudioTrackRepository {
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  );
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  });

  Future<Either<Failure, Unit>> deleteTrack(String trackId);
}

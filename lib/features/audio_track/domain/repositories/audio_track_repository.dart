import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'dart:io';

abstract class AudioTrackRepository {
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required String name,
    required Duration duration,
    required List<String> projectIds,
    required String uploadedBy,
  });

  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    String projectId,
  );

  Future<Either<Failure, Unit>> deleteTrack(String trackId);
}

import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class WatchAudioTracksByProjectParams {
  final String projectId;

  WatchAudioTracksByProjectParams({required this.projectId});
}

class WatchAudioTracksByProject {
  final AudioTrackRepository repository;

  WatchAudioTracksByProject(this.repository);

  Stream<Either<Failure, List<AudioTrack>>> call(String projectId) {
    return repository.watchTracksByProject(projectId);
  }
}

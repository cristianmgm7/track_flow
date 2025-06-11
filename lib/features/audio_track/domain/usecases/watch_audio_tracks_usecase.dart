import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class WatchAudioTracksByProjectParams {
  final ProjectId projectId;

  WatchAudioTracksByProjectParams({required this.projectId});
}

@lazySingleton
class WatchAudioTracksByProject {
  final AudioTrackRepository repository;

  WatchAudioTracksByProject(this.repository);

  Stream<Either<Failure, List<AudioTrack>>> call(ProjectId projectId) {
    return repository.watchTracksByProject(projectId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class WatchTracksByProjectIdParams {
  final ProjectId projectId;

  WatchTracksByProjectIdParams({required this.projectId});
}

@lazySingleton
class WatchTracksByProjectIdUseCase {
  final AudioTrackRepository repository;

  WatchTracksByProjectIdUseCase(this.repository);

  Stream<Either<Failure, List<AudioTrack>>> call(
    WatchTracksByProjectIdParams params,
  ) {
    return repository.watchTracksByProject(params.projectId);
  }
}

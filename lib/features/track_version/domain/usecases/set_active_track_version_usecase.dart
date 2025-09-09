import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

class SetActiveTrackVersionParams {
  final AudioTrackId trackId;
  final TrackVersionId versionId;
  SetActiveTrackVersionParams({required this.trackId, required this.versionId});
}

@lazySingleton
class SetActiveTrackVersionUseCase {
  final AudioTrackRepository repository;
  SetActiveTrackVersionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(SetActiveTrackVersionParams params) {
    return repository.setActiveVersion(
      trackId: params.trackId,
      versionId: params.versionId,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

class DeleteTrackVersionParams {
  final TrackVersionId versionId;

  DeleteTrackVersionParams({required this.versionId});
}

@lazySingleton
class DeleteTrackVersionUseCase {
  final TrackVersionRepository repository;

  DeleteTrackVersionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(DeleteTrackVersionParams params) {
    return repository.deleteVersion(params.versionId);
    // TODO: Implement delete of waveforms for the version
    // TODO: Implement delete of comments for the version
    // TODO: Implement delete of audio file for the version
    // TODO: Implement delete of audio file for the version
  }
}

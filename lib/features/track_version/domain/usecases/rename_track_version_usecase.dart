import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

class RenameTrackVersionParams {
  final TrackVersionId versionId;
  final String? newLabel;

  RenameTrackVersionParams({required this.versionId, required this.newLabel});
}

@lazySingleton
class RenameTrackVersionUseCase {
  final TrackVersionRepository repository;

  RenameTrackVersionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RenameTrackVersionParams params) {
    return repository.renameVersion(
      versionId: params.versionId,
      newLabel: params.newLabel,
    );
  }
}

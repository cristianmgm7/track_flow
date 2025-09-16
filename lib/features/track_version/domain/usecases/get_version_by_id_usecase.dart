import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

@lazySingleton
class GetVersionByIdUseCase {
  final TrackVersionRepository repository;
  GetVersionByIdUseCase(this.repository);

  Future<Either<Failure, TrackVersion>> call(TrackVersionId id) {
    return repository.getById(id);
  }
}

import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

class GetProjectByIdUseCase {
  final ProjectRepository repository;

  GetProjectByIdUseCase(this.repository);

  Future<Either<Failure, Project>> call(UniqueId id) {
    return repository.getProjectById(id);
  }
}

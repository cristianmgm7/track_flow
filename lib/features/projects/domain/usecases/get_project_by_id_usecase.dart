import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Use case for retrieving a project by its ID.
class GetProjectByIdUseCase {
  final ProjectRepository _repository;

  GetProjectByIdUseCase(this._repository);

  /// Gets a project by its ID.
  ///
  /// Returns Either<Failure, Project>.
  Future<Either<Failure, Project>> call(String projectId) async {
    if (projectId.isEmpty) {
      return Left(ValidationFailure('Project ID cannot be empty'));
    }
    return _repository.getProjectById(projectId);
  }
}

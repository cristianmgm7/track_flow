import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Use case for updating an existing project.
///
/// This use case implements the business rules for updating projects:
/// - Uses ProjectModel for validation and business rules
/// - Ensures project can be edited (not finished)
/// - Validates all project fields
/// - Calls repository to update the project
class UpdateProjectUseCase {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  /// Updates an existing project.
  ///
  /// Returns Either<Failure, Project>.
  Future<Either<Failure, Project>> call(Project project) async {
    // Check if project can be edited
    if (!project.canEdit()) {
      return Left(ValidationFailure('Cannot modify a finished project'));
    }

    // Validate project fields
    return project.validate().fold(
      (failure) => Left(failure),
      (validProject) => _repository.updateProject(validProject),
    );
  }
}

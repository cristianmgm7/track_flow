import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Use case for creating a new project.
///
/// This use case implements the business rules for creating projects:
/// - Validates required fields (title, userId, status)
/// - Ensures status is valid
/// - Calls repository to create the project
class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  /// Creates a new project.
  ///
  /// Returns Either<Failure, Project>.
  /// Throws [Exception] for validation errors.
  Future<Either<Failure, Project>> call(Project project) async {
    // Validate required fields
    if (project.title.isEmpty) {
      return Left(ValidationFailure(message: 'Project title cannot be empty'));
    }
    if (project.userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    if (!Project.validStatuses.contains(project.status)) {
      return Left(ValidationFailure(message: 'Invalid project status'));
    }
    // Call repository
    return await _repository.createProject(project);
  }
}

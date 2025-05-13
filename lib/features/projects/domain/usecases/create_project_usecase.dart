import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/models/project_model.dart';

/// Use case for creating a new project.
///
/// This use case implements the business rules for creating projects:
/// - Uses ProjectModel for validation and business rules
/// - Ensures all project fields are valid
/// - Calls repository to create the project
class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  /// Creates a new project.
  ///
  /// Returns Either<Failure, Project>.
  Future<Either<Failure, Project>> call(Project project) async {
    // Use ProjectModel for validation
    final model = ProjectModel(project);

    return model.validate().fold(
      (failure) => Left(failure),
      (validProject) => _repository.createProject(validProject),
    );
  }
}

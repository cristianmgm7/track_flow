import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Use case for deleting a project.
///
/// This use case implements the business rules for deleting projects:
/// - Validates projectId and userId
/// - Checks ownership before deletion
/// - Calls repository to delete the project
class DeleteProjectUseCase {
  final ProjectRepository _repository;

  DeleteProjectUseCase(this._repository);

  /// Deletes a project by its ID and userId.
  ///
  /// Returns Either<Failure, void>.
  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    if (projectId.isEmpty) {
      return Left(ValidationFailure(message: 'Project ID cannot be empty'));
    }
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    // Get the project to check ownership
    final result = await _repository.getProjectById(projectId);
    return result.fold((failure) => Left(failure), (project) {
      if (project.userId != userId) {
        return Left(
          PermissionFailure(message: 'User does not own this project'),
        );
      }
      return _repository.deleteProject(projectId);
    });
  }
}

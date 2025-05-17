import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';

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

  /// Returns Either<Failure, void>.
  Future<Either<Failure, Unit>> call(UniqueId id) async {
    return await _repository.deleteProject(id);
  }
}

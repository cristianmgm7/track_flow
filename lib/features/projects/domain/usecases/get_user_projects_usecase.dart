import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// Use case for retrieving all projects for a specific user.
///
/// This use case implements the business rules for retrieving projects:
/// - Only returns projects owned by the specified user
/// - Projects are sorted by creation date (newest first)
/// - Handles various failure cases with Either type
class GetUserProjectsUseCase {
  GetUserProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  /// Get all projects for a specific user.
  ///
  /// Returns an Either with:
  /// - Left: Failure if something goes wrong
  /// - Right: Stream of project lists, sorted by creation date (newest first)
  ///
  /// The stream will emit new lists whenever the underlying data changes.
  Either<Failure, Stream<List<Project>>> call(String userId) {
    if (userId.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }

    return _repository.getUserProjects(userId);
  }

  /// Get all projects for a specific user with a given status.
  ///
  /// Returns an Either with:
  /// - Left: Failure if something goes wrong
  /// - Right: Stream of project lists, filtered by status and sorted by creation date
  ///
  /// The stream will emit new lists whenever the underlying data changes.
  Either<Failure, Stream<List<Project>>> getByStatus(
    String userId,
    String status,
  ) {
    if (userId.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }

    if (!Project.validStatuses.contains(status)) {
      return Left(ValidationFailure('Invalid project status: $status'));
    }

    return _repository.getUserProjectsByStatus(userId, status);
  }
}

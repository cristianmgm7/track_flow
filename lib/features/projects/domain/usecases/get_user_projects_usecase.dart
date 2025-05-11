import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// Use case for retrieving all projects for a specific user.
///
/// This use case implements the business rules for retrieving projects:
/// - Only returns projects owned by the specified user
/// - Projects are sorted by creation date (newest first)
class GetUserProjectsUseCase {
  final ProjectRepository _repository;

  GetUserProjectsUseCase(this._repository);

  /// Get all projects for a specific user.
  ///
  /// Returns a stream of project lists, sorted by creation date (newest first).
  /// The stream will emit new lists whenever the underlying data changes.
  ///
  /// Throws [Exception] if the user ID is invalid or if there's a repository error.
  Stream<List<Project>> call(String userId) {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    return _repository.getUserProjects(userId);
  }

  /// Get all projects for a specific user with a given status.
  ///
  /// Returns a stream of project lists, filtered by status and sorted by creation date.
  /// The stream will emit new lists whenever the underlying data changes.
  ///
  /// Throws [Exception] if:
  /// - User ID is invalid
  /// - Status is not a valid project status
  /// - There's a repository error
  Stream<List<Project>> getByStatus(String userId, String status) {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    if (!Project.validStatuses.contains(status)) {
      throw Exception('Invalid project status: $status');
    }

    return _repository.getUserProjectsByStatus(userId, status);
  }
}

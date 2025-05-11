import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// Use case for updating an existing project.
///
/// This use case implements the business rules for updating projects:
/// - Verifies project exists
/// - Verifies user owns the project
/// - Validates status transitions
/// - Ensures required fields are present
class UpdateProjectUseCase {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  /// Update an existing project.
  ///
  /// Throws [Exception] if:
  /// - Project doesn't exist
  /// - User doesn't own the project
  /// - Status transition is invalid
  /// - Required fields are missing
  /// - There's a repository error
  Future<void> call(Project project) async {
    // Validate required fields
    if (project.title.isEmpty) {
      throw Exception('Project title cannot be empty');
    }

    // Get existing project to validate ownership and status transition
    final existingProject = await _repository.getProject(project.id);
    if (existingProject == null) {
      throw Exception('Project not found');
    }

    // Verify ownership
    if (existingProject.userId != project.userId) {
      throw Exception('User does not own this project');
    }

    // Validate status transition
    _validateStatusTransition(existingProject.status, project.status);

    // Update the project
    await _repository.updateProject(project);
  }

  /// Validates that the status transition is allowed.
  ///
  /// Allowed transitions:
  /// - draft -> in_progress
  /// - in_progress -> finished
  /// - Any status -> same status (no change)
  void _validateStatusTransition(String oldStatus, String newStatus) {
    if (oldStatus == newStatus) return; // No change is always valid

    final validTransitions = {
      Project.statusDraft: [Project.statusInProgress],
      Project.statusInProgress: [Project.statusFinished],
      Project.statusFinished: [], // Can't transition from finished
    };

    final allowedTransitions = validTransitions[oldStatus] ?? [];
    if (!allowedTransitions.contains(newStatus)) {
      throw Exception(
        'Invalid status transition: cannot change from $oldStatus to $newStatus',
      );
    }
  }
}

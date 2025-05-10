import '../models/project.dart';

/// Abstract class defining the contract for project operations.
///
/// This repository interface defines all the operations that can be performed
/// on projects, following the repository pattern to abstract the data source.
abstract class ProjectRepository {
  /// Creates a new project.
  Future<Project> createProject(Project project);

  /// Updates an existing project.
  Future<void> updateProject(Project project);

  /// Deletes a project by its ID.
  Future<void> deleteProject(String projectId);

  /// Gets a project by its ID.
  Future<Project?> getProject(String projectId);

  /// Gets all projects for a specific user.
  Stream<List<Project>> getUserProjects(String userId);

  /// Gets all projects for a specific user with a given status.
  Stream<List<Project>> getUserProjectsByStatus(String userId, String status);
}

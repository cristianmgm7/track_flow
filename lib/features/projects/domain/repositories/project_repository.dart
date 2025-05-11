import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/project.dart';

/// Abstract class defining the contract for project operations.
///
/// This repository interface defines all the operations that can be performed
/// on projects, following the repository pattern to abstract the data source.
abstract class ProjectRepository {
  /// Creates a new project.
  Future<Either<Failure, Project>> createProject(Project project);

  /// Updates an existing project.
  Future<Either<Failure, Project>> updateProject(Project project);

  /// Deletes a project by its ID.
  Future<Either<Failure, void>> deleteProject(String projectId);

  /// Gets a project by its ID.
  Future<Either<Failure, Project>> getProjectById(String projectId);

  /// Gets all projects for a specific user.
  ///
  /// Returns Either:
  /// - Right: Stream of project lists if successful
  /// - Left: Failure if initial stream setup fails
  Either<Failure, Stream<List<Project>>> getUserProjects(String userId);

  /// Gets all projects for a specific user with a given status.
  ///
  /// Returns Either:
  /// - Right: Stream of filtered project lists if successful
  /// - Left: Failure if initial stream setup fails
  Either<Failure, Stream<List<Project>>> getUserProjectsByStatus(
    String userId,
    String status,
  );
}

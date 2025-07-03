import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

/// Repository responsible for managing project collaborators
/// Follows Single Responsibility Principle - only handles collaborator operations
abstract class CollaboratorRepository {
  /// Join a project as a collaborator
  Future<Either<Failure, Unit>> joinProject(
    ProjectId projectId,
    UserId userId,
  );

  /// Leave a project as a collaborator
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  });

  /// Add a collaborator to a project with specific role
  Future<Either<Failure, Unit>> addCollaborator(
    ProjectId projectId,
    UserId userId,
    ProjectRole role,
  );

  /// Remove a collaborator from a project
  Future<Either<Failure, Unit>> removeCollaborator(
    ProjectId projectId,
    UserId userId,
  );

  /// Update collaborator role in a project
  Future<Either<Failure, Unit>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    ProjectRole newRole,
  );
}
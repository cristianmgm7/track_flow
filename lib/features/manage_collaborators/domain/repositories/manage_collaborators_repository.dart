import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/error/failures.dart';

/// Legacy repository for managing collaborators and projects
/// DEPRECATED: Use CollaboratorRepository and ProjectsRepository directly
/// This composite will be removed in future versions
@Deprecated('Use CollaboratorRepository for collaborator operations and ProjectsRepository for project operations')
abstract class ManageCollaboratorsRepository {
  Future<Either<Failure, Unit>> joinProjectWithId(
    ProjectId projectId,
    UserId userId,
  );

  @Deprecated('Use ProjectsRepository.updateProject() instead')
  Future<Either<Failure, Project>> updateProject(Project project);

  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  });
}

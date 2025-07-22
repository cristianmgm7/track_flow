import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';

import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart'
    as manage_collab_exc;

class RemoveCollaboratorParams extends Equatable {
  final ProjectId projectId;
  final UserId collaboratorId;

  const RemoveCollaboratorParams({
    required this.projectId,
    required this.collaboratorId,
  });

  @override
  List<Object?> get props => [projectId, collaboratorId];
}

@lazySingleton
class RemoveCollaboratorUseCase {
  final ProjectsRepository _repositoryProjectDetail;
  final SessionStorage _sessionService;

  RemoveCollaboratorUseCase(
    this._repositoryProjectDetail,
    this._sessionService,
  );

  Future<Either<Failure, Project>> call(RemoveCollaboratorParams params) async {
    final userId = await _sessionService.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    final projectResult = await _repositoryProjectDetail.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      final currentUserCollaborator = project.collaborators.firstWhere(
        (collaborator) => collaborator.userId.value == userId,
        orElse: () => throw UserNotCollaboratorException(),
      );

      if (!currentUserCollaborator.hasPermission(
        ProjectPermission.removeCollaborator,
      )) {
        return left(ProjectPermissionException());
      }

      try {
        // Use domain logic to remove collaborator
        final updatedProject = project.removeCollaborator(
          params.collaboratorId,
        );

        // Save the updated project using the projects repository
        final saveResult = await _repositoryProjectDetail.updateProject(
          updatedProject,
        );

        return saveResult.fold(
          (failure) => left(failure),
          (_) => right(updatedProject),
        );
      } on CollaboratorNotFoundException catch (e) {
        return left(
          manage_collab_exc.ManageCollaboratorException(e.toString()),
        );
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

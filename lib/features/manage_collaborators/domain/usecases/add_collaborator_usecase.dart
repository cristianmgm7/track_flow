import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart'
    as manage_collab_exc;

class AddCollaboratorToProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId collaboratorId;

  const AddCollaboratorToProjectParams({
    required this.projectId,
    required this.collaboratorId,
  });

  @override
  List<Object?> get props => [projectId, collaboratorId];
}

@lazySingleton
class AddCollaboratorToProjectUseCase {
  final ProjectDetailRepository _repositoryProjectDetail;
  final ManageCollaboratorsRepository _repositoryManageCollaborators;
  final SessionStorage _sessionService;

  AddCollaboratorToProjectUseCase(
    this._repositoryProjectDetail,
    this._repositoryManageCollaborators,
    this._sessionService,
  );

  Future<Either<Failure, Project>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    final userId = _sessionService.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    // Obtener el proyecto del repositorio
    final projectResult = await _repositoryProjectDetail.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      final currentUserCollaborator = project.collaborators.firstWhere(
        (collaborator) => collaborator.userId.value == userId,
        orElse: () => throw UserNotCollaboratorException(),
      );

      if (!currentUserCollaborator.hasPermission(
        ProjectPermission.addCollaborator,
      )) {
        return left(ProjectPermissionException());
      }

      final newCollaborator = ProjectCollaborator.create(
        userId: params.collaboratorId,
        role: ProjectRole.viewer,
      );

      try {
        final updatedProject = project.addCollaborator(newCollaborator);
        final result = await _repositoryManageCollaborators.updateProject(
          updatedProject,
        );
        return result;
      } on manage_collab_exc.CollaboratorAlreadyExistsException catch (e) {
        return left(
          manage_collab_exc.ManageCollaboratorException(e.toString()),
        );
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

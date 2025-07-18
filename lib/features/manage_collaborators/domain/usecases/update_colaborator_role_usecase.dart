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
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class UpdateCollaboratorRoleParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;
  final ProjectRole role;

  const UpdateCollaboratorRoleParams({
    required this.projectId,
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, userId, role];
}

@lazySingleton
class UpdateCollaboratorRoleUseCase {
  final ProjectsRepository _repositoryProjectDetail;
  final SessionStorage _sessionService;

  UpdateCollaboratorRoleUseCase(
    this._repositoryProjectDetail,
    this._sessionService,
  );

  Future<Either<Failure, Project>> call(
    UpdateCollaboratorRoleParams params,
  ) async {
    final userId = _sessionService.getUserId();
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
        ProjectPermission.updateCollaboratorRole,
      )) {
        return left(ProjectPermissionException());
      }

      if (params.userId == currentUserCollaborator.userId) {
        return left(ServerFailure("You can't change your own role."));
      }

      try {
        // Use domain logic to update collaborator role
        final updatedProject = project.updateCollaboratorRole(
          params.userId,
          params.role,
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
        return left(ServerFailure(e.toString()));
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

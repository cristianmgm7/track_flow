import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart';

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
  final CollaboratorRepository _collaboratorRepository;
  final SessionStorage _sessionService;

  UpdateCollaboratorRoleUseCase(
    this._repositoryProjectDetail,
    this._collaboratorRepository,
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
        final result = await _collaboratorRepository.updateCollaboratorRole(
          params.projectId,
          params.userId,
          params.role,
        );
        return result.fold((failure) => left(failure), (_) async {
          // Return updated project after successful role update
          final updatedProject = project.updateCollaboratorRole(
            params.userId,
            params.role,
          );
          return right(updatedProject);
        });
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

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
  final ManageCollaboratorsRepository _repository;
  final SessionStorage _sessionService;

  AddCollaboratorToProjectUseCase(this._repository, this._sessionService);

  Future<Either<Failure, void>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    final userId = _sessionService.getUserId();
    if (userId == null) {
      return left(ServerFailure('No user found'));
    }

    // Fetch the project
    final projectOrFailure = await _repository.getProjectById(params.projectId);
    return projectOrFailure.fold((failure) => left(failure), (project) {
      // Check if the current user has permission to add a collaborator
      final currentUserCollaborator = project.collaborators.firstWhere(
        (collaborator) => collaborator.userId == userId,
        orElse: () => throw UserNotCollaboratorException(),
      );

      if (!currentUserCollaborator.hasPermission(
        ProjectPermission.addCollaborator,
      )) {
        return left(ProjectPermissionException());
      }

      // Create a new collaborator
      final newCollaborator = ProjectCollaborator.create(
        userId: params.collaboratorId,
        role: ProjectRole.viewer, // Default role, can be adjusted
      );

      // Add the collaborator to the project
      try {
        project.addCollaborator(newCollaborator);
        return _repository.updateProject(project);
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

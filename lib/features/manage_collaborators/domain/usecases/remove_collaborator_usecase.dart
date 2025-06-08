import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';

@immutable
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
  final ManageCollaboratorsRepository _repository;
  final SessionStorage _sessionService;

  RemoveCollaboratorUseCase(this._repository, this._sessionService);

  Future<Either<Failure, void>> call(RemoveCollaboratorParams params) async {
    final userId = _sessionService.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    final projectResult = await _repository.getProjectById(params.projectId);
    return projectResult.fold((failure) => left(failure), (project) async {
      // Debug print: list all collaborator userIds and the session userId
      debugPrint('Colaboradores en el proyecto:');
      for (final c in project.collaborators) {
        debugPrint('userId: \\${c.userId.value}');
      }
      debugPrint('Buscando userId de sesión: \\$userId');
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
        final updatedProject = project.removeCollaborator(
          params.collaboratorId,
        );
        return await _repository.updateProject(updatedProject);
      } on CollaboratorNotFoundException catch (e) {
        return left(ServerFailure(e.toString()));
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

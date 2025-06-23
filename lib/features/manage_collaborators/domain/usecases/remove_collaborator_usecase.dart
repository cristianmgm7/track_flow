import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
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
  final ProjectDetailRepository _repositoryProjectDetail;
  final ManageCollaboratorsRepository _repositoryManageCollaborators;
  final SessionStorage _sessionService;

  RemoveCollaboratorUseCase(
    this._repositoryProjectDetail,
    this._repositoryManageCollaborators,
    this._sessionService,
  );

  Future<Either<Failure, Project>> call(RemoveCollaboratorParams params) async {
    final userId = _sessionService.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    final projectResult = await _repositoryProjectDetail.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      final currentUserCollaborator = project.collaborators.firstWhere(
        (collaborator) => collaborator.userId.value == userId,
        orElse:
            () =>
                throw ManageCollaboratorException('User is not a collaborator'),
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
        final result = await _repositoryManageCollaborators.updateProject(
          updatedProject,
        );
        return result;
      } on CollaboratorNotFoundException catch (e) {
        return left(ManageCollaboratorException(e.toString()));
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';

import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart'
    as manage_collab_exc;

class JoinProjectWithIdParams extends Equatable {
  final ProjectId projectId;

  const JoinProjectWithIdParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class JoinProjectWithIdUseCase {
  final ProjectsRepository _repositoryProjectDetail;
  final SessionStorage _sessionRepository;

  JoinProjectWithIdUseCase(
    this._repositoryProjectDetail,
    this._sessionRepository,
  );

  Future<Either<Failure, Project>> call(JoinProjectWithIdParams params) async {
    final userId = await _sessionRepository.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    final projectResult = await _repositoryProjectDetail.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      final alreadyExists = project.collaborators.any(
        (c) => c.userId.value == userId,
      );
      if (alreadyExists) {
        return left(ServerFailure('User is already a collaborator.'));
      }

      final newCollaborator = ProjectCollaborator.create(
        userId: UserId.fromUniqueString(userId),
        role: ProjectRole.viewer,
      );

      try {
        // Use domain logic to add collaborator
        final updatedProject = project.addCollaborator(newCollaborator);

        // Save the updated project using the projects repository
        final saveResult = await _repositoryProjectDetail.updateProject(
          updatedProject,
        );

        return saveResult.fold(
          (failure) => left(failure),
          (_) => right(updatedProject),
        );
      } on manage_collab_exc.CollaboratorAlreadyExistsException catch (e) {
        return left(ServerFailure('Failed to join project: ${e.toString()}'));
      } catch (e) {
        return left(ServerFailure('Failed to join project: ${e.toString()}'));
      }
    });
  }
}

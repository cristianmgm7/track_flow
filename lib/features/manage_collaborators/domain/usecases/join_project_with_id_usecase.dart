import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class JoinProjectWithIdParams extends Equatable {
  final ProjectId projectId;

  const JoinProjectWithIdParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class JoinProjectWithIdUseCase {
  final ProjectsRepository _repositoryProjectDetail;
  final CollaboratorRepository _collaboratorRepository;
  final SessionStorage _sessionRepository;

  JoinProjectWithIdUseCase(
    this._repositoryProjectDetail,
    this._collaboratorRepository,
    this._sessionRepository,
  );

  Future<Either<Failure, Project>> call(JoinProjectWithIdParams params) async {
    final userId = _sessionRepository.getUserId();
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
        final result = await _collaboratorRepository.joinProject(
          params.projectId,
          UserId.fromUniqueString(userId),
        );
        return result.fold(
          (failure) => left(failure),
          (_) async {
            // Return updated project after successful join
            final updatedProject = project.addCollaborator(newCollaborator);
            return right(updatedProject);
          },
        );
      } catch (e) {
        return left(ServerFailure('Failed to join project: ${e.toString()}'));
      }
    });
  }
}

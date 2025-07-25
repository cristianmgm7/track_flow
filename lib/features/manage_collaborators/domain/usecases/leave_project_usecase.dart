import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';

class LeaveProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;

  const LeaveProjectParams({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class LeaveProjectUseCase {
  final ProjectsRepository _repositoryProjectDetail;
  final SessionStorage _sessionStorage;

  LeaveProjectUseCase(this._repositoryProjectDetail, this._sessionStorage);

  Future<Either<Failure, Project>> call(LeaveProjectParams params) async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) return left(ServerFailure('No user found'));

    final projectResult = await _repositoryProjectDetail.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      try {
        // Use domain logic to remove the current user from the project
        final updatedProject = project.removeCollaborator(
          UserId.fromUniqueString(userId),
        );

        // Save the updated project using the projects repository
        final saveResult = await _repositoryProjectDetail.updateProject(
          updatedProject,
        );

        return saveResult.fold(
          (failure) => left(failure),
          (_) => right(updatedProject),
        );
      } on CollaboratorNotFoundException {
        return left(
          ServerFailure('User is not a collaborator in this project'),
        );
      } catch (e) {
        return left(ServerFailure(e.toString()));
      }
    });
  }
}

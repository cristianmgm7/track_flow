import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/project_detail/domain/entities/project_with_collaborators.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

@lazySingleton
class GetProjectWithCollaboratorsUseCase {
  final ProjectRepository _repository;

  GetProjectWithCollaboratorsUseCase(this._repository);

  Future<Either<Failure, ProjectWithCollaborators>> call(
    ProjectId projectId,
  ) async {
    try {
      final projectResult = await _repository.getProjectById(projectId);
      return projectResult.fold((failure) => Left(failure), (project) async {
        final participantsResult =
            await _repository.observeProjectParticipants(projectId).first;
        return participantsResult.fold((failure) => Left(failure), (
          userIds,
        ) async {
          // Assuming a method to fetch user profiles from user IDs
          final userProfiles = await _fetchUserProfiles(userIds);
          return Right(
            ProjectWithCollaborators(
              project: project,
              collaborators: userProfiles,
            ),
          );
        });
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<UserProfile>> _fetchUserProfiles(List<UserId> userIds) async {
    // Placeholder for fetching user profiles from user IDs
    // This should be replaced with actual implementation
    return [];
  }
}

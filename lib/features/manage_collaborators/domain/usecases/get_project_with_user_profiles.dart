import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

class GetProjectWithUserProfilesParams {
  final ProjectId projectId;

  GetProjectWithUserProfilesParams({required this.projectId});
}

class GetProjectWithUserProfilesUseCase {
  final ManageCollaboratorsRepository _repositoryManageCollaborators;
  final ProjectDetailRepository _repositoryProjectDetail;

  GetProjectWithUserProfilesUseCase(
    this._repositoryManageCollaborators,
    this._repositoryProjectDetail,
  );

  Future<Either<Failure, Tuple2<Project, List<UserProfile>>>> call(
    GetProjectWithUserProfilesParams params,
  ) async {
    final projectResult = await _repositoryManageCollaborators.getProjectById(
      params.projectId,
    );
    return projectResult.fold((failure) => left(failure), (project) async {
      final userProfilesResult = await _repositoryProjectDetail
          .getUserProfileCollaborators(project);
      return userProfilesResult.fold(
        (failure) => left(failure),
        (userProfiles) => right(Tuple2(project, userProfiles)),
      );
    });
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collabolators_remote_datasource.dart';

@LazySingleton(as: ManageCollaboratorsRepository)
class ManageCollaboratorsRepositoryImpl
    implements ManageCollaboratorsRepository {
  final ManageCollaboratorsRemoteDataSource remoteDataSourceManageCollaborators;
  final NetworkInfo networkInfo;
  final ProjectRemoteDataSource projectRemoteDataSource;

  ManageCollaboratorsRepositoryImpl({
    required this.remoteDataSourceManageCollaborators,
    required this.networkInfo,
    required this.projectRemoteDataSource,
  });

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSourceManageCollaborators.getProjectById(projectId);
  }

  @override
  Future<Either<Failure, void>> joinProjectWithId(
    ProjectId projectId,
    UserId userId,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSourceManageCollaborators
        .selfJoinProjectWithProjectId(
          projectId: projectId.value,
          userId: userId.value,
        );
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    return await remoteDataSourceManageCollaborators.updateProject(project);
  }
}

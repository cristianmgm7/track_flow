import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collabolators_remote_datasource.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart';

@LazySingleton(as: ManageCollaboratorsRepository)
class ManageCollaboratorsRepositoryImpl
    implements ManageCollaboratorsRepository {
  final ManageCollaboratorsRemoteDataSource remoteDataSourceManageCollaborators;
  final ManageCollaboratorsLocalDataSource localDataSourceManageCollaborators;
  final NetworkInfo networkInfo;

  ManageCollaboratorsRepositoryImpl({
    required this.remoteDataSourceManageCollaborators,
    required this.localDataSourceManageCollaborators,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> joinProjectWithId(
    ProjectId projectId,
    UserId userId,
  ) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    final result = await remoteDataSourceManageCollaborators
        .selfJoinProjectWithProjectId(
          projectId: projectId.value,
          userId: userId.value,
        );
    if (result.isRight()) {
      final updatedProject = await localDataSourceManageCollaborators
          .getProjectById(projectId);
      if (updatedProject != null) {
        await localDataSourceManageCollaborators.updateProject(updatedProject);
      }
    }
    return result;
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    final hasConnected = await networkInfo.isConnected;
    if (!hasConnected) {
      return left(DatabaseFailure('No internet connection'));
    }
    final result = await remoteDataSourceManageCollaborators.updateProject(
      project,
    );
    return result.fold((failure) => left(failure), (updatedProject) async {
      await localDataSourceManageCollaborators.updateProject(updatedProject);
      return right(updatedProject);
    });
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    final hasConnected = await networkInfo.isConnected;
    if (hasConnected) {
      final failureOrUnit = await remoteDataSourceManageCollaborators
          .leaveProject(projectId: projectId, userId: userId);
      if (failureOrUnit.isRight()) {
        final updatedProject = await localDataSourceManageCollaborators
            .getProjectById(projectId);
        if (updatedProject != null) {
          await localDataSourceManageCollaborators.updateProject(
            updatedProject,
          );
        }
      }
      return failureOrUnit.fold(
        (failure) => Left(failure),
        (unit) => Right(unit),
      );
    } else {
      return Left(DatabaseFailure('No internet connection'));
    }
  }
}

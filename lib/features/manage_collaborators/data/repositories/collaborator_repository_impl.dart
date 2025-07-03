import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_remote_datasource.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart';
import 'package:trackflow/features/manage_collaborators/data/datasources/manage_collaborators_local_datasource.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

@LazySingleton(as: CollaboratorRepository)
class CollaboratorRepositoryImpl implements CollaboratorRepository {
  final ManageCollaboratorsRemoteDataSource _remoteDataSource;
  final ManageCollaboratorsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  CollaboratorRepositoryImpl({
    required ManageCollaboratorsRemoteDataSource remoteDataSource,
    required ManageCollaboratorsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Unit>> joinProject(
    ProjectId projectId,
    UserId userId,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    final result = await _remoteDataSource.selfJoinProjectWithProjectId(
      projectId: projectId.value,
      userId: userId.value,
    );
    
    if (result.isRight()) {
      // Update local cache
      final updatedProject = await _localDataSource.getProjectById(projectId);
      if (updatedProject != null) {
        await _localDataSource.updateProject(updatedProject);
      }
      return const Right(unit);
    }
    
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    final result = await _remoteDataSource.leaveProject(
      projectId: projectId,
      userId: userId,
    );
    
    if (result.isRight()) {
      // Update local cache
      final updatedProject = await _localDataSource.getProjectById(projectId);
      if (updatedProject != null) {
        await _localDataSource.updateProject(updatedProject);
      }
      return const Right(unit);
    }
    
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, Unit>> addCollaborator(
    ProjectId projectId,
    UserId userId,
    ProjectRole role,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    // This would be implemented when the remote data source supports it
    return Left(ServerFailure('Add collaborator not implemented yet'));
  }

  @override
  Future<Either<Failure, Unit>> removeCollaborator(
    ProjectId projectId,
    UserId userId,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    // This would be implemented when the remote data source supports it
    return Left(ServerFailure('Remove collaborator not implemented yet'));
  }

  @override
  Future<Either<Failure, Unit>> updateCollaboratorRole(
    ProjectId projectId,
    UserId userId,
    ProjectRole newRole,
  ) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    
    // This would be implemented when the remote data source supports it
    return Left(ServerFailure('Update collaborator role not implemented yet'));
  }
}
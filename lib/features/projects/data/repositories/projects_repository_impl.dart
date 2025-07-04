import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ProjectsRepositoryImpl({
    required ProjectRemoteDataSource remoteDataSource,
    required ProjectsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    try {
      final result = await _remoteDataSource.createProject(
        ProjectDTO.fromDomain(project),
      );
      return result.fold((failure) => Left(failure), (projectWithId) async {
        await _localDataSource.cacheProject(projectWithId);
        return Right(projectWithId.toDomain());
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to create project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      await _remoteDataSource.updateProject(ProjectDTO.fromDomain(project));
      await _localDataSource.cacheProject(ProjectDTO.fromDomain(project));
      return Right(unit);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to update project: \\${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(ProjectId projectId) async {
    try {
      await _remoteDataSource.deleteProject(projectId.value);
      await _localDataSource.removeCachedProject(projectId.value);
      return Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    return await _remoteDataSource
        .getProjectById(projectId.value)
        .then(
          (either) => either.fold(
            (failure) => Left(failure),
            (project) => Right(project.toDomain()),
          ),
        );
  }

  // watching projects stream
  @override
  Stream<Either<Failure, List<Project>>> watchLocalProjects(UserId ownerId) {
    return _localDataSource
        .watchAllProjects(ownerId.value)
        .map(
          (either) => either.map(
            (projects) =>
                projects.map((project) => project.toDomain()).toList(),
          ),
        );
  }
}

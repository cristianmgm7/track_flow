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
    if (hasConnected) {
      try {
        final result = await _remoteDataSource.createProject(project);
        return await result.fold((failure) => Left(failure), (
          projectWithId,
        ) async {
          final dto = ProjectDTO.fromDomain(projectWithId);
          await _localDataSource.cacheProject(dto);
          return Right(projectWithId);
        });
      } catch (e) {
        return Left(
          DatabaseFailure('Failed to create project: ${e.toString()}'),
        );
      }
    }
    return Left(DatabaseFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      await _remoteDataSource.updateProject(project);
      final dto = ProjectDTO.fromDomain(project);
      await _localDataSource.cacheProject(dto);
      return Right(unit);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to update project: \\${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(UniqueId id) async {
    try {
      await _remoteDataSource.deleteProject(id);
      await _localDataSource.removeCachedProject(id);
      return Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete project: ${e.toString()}'));
    }
  }

  // watching projects stream
  @override
  Stream<Either<Failure, List<Project>>> watchAllProjects(UserId ownerId) {
    return _localDataSource
        .watchAllProjects(ownerId)
        .map(
          (projects) =>
              Right(projects.map((project) => project.toDomain()).toList()),
        );
  }

  @override
  Future<Either<Failure, Unit>> addCollaborator({
    required UniqueId projectId,
    required UserId userId,
  }) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }
    return await _remoteDataSource.addCollaboratorWithIdProject(
      projectId: projectId.value,
      userId: userId.value,
    );
  }

  @override
  Future<Either<Failure, Project>> joinProjectWithId({
    required UniqueId projectId,
    required UserId userId,
  }) async {
    final hasConnected = await _networkInfo.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('No internet connection'));
    }

    // Obtener el proyecto remoto
    final projectOrFailure = await _remoteDataSource.getProjectById(
      projectId.value,
    );

    return projectOrFailure.fold((failure) => Left(failure), (project) async {
      final projectDTO = ProjectDTO.fromDomain(project);
      await _localDataSource.cacheProject(projectDTO);

      // Agregar el colaborador
      final addCollaboratorResult = await _remoteDataSource
          .addCollaboratorWithIdProject(
            projectId: projectId.value,
            userId: userId.value,
          );
      return addCollaboratorResult.fold(
        (failure) => Left(failure),
        (_) => Right(project),
      );
    });
  }
}

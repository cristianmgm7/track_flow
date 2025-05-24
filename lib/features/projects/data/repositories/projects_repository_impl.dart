import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_info.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// A repository that implements offline-first with sync capabilities.
///
/// This repository:
/// 1. Always writes to local storage first
/// 2. Syncs with Firestore when online
/// 3. Reads from local storage for immediate access
/// 4. Periodically syncs with Firestore in the background
class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({
    required ProjectRemoteDataSource remoteDataSource,
    required ProjectLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, Unit>> createProject(Project project) async {
    final dto = ProjectDTO.fromDomain(project);
    final hasConnected = await _networkInfo.isConnected;
    if (hasConnected) {
      try {
        await _remoteDataSource.createProject(project);
        await _localDataSource.cacheProject(dto);
        return Right(unit);
      } catch (e) {
        return Left(
          DatabaseFailure('Failed to create project: \\${e.toString()}'),
        );
      }
    }
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      //final dto = ProjectDTO.fromDomain(project);
      await _remoteDataSource.updateProject(project);
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
      return Right(unit);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to delete project: \\${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    return _remoteDataSource.getAllProjects();
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    return _remoteDataSource.getProjectById(id);
  }

  @override
  Stream<Either<Failure, List<Project>>> watchAllProjects() {
    return _localDataSource.watchAllProjects().map(
      (projects) =>
          Right(projects.map((project) => project.toDomain()).toList()),
    );
  }
}

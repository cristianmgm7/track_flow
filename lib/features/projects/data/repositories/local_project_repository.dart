import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// Implementation of [ProjectRepository] using local storage (Hive) as the data source.
class LocalProjectRepository implements ProjectRepository {
  final ProjectLocalDataSource _localDataSource;

  LocalProjectRepository({ProjectLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? HiveProjectLocalDataSource();

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final dto = ProjectDTO.fromEntity(project);
      await _localDataSource.cacheProject(dto);
      return Right(project);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to create project locally: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      final dto = ProjectDTO.fromEntity(project);
      await _localDataSource.cacheProject(dto);
      return Right(project);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to update project locally: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      await _localDataSource.removeCachedProject(projectId);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to delete project locally: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String projectId) async {
    try {
      final dto = await _localDataSource.getCachedProject(projectId);
      if (dto == null) {
        return Left(DatabaseFailure(message: 'Project not found locally'));
      }
      return Right(dto.toEntity());
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to get project locally: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjects(String userId) {
    try {
      return Right(
        Stream.fromFuture(
          _localDataSource.getCachedProjects(userId),
        ).map((dtos) => dtos.map((dto) => dto.toEntity()).toList()),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to get user projects locally: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjectsByStatus(
    String userId,
    String status,
  ) {
    try {
      return Right(
        Stream.fromFuture(
          _localDataSource.getCachedProjectsByStatus(userId, status),
        ).map((dtos) => dtos.map((dto) => dto.toEntity()).toList()),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to get projects by status locally: ${e.toString()}',
        ),
      );
    }
  }
}

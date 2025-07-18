import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import '../models/project_dto.dart';

abstract class ProjectsLocalDataSource {
  Future<Either<Failure, Unit>> cacheProject(ProjectDTO project);

  Future<Either<Failure, ProjectDTO?>> getCachedProject(String projectId);

  Future<Either<Failure, Unit>> removeCachedProject(String projectId);

  Future<Either<Failure, List<ProjectDTO>>> getAllProjects();

  Stream<Either<Failure, List<ProjectDTO>>> watchAllProjects(String ownerId);

  Future<Either<Failure, Unit>> clearCache();
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  final Isar _isar;

  ProjectsLocalDataSourceImpl(this._isar);

  @override
  Future<Either<Failure, Unit>> cacheProject(ProjectDTO project) async {
    try {
      print(
        'ProjectsLocalDataSource: Caching project: ${project.name} (${project.id})',
      );
      final projectDoc = ProjectDocument.fromDTO(project);
      await _isar.writeTxn(() async {
        await _isar.projectDocuments.put(projectDoc);
      });
      print(
        'ProjectsLocalDataSource: Successfully cached project: ${project.name}',
      );
      return const Right(unit);
    } catch (e) {
      print('ProjectsLocalDataSource: Failed to cache project: $e');
      return Left(CacheFailure('Failed to cache project: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectDTO?>> getCachedProject(
    String projectId,
  ) async {
    try {
      final projectDoc = await _isar.projectDocuments.get(fastHash(projectId));
      return Right(projectDoc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached project: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeCachedProject(String projectId) async {
    try {
      await _isar.writeTxn(() async {
        final projectDoc = await _isar.projectDocuments.get(
          fastHash(projectId),
        );
        if (projectDoc != null) {
          projectDoc.isDeleted = true;
          await _isar.projectDocuments.put(projectDoc);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to remove cached project: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProjectDTO>>> getAllProjects() async {
    try {
      final projectDocs = await _isar.projectDocuments.where().findAll();
      return Right(projectDocs.map((doc) => doc.toDTO()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get all projects: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ProjectDTO>>> watchAllProjects(String ownerId) {
    return _isar.projectDocuments
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (q) => q
              .ownerIdEqualTo(ownerId)
              .or()
              .collaboratorIdsElementEqualTo(ownerId),
        )
        .watch(fireImmediately: true)
        .map(
          (docs) => right<Failure, List<ProjectDTO>>(
            docs.map((doc) => doc.toDTO()).toList(),
          ),
        )
        .handleError((e) => left(CacheFailure('Failed to watch projects: $e')));
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      print('ProjectsLocalDataSource: Clearing cache...');
      await _isar.writeTxn(() async {
        await _isar.projectDocuments.clear();
      });
      print('ProjectsLocalDataSource: Cache cleared.');
      return const Right(unit);
    } catch (e) {
      print('ProjectsLocalDataSource: Failed to clear cache: $e');
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }
}

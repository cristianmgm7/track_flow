import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import '../models/project_dto.dart';

abstract class ProjectsLocalDataSource {
  Future<Either<Failure, Unit>> cacheProject(ProjectDTO project);

  Future<Either<Failure, ProjectDTO?>> getCachedProject(String projectId);

  Future<Either<Failure, Unit>> removeCachedProject(String projectId);

  Future<Either<Failure, List<ProjectDTO>>> getAllProjects();

  Stream<Either<Failure, List<ProjectDTO>>> watchAllProjects(String ownerId);

  Stream<Either<Failure, ProjectDTO?>> watchProjectById(String projectId);

  Future<Either<Failure, Unit>> clearCache();
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  final Isar _isar;

  ProjectsLocalDataSourceImpl(this._isar);

  @override
  Future<Either<Failure, Unit>> cacheProject(ProjectDTO project) async {
    try {
      AppLogger.database(
        'Caching project: ${project.name} (${project.id})',
        table: 'projects',
      );
      final projectDoc = ProjectDocument.fromDTO(project);
      await _isar.writeTxn(() async {
        await _isar.projectDocuments.put(projectDoc);
      });
      AppLogger.database(
        'Successfully cached project: ${project.name}',
        table: 'projects',
      );
      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'Failed to cache project: $e',
        tag: 'ProjectsLocalDataSource',
      );
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
  Stream<Either<Failure, ProjectDTO?>> watchProjectById(String projectId) {
    try {
      // Watch a single project document by its id
      return _isar.projectDocuments
          .watchObject(fastHash(projectId), fireImmediately: true)
          .map((doc) => right<Failure, ProjectDTO?>(doc?.toDTO()))
          .handleError(
            (e) => left<Failure, ProjectDTO?>(
              CacheFailure('Failed to watch project: $e'),
            ),
          );
    } catch (e) {
      return Stream.value(left(CacheFailure('Failed to watch project: $e')));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      AppLogger.database('Clearing cache...', table: 'projects');
      await _isar.writeTxn(() async {
        await _isar.projectDocuments.clear();
      });
      AppLogger.database('Cache cleared.', table: 'projects');
      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'Failed to clear cache: $e',
        tag: 'ProjectsLocalDataSource',
      );
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }
}

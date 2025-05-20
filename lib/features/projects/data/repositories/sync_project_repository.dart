import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// A repository that implements offline-first with sync capabilities.
///
/// This repository:
/// 1. Always writes to local storage first
/// 2. Syncs with Firestore when online
/// 3. Reads from local storage for immediate access
/// 4. Periodically syncs with Firestore in the background
class SyncProjectRepository implements ProjectRepository {
  SyncProjectRepository({ProjectRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? FirestoreProjectDataSource();

  final ProjectRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Unit>> createProject(Project project) async {
    try {
      //final dto = ProjectDTO.fromDomain(project);
      await _remoteDataSource.createProject(project);
      return Right(unit);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to create project: \\${e.toString()}'),
      );
    }
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
}

/// Represents the status of the sync operation
enum SyncStatusType { syncing, synced, error }

class SyncStatus {
  final SyncStatusType type;
  final String? error;
  const SyncStatus.syncing() : type = SyncStatusType.syncing, error = null;
  const SyncStatus.synced() : type = SyncStatusType.synced, error = null;
  const SyncStatus.error(this.error) : type = SyncStatusType.error;
}

/// Represents a sync operation to be performed
class SyncOperation {
  final SyncOperationType type;
  final Project? project;
  final String? projectId;

  const SyncOperation.create(this.project)
    : type = SyncOperationType.create,
      projectId = null;

  const SyncOperation.update(this.project)
    : type = SyncOperationType.update,
      projectId = null;

  const SyncOperation.delete(this.projectId)
    : type = SyncOperationType.delete,
      project = null;
}

enum SyncOperationType { create, update, delete }

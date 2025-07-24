import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
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
  final NetworkStateManager _networkStateManager;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  ProjectsRepositoryImpl({
    required ProjectRemoteDataSource remoteDataSource,
    required ProjectsLocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkStateManager = networkStateManager,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final projectDto = ProjectDTO.fromDomain(project);

      // 1. ALWAYS save locally first (ignore minor cache errors)
      await _localDataSource.cacheProject(projectDto);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addCreateOperation(
        entityType: 'project',
        entityId: project.id.value,
        data: projectDto.toMap(), // Use complete DTO data
        priority: SyncPriority.high,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        // ❌ CRITICAL: Failed to queue - this is a serious issue
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync (no condition check - coordinator handles it)
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_create',
        ),
      );

      // 5. Return success only after successful queue
      return Right(project);
    } catch (e) {
      // Only fail for critical storage errors (disk full, etc.)
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      final projectDto = ProjectDTO.fromDomain(project);

      // 1. ALWAYS update locally first
      await _localDataSource.cacheProject(projectDto);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: 'project',
        entityId: project.id.value,
        data: projectDto.toMap(),
        priority: SyncPriority.medium,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_update',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(ProjectId projectId) async {
    try {
      // 1. ALWAYS soft delete locally first
      await _localDataSource.removeCachedProject(projectId.value);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addDeleteOperation(
        entityType: 'project',
        entityId: projectId.value,
        priority: SyncPriority.medium,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_delete',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    try {
      // 1. ALWAYS try local cache first
      final localResult = await _localDataSource.getCachedProject(
        projectId.value,
      );

      final localProject = localResult.fold(
        (failure) => null,
        (projectDto) => projectDto?.toDomain(),
      );

      // 2. If found locally, return it and trigger background refresh
      if (localProject != null) {
        // Trigger background sync for fresh data (non-blocking)
        unawaited(
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'project_${projectId.value}',
          ),
        );

        return Right(localProject);
      }

      // 3. Not found locally - trigger background fetch and return not found
      // This is offline-first: we don't block waiting for network
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'project_${projectId.value}',
        ),
      );

      // Return "not found locally" instead of network error
      return Left(DatabaseFailure('Project not found in local cache'));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<Project>>> watchLocalProjects(UserId ownerId) {
    // Trigger background sync when method is called
    unawaited(
      _backgroundSyncCoordinator.triggerBackgroundSync(
        syncKey: 'projects_${ownerId.value}',
      ),
    );

    return _localDataSource
        .watchAllProjects(ownerId.value)
        .map((either) {
          // Always return local data immediately (even if empty)
          return either.map(
            (projects) =>
                projects.map((project) => project.toDomain()).toList(),
          );
        })
        .handleError((error) {
          // Handle stream errors gracefully
          return left<Failure, List<Project>>(
            DatabaseFailure('Local projects stream error: $error'),
          );
        });
  }
}

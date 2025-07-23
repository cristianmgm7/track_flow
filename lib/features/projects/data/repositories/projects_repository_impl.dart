import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/background_sync_coordinator.dart';
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
      // 1. OFFLINE-FIRST: Save locally IMMEDIATELY
      final projectDto = ProjectDTO.fromDomain(project);
      final cacheResult = await _localDataSource.cacheProject(projectDto);
      
      if (cacheResult.isLeft()) {
        return cacheResult.fold(
          (failure) => Left(failure),
          (_) => Right(project), // This won't execute but needed for type
        );
      }
      
      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'project',
        entityId: project.id.value,
        operationType: 'create',
        priority: SyncPriority.high,
        data: {
          'name': project.name,
          'description': project.description,
          'ownerId': project.ownerId.value,
          'createdAt': project.createdAt.toIso8601String(),
        },
      );
      
      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_create',
        );
      }
      
      return Right(project); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to create project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      // 1. OFFLINE-FIRST: Update locally IMMEDIATELY
      final projectDto = ProjectDTO.fromDomain(project);
      final cacheResult = await _localDataSource.cacheProject(projectDto);
      
      if (cacheResult.isLeft()) {
        return cacheResult.fold(
          (failure) => Left(failure),
          (_) => Right(unit), // This won't execute but needed for type
        );
      }
      
      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'project',
        entityId: project.id.value,
        operationType: 'update',
        priority: SyncPriority.medium,
        data: {
          'name': project.name,
          'description': project.description,
          'ownerId': project.ownerId.value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_update',
        );
      }
      
      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to update project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(ProjectId projectId) async {
    try {
      // 1. OFFLINE-FIRST: Delete locally IMMEDIATELY (soft delete with sync metadata)
      final deleteResult = await _localDataSource.removeCachedProject(projectId.value);
      
      if (deleteResult.isLeft()) {
        return deleteResult.fold(
          (failure) => Left(failure),
          (_) => Right(unit), // This won't execute but needed for type
        );
      }
      
      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'project',
        entityId: projectId.value,
        operationType: 'delete',
        priority: SyncPriority.medium,
        data: {},
      );
      
      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'projects_delete',
        );
      }
      
      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(ProjectId projectId) async {
    // 1. Try to get from local cache first (cache-aside pattern)
    final localResult = await _localDataSource.getCachedProject(projectId.value);
    
    // 2. Return local data if available
    final localProject = localResult.fold(
      (failure) => null,
      (projectDto) => projectDto?.toDomain(),
    );
    
    if (localProject != null) {
      // 3. Trigger background sync for fresh data (non-blocking)
      _backgroundSyncCoordinator.triggerBackgroundSync(
        syncKey: 'project_${projectId.value}',
      );
      
      return Right(localProject);
    }
    
    // 4. If not in cache and we have network, fetch from remote
    final hasConnected = await _networkStateManager.isConnected;
    if (!hasConnected) {
      return Left(DatabaseFailure('Project not found in cache and no internet connection'));
    }
    
    // 5. Fetch from remote and cache result
    final remoteResult = await _remoteDataSource.getProjectById(projectId.value);
    return remoteResult.fold(
      (failure) => Left(failure),
      (project) async {
        // Cache the project for future offline access
        await _localDataSource.cacheProject(project);
        return Right(project.toDomain());
      },
    );
  }

  // watching projects stream - Cache-aside pattern implementation
  @override
  Stream<Either<Failure, List<Project>>> watchLocalProjects(UserId ownerId) {
    return _localDataSource
        .watchAllProjects(ownerId.value)
        .asyncMap((either) async {
          // 1. Always return local data immediately (even if empty)
          final result = either.map(
            (projects) => projects.map((project) => project.toDomain()).toList(),
          );
          
          // 2. Trigger background sync for fresh data (non-blocking)
          // This will update the cache and the stream will emit new data
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'projects_${ownerId.value}',
          );
          
          return result;
        });
  }
}

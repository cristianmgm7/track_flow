import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/background_sync_coordinator.dart';
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

  ProjectsRepositoryImpl({
    required ProjectRemoteDataSource remoteDataSource,
    required ProjectsLocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkStateManager = networkStateManager,
       _backgroundSyncCoordinator = backgroundSyncCoordinator;

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final hasConnected = await _networkStateManager.isConnected;
      
      if (hasConnected) {
        // Online: Create on remote and cache locally
        final result = await _remoteDataSource.createProject(
          ProjectDTO.fromDomain(project),
        );
        return result.fold(
          (failure) => Left(failure), 
          (projectWithId) async {
            await _localDataSource.cacheProject(projectWithId);
            return Right(projectWithId.toDomain());
          }
        );
      } else {
        // Offline: Cache locally with pending sync flag
        // TODO: Add sync metadata for offline operations
        final projectDto = ProjectDTO.fromDomain(project);
        final cacheResult = await _localDataSource.cacheProject(projectDto);
        return cacheResult.fold(
          (failure) => Left(failure),
          (unit) => Right(project),
        );
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to create project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      final hasConnected = await _networkStateManager.isConnected;
      
      // Always cache locally first for immediate UI updates
      final projectDto = ProjectDTO.fromDomain(project);
      await _localDataSource.cacheProject(projectDto);
      
      if (hasConnected) {
        // Online: Sync to remote immediately
        try {
          await _remoteDataSource.updateProject(projectDto);
        } catch (e) {
          // If remote update fails, keep local changes and trigger background sync
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'update_project_${project.id.value}',
          );
        }
      } else {
        // Offline: Mark for sync when connection is restored
        // TODO: Add sync metadata for offline operations
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'update_project_${project.id.value}',
        );
      }
      
      return Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update project: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(ProjectId projectId) async {
    try {
      final hasConnected = await _networkStateManager.isConnected;
      
      if (hasConnected) {
        // Online: Delete from remote first, then local
        try {
          await _remoteDataSource.deleteProject(projectId.value);
          await _localDataSource.removeCachedProject(projectId.value);
        } catch (e) {
          // If remote delete fails, mark for background sync
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'delete_project_${projectId.value}',
          );
          rethrow; // Re-throw to indicate failure
        }
      } else {
        // Offline: Mark as deleted locally, sync when online
        // TODO: Implement soft delete with sync metadata
        await _localDataSource.removeCachedProject(projectId.value);
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'delete_project_${projectId.value}',
        );
      }
      
      return Right(unit);
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

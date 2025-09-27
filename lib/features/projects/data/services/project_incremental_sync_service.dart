import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

/// 🎯 TRUE INCREMENTAL PROJECT SYNC SERVICE
///
/// Implements the IncrementalSyncService interface for proper incremental sync.
/// This replaces the old "smart sync" that was actually full sync with local filtering.
///
/// ✅ TRUE INCREMENTAL: Only fetches modified data from remote
/// ✅ EFFICIENT: Uses timestamp-based queries
/// ✅ RELIABLE: Proper error handling and fallbacks
@LazySingleton()
class ProjectIncrementalSyncService
    implements IncrementalSyncService<ProjectDTO> {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;

  ProjectIncrementalSyncService(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, List<ProjectDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'PROJECTS',
        'Fetching projects modified since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      final result = await _remoteDataSource.getUserProjectsModifiedSince(
        lastSyncTime,
        userId,
      );

      return result.fold((failure) => Left(failure), (modifiedProjects) {
        AppLogger.sync(
          'PROJECTS',
          'Found ${modifiedProjects.length} modified projects',
          syncKey: userId,
        );
        return Right(modifiedProjects);
      });
    } catch (e) {
      AppLogger.error(
        'Failed to get modified projects: $e',
        tag: 'ProjectIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to get modified projects: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      final result = await _remoteDataSource.hasUserProjectsModifiedSince(
        lastSyncTime,
        userId,
      );

      return result.fold((failure) => Left(failure), (hasModified) {
        AppLogger.sync(
          'PROJECTS',
          'Has modified projects since ${lastSyncTime.toIso8601String()}: $hasModified',
          syncKey: userId,
        );
        return Right(hasModified);
      });
    } catch (e) {
      AppLogger.error(
        'Failed to check for modified projects: $e',
        tag: 'ProjectIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to check for modified projects: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    // For Firestore, we can use a server timestamp approximation
    // In a real implementation, you might want a dedicated endpoint
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    // For now, return empty - can be implemented if metadata-only queries are needed
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    // TODO: Implement when soft deletes are tracked
    // This would require a separate collection for deleted items
    return const Right([]);
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<ProjectDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'PROJECTS',
        'Starting incremental sync from ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // 1. Get modified projects
      final modifiedResult = await getModifiedSince(lastSyncTime, userId);
      if (modifiedResult.isLeft()) {
        return modifiedResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final modifiedProjects = modifiedResult.getOrElse(() => []);

      // 2. Get deleted projects (placeholder for now)
      final deletedResult = await getDeletedSince(lastSyncTime, userId);
      if (deletedResult.isLeft()) {
        return deletedResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final deletedIds = deletedResult.getOrElse(() => []);

      // 3. Update local cache
      await _updateLocalCache(modifiedProjects, deletedIds);

      // 4. Get server timestamp for next sync
      final serverTimestamp = DateTime.now().toUtc();

      final result = IncrementalSyncResult(
        modifiedItems: modifiedProjects,
        deletedItemIds: deletedIds,
        serverTimestamp: serverTimestamp,
        totalProcessed: modifiedProjects.length + deletedIds.length,
      );

      AppLogger.sync(
        'PROJECTS',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'ProjectIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<ProjectDTO>>> performFullSync(
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'PROJECTS',
        'Starting full sync fallback',
        syncKey: userId,
      );

      // Get all projects as fallback
      final allProjectsResult = await _remoteDataSource.getUserProjects(userId);
      if (allProjectsResult.isLeft()) {
        return allProjectsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final allProjects = allProjectsResult.getOrElse(() => []);

      // Clear and replace local cache
      await _localDataSource.clearCache();
      for (final project in allProjects) {
        await _localDataSource.cacheProject(project);
      }

      final result = IncrementalSyncResult(
        modifiedItems: allProjects,
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        wasFullSync: true,
        totalProcessed: allProjects.length,
      );

      AppLogger.sync(
        'PROJECTS',
        'Full sync completed: ${allProjects.length} projects',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Full sync failed: $e',
        tag: 'ProjectIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Full sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    try {
      final localResult = await _localDataSource.getAllProjects();
      final projects = localResult.fold(
        (failure) => <ProjectDTO>[],
        (projects) => projects,
      );

      return Right({
        'userId': userId,
        'totalProjects': projects.length,
        'activeProjects': projects.where((p) => !p.isDeleted).length,
        'syncStrategy': 'true_incremental_with_fallback',
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }

  /// Update local cache with modified and deleted projects
  Future<void> _updateLocalCache(
    List<ProjectDTO> modifiedProjects,
    List<String> deletedIds,
  ) async {
    // Update modified projects
    for (final project in modifiedProjects) {
      await _localDataSource.cacheProject(project);
    }

    // Remove deleted projects
    for (final id in deletedIds) {
      await _localDataSource.removeCachedProject(id);
    }
  }
}

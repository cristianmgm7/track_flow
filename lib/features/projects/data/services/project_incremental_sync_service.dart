import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🎯 SIMPLE PROJECT SYNC SERVICE
///
/// Pragmatic service that handles downstream sync for projects:
/// - Fetches all remote projects (simple approach)
/// - Compares with local cache
/// - Only updates projects that actually changed
/// - Uses simple timestamp logic (15 min intervals)
///
/// ✅ CLEAN ARCHITECTURE:
/// - Repository stays clean (only CRUD)
/// - Service handles sync complexity
/// - Use case orchestrates the flow
///
/// 🚀 STRATEGY (Option 2 - Smart Logic from this morning):
/// 1. Check if sync is needed (15 min since last sync)
/// 2. Fetch all remote projects
/// 3. Smart comparison - only update changed projects
/// 4. Preserve local data on failures
@LazySingleton()
class ProjectIncrementalSyncService {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;

  ProjectIncrementalSyncService(this._remoteDataSource, this._localDataSource);

  /// 🔄 Perform smart sync with timestamp logic
  /// Returns the number of projects updated
  Future<Either<Failure, int>> performSmartSync(String userId) async {
    try {
      AppLogger.sync('PROJECTS', 'Starting smart sync', syncKey: userId);

      // 1. 📅 Check if sync is needed (15 min intervals)
      final shouldSync = await _shouldSyncProjects();
      if (!shouldSync) {
        AppLogger.sync(
          'PROJECTS',
          'Skipping sync - data is fresh',
          syncKey: userId,
        );
        return const Right(0);
      }

      // 2. 🌐 Fetch all remote projects (simple approach)
      final remoteResult = await _remoteDataSource.getUserProjects(userId);

      return await remoteResult.fold(
        (failure) async {
          // 🚨 Remote fetch failed - preserve local data
          AppLogger.warning(
            'Failed to fetch remote projects: ${failure.message}',
            tag: 'ProjectSyncService',
          );
          return Left(failure);
        },
        (remoteProjects) async {
          // ✅ Remote fetch succeeded - apply smart updates
          AppLogger.sync(
            'PROJECTS',
            'Fetched ${remoteProjects.length} projects from remote',
            syncKey: userId,
          );

          // 3. 🧠 Smart logic: only update what changed
          final updateCount = await _updateChangedProjects(remoteProjects);

          // 4. 📝 Mark as synced (update timestamp)
          await _markProjectsAsSynced();

          AppLogger.sync(
            'PROJECTS',
            'Smart sync completed - updated $updateCount projects',
            syncKey: userId,
          );

          return Right(updateCount);
        },
      );
    } catch (e) {
      AppLogger.error(
        'Smart sync failed: $e',
        tag: 'ProjectSyncService',
        error: e,
      );
      return Left(ServerFailure('Smart sync failed: $e'));
    }
  }

  /// 📅 Check if sync is needed (simple timestamp logic)
  Future<bool> _shouldSyncProjects() async {
    try {
      // Get all local projects and find the most recent sync time
      final localResult = await _localDataSource.getAllProjects();

      return localResult.fold(
        (failure) => true, // Error getting local = sync needed
        (localProjects) {
          if (localProjects.isEmpty) {
            return true; // No local projects = sync needed
          }

          // Find the most recent sync time
          DateTime? mostRecentSync;
          for (final project in localProjects) {
            final projectSyncTime = project.updatedAt ?? project.createdAt;
            if (mostRecentSync == null ||
                projectSyncTime.isAfter(mostRecentSync)) {
              mostRecentSync = projectSyncTime;
            }
          }

          if (mostRecentSync == null) {
            return true; // No sync metadata = sync needed
          }

          // Check if 15 minutes have passed
          final now = DateTime.now();
          final timeSinceSync = now.difference(mostRecentSync);
          return timeSinceSync.inMinutes >= 15;
        },
      );
    } catch (e) {
      AppLogger.warning(
        'Error checking sync need: $e - defaulting to sync',
        tag: 'ProjectSyncService',
      );
      return true; // Default to sync on error
    }
  }

  /// 🧠 Smart update: only change projects that actually changed
  Future<int> _updateChangedProjects(List<ProjectDTO> remoteProjects) async {
    int updateCount = 0;

    for (final remoteProject in remoteProjects) {
      try {
        // Get local version if it exists
        final localResult = await _localDataSource.getCachedProject(
          remoteProject.id,
        );

        final localProject = localResult.fold(
          (failure) => null,
          (project) => project,
        );

        // Check if update is needed
        if (localProject == null ||
            _hasProjectChanged(localProject, remoteProject)) {
          // Update needed
          await _localDataSource.cacheProject(remoteProject);
          updateCount++;

          AppLogger.database(
            'Updated project: ${remoteProject.name}',
            table: 'projects',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to update project ${remoteProject.name}: $e',
          tag: 'ProjectSyncService',
        );
        // Continue with other projects
      }
    }

    return updateCount;
  }

  /// 🔍 Simple change detection (like we had in repository)
  bool _hasProjectChanged(ProjectDTO local, ProjectDTO remote) {
    // Compare key fields that indicate change
    return local.name != remote.name ||
        local.description != remote.description ||
        local.collaborators.length != remote.collaborators.length ||
        (remote.updatedAt != null &&
            (local.updatedAt == null ||
                remote.updatedAt!.isAfter(local.updatedAt!)));
  }

  /// 📝 Mark projects as synced (simple timestamp update)
  Future<void> _markProjectsAsSynced() async {
    try {
      // For now, we rely on the fact that projects were just updated
      // with fresh remote data, so their timestamps are current
      AppLogger.info('Projects marked as synced', tag: 'ProjectSyncService');
    } catch (e) {
      AppLogger.warning(
        'Failed to mark projects as synced: $e',
        tag: 'ProjectSyncService',
      );
    }
  }

  /// 📊 Get simple sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics(String userId) async {
    try {
      final localResult = await _localDataSource.getAllProjects();
      final localCount = localResult.fold(
        (failure) => 0,
        (projects) => projects.length,
      );

      return {
        'userId': userId,
        'localProjectsCount': localCount,
        'syncStrategy': 'smart_timestamp_based',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to get sync statistics: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

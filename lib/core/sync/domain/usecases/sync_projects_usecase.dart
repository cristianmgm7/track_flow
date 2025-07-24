import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/session/data/session_storage.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 📋 SIMPLE PROJECTS SYNC USE CASE
///
/// Synchronizes projects from remote to local cache using a simple,
/// non-destructive approach with smart change detection.
///
/// STRATEGY (Option 2 - Smart Logic):
/// 1. 📅 CHECK: Use SyncMetadata timestamps to determine if sync needed
/// 2. 🌐 FETCH: Get all user projects using existing method
/// 3. 🧠 SMART: Only update projects that actually changed
/// 4. 💾 PRESERVE: Never clear cache until we have new data
/// 5. ⚡ EFFICIENT: Skip sync if data is fresh (15 min interval)
@lazySingleton
class SyncProjectsUseCase {
  final ProjectRemoteDataSource _remote;
  final ProjectsLocalDataSource _local;
  final SessionStorage _sessionStorage;
  final Isar _isar;

  SyncProjectsUseCase(
    this._remote,
    this._local,
    this._sessionStorage,
    this._isar,
  );

  /// 🚀 Execute projects synchronization with smart logic
  /// Uses existing getUserProjects() method with intelligent change detection
  Future<void> call() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      AppLogger.warning(
        'No user ID available - skipping projects sync',
        tag: 'SyncProjectsUseCase',
      );
      return;
    }

    // 1. 📅 Check if sync is needed based on interval
    final shouldSync = await _shouldSyncProjects();
    if (!shouldSync) {
      AppLogger.sync(
        'PROJECTS',
        'Skipping sync - data is fresh (< 15 min)',
        syncKey: userId,
      );
      return;
    }

    AppLogger.sync('PROJECTS', 'Starting smart projects sync', syncKey: userId);
    final startTime = DateTime.now();

    try {
      // 2. 🌐 Fetch all projects from remote (using existing method)
      final projectsResult = await _remote.getUserProjects(userId);

      await projectsResult.fold(
        (failure) async {
          // 🚨 Remote fetch failed - preserve local data
          AppLogger.warning(
            'Failed to fetch projects from remote: ${failure.message}',
            tag: 'SyncProjectsUseCase',
          );
          // DON'T clear local cache - preserve existing data
        },
        (remoteProjects) async {
          // ✅ Remote fetch succeeded - apply smart updates
          AppLogger.sync(
            'PROJECTS',
            'Fetched ${remoteProjects.length} projects from remote',
            syncKey: userId,
          );

          // 3. 🧠 Smart logic: only update what actually changed
          final updateCount = await _updateChangedProjects(remoteProjects);

          // 4. 📝 Update sync timestamp on success
          await _updateSyncTimestamp();

          final duration = DateTime.now().difference(startTime);
          AppLogger.sync(
            'PROJECTS',
            'Smart sync completed - updated $updateCount projects',
            syncKey: userId,
            duration: duration.inMilliseconds,
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error during projects sync: $e',
        tag: 'SyncProjectsUseCase',
        error: e,
      );
      // Don't rethrow - this is a background operation
    }
  }

  /// 📅 Check if projects sync is needed based on timestamp interval
  Future<bool> _shouldSyncProjects() async {
    try {
      // Get all projects and find the most recently synced one
      final allProjects = await _isar.projectDocuments.where().findAll();

      DateTime? lastSyncTime;
      if (allProjects.isNotEmpty) {
        // Find the most recent sync time among all projects
        for (final project in allProjects) {
          final projectSyncTime = project.syncMetadata.lastSyncTime;
          if (projectSyncTime != null) {
            if (lastSyncTime == null || projectSyncTime.isAfter(lastSyncTime)) {
              lastSyncTime = projectSyncTime;
            }
          }
        }
      }

      if (lastSyncTime == null) {
        // Never synced before - definitely need sync
        return true;
      }

      // Check if 15 minutes have passed since last sync
      final now = DateTime.now();
      final timeSinceSync = now.difference(lastSyncTime);

      return timeSinceSync.inMinutes >= 15; // 15 minute interval
    } catch (e) {
      AppLogger.warning(
        'Error checking sync timestamp: $e - defaulting to sync',
        tag: 'SyncProjectsUseCase',
      );
      return true; // Default to sync on error
    }
  }

  /// 🧠 Smart update: only modify projects that actually changed
  Future<int> _updateChangedProjects(List<ProjectDTO> remoteProjects) async {
    int updateCount = 0;

    for (final remoteProject in remoteProjects) {
      try {
        // Get local version if it exists
        final localResult = await _local.getCachedProject(remoteProject.id);
        final localProject = localResult.fold(
          (failure) => null,
          (project) => project,
        );

        // Check if update is needed
        if (localProject == null ||
            _hasProjectChanged(localProject, remoteProject)) {
          // Update needed - create document with sync metadata
          await _isar.writeTxn(() async {
            final doc = ProjectDocument.fromRemoteDTO(
              remoteProject,
              version: 1,
              lastModified: remoteProject.updatedAt ?? remoteProject.createdAt,
            );
            doc.syncMetadata.markAsSynced();
            await _isar.projectDocuments.put(doc);
          });

          updateCount++;

          AppLogger.database(
            'Updated project: ${remoteProject.name}',
            table: 'projects',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to update project ${remoteProject.name}: $e',
          tag: 'SyncProjectsUseCase',
        );
        // Continue with other projects
      }
    }

    return updateCount;
  }

  /// 🔍 Check if remote project is different from local version
  bool _hasProjectChanged(ProjectDTO local, ProjectDTO remote) {
    // Compare key fields that indicate changes
    return local.name != remote.name ||
        local.description != remote.description ||
        local.updatedAt != remote.updatedAt ||
        !_listsEqual(local.collaboratorIds, remote.collaboratorIds);
  }

  /// Helper to compare lists for equality
  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 📝 Update sync timestamp for projects
  Future<void> _updateSyncTimestamp() async {
    try {
      // Update timestamp on any existing project (they all sync together)
      final anyProject = await _isar.projectDocuments.where().findFirst();

      if (anyProject != null) {
        await _isar.writeTxn(() async {
          anyProject.syncMetadata.markAsSynced();
          await _isar.projectDocuments.put(anyProject);
        });
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to update sync timestamp: $e',
        tag: 'SyncProjectsUseCase',
      );
    }
  }

  /// 📊 Get sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      final userId = await _sessionStorage.getUserId();
      if (userId == null) {
        return {'error': 'No user ID available'};
      }

      final localResult = await _local.getAllProjects();
      final localCount = localResult.fold(
        (failure) => 0,
        (projects) => projects.length,
      );

      // Get last sync time from any project
      final allProjects = await _isar.projectDocuments.where().findAll();
      DateTime? lastSync;

      for (final project in allProjects) {
        final projectSyncTime = project.syncMetadata.lastSyncTime;
        if (projectSyncTime != null) {
          if (lastSync == null || projectSyncTime.isAfter(lastSync)) {
            lastSync = projectSyncTime;
          }
        }
      }
      final shouldSync = await _shouldSyncProjects();

      return {
        'userId': userId,
        'localProjectsCount': localCount,
        'lastSyncTime': lastSync?.toIso8601String(),
        'shouldSync': shouldSync,
        'minutesSinceLastSync':
            lastSync != null
                ? DateTime.now().difference(lastSync).inMinutes
                : null,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🎵 TRACK VERSION SYNC SERVICE
///
/// Pragmatic service that handles downstream sync for track versions:
/// - Fetches user projects to get track IDs
/// - Fetches all remote versions for those tracks
/// - Compares with local cache
/// - Only updates versions that actually changed
/// - Uses simple timestamp logic (15 min intervals)
///
/// ✅ CLEAN ARCHITECTURE:
/// - Repository stays clean (only CRUD)
/// - Service handles sync complexity
/// - Use case orchestrates the flow
///
/// 🚀 STRATEGY (Option 2 - Smart Logic):
/// 1. Check if sync is needed (15 min since last sync)
/// 2. Fetch user projects to get track IDs
/// 3. Fetch all remote versions for those tracks
/// 4. Smart comparison - only update changed versions
/// 5. Preserve local data on failures
@LazySingleton()
class TrackVersionIncrementalSyncService {
  final TrackVersionRemoteDataSource _remoteDataSource;
  final TrackVersionLocalDataSource _localDataSource;
  final ProjectRemoteDataSource _projectRemoteDataSource;
  final AudioTrackRemoteDataSource _audioTrackRemoteDataSource;

  TrackVersionIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._projectRemoteDataSource,
    this._audioTrackRemoteDataSource,
  );

  /// 🔄 Perform smart sync with timestamp logic
  /// Returns the number of versions updated
  Future<Either<Failure, int>> performSmartSync(String userId) async {
    try {
      AppLogger.sync('TRACK_VERSIONS', 'Starting smart sync', syncKey: userId);

      // 1. 📅 Check if sync is needed (15 min intervals)
      final shouldSync = await _shouldSyncVersions();
      if (!shouldSync) {
        AppLogger.sync(
          'TRACK_VERSIONS',
          'Skipping sync - data is fresh',
          syncKey: userId,
        );
        return const Right(0);
      }

      // 2. 📋 Get user projects first
      final projectsResult = await _projectRemoteDataSource.getUserProjects(
        userId,
      );

      return await projectsResult.fold(
        (failure) async {
          // 🚨 Failed to get projects - preserve local data
          AppLogger.warning(
            'Failed to fetch user projects: ${failure.message}',
            tag: 'TrackVersionSyncService',
          );
          return Left(failure);
        },
        (projects) async {
          if (projects.isEmpty) {
            AppLogger.sync(
              'TRACK_VERSIONS',
              'No projects found - skipping sync',
              syncKey: userId,
            );
            return const Right(0);
          }

          // 3. 🎵 Get project IDs and fetch track versions
          final projectIds = projects.map((p) => p.id).toList();

          if (projectIds.isEmpty) {
            AppLogger.sync(
              'TRACK_VERSIONS',
              'No projects found - skipping sync',
              syncKey: userId,
            );
            return const Right(0);
          }

          final versionsResult = await _getVersionsForProjects(projectIds);

          return versionsResult.fold((failure) => Left(failure), (
            remoteVersions,
          ) async {
            // ✅ Remote fetch succeeded - apply smart updates
            AppLogger.sync(
              'TRACK_VERSIONS',
              'Fetched ${remoteVersions.length} versions from remote',
              syncKey: userId,
            );

            // 4. 🧠 Smart logic: only update what changed
            final updateCount = await _updateChangedVersions(remoteVersions);

            // 5. 📝 Mark as synced (update timestamp)
            await _markVersionsAsSynced();

            AppLogger.sync(
              'TRACK_VERSIONS',
              'Smart sync completed - updated $updateCount versions',
              syncKey: userId,
            );

            return Right(updateCount);
          });
        },
      );
    } catch (e) {
      AppLogger.error(
        'Smart sync failed: $e',
        tag: 'TrackVersionSyncService',
        error: e,
      );
      return Left(ServerFailure('Smart sync failed: $e'));
    }
  }

  /// 🎵 Get versions for multiple projects
  Future<Either<Failure, List<TrackVersionDTO>>> _getVersionsForProjects(
    List<String> projectIds,
  ) async {
    try {
      final allVersions = <TrackVersionDTO>[];

      // For each project, get all track versions
      for (final projectId in projectIds) {
        // First get tracks for this project
        final tracksResult = await _audioTrackRemoteDataSource
            .getTracksByProjectIds([projectId]);
        final trackIds = tracksResult.map((track) => track.id.value).toList();

        // Then get versions for each track
        for (final trackId in trackIds) {
          final versions = await _remoteDataSource.getVersionsByTrackId(
            trackId,
          );
          allVersions.addAll(versions);
        }
      }

      return Right(allVersions);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch versions for projects: $e'));
    }
  }

  /// 📅 Check if sync is needed (simple timestamp logic)
  Future<bool> _shouldSyncVersions() async {
    try {
      // Get all local versions and find the most recent sync time
      final localResult = await _localDataSource.getAllVersions();

      return localResult.fold(
        (failure) => true, // Error getting local = sync needed
        (localVersions) {
          if (localVersions.isEmpty) {
            return true; // No local versions = sync needed
          }

          // Find the most recent sync time
          DateTime? mostRecentSync;
          for (final version in localVersions) {
            final versionSyncTime = version.lastModified ?? version.createdAt;
            if (mostRecentSync == null ||
                versionSyncTime.isAfter(mostRecentSync)) {
              mostRecentSync = versionSyncTime;
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
        'Error checking version sync need: $e - defaulting to sync',
        tag: 'TrackVersionSyncService',
      );
      return true; // Default to sync on error
    }
  }

  /// 🧠 Smart update: only change versions that actually changed
  Future<int> _updateChangedVersions(
    List<TrackVersionDTO> remoteVersions,
  ) async {
    int updateCount = 0;

    for (final remoteVersion in remoteVersions) {
      try {
        // Get local version if it exists
        final localResult = await _localDataSource.getVersionById(
          remoteVersion.id,
        );
        final localVersion = localResult.fold(
          (failure) => null,
          (version) => version,
        );

        // Check if update is needed
        if (localVersion == null ||
            _hasVersionChanged(localVersion, remoteVersion)) {
          // Update needed
          await _localDataSource.cacheVersion(remoteVersion);
          updateCount++;

          AppLogger.database(
            'Updated version: ${remoteVersion.id}',
            table: 'track_versions',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to update version ${remoteVersion.id}: $e',
          tag: 'TrackVersionSyncService',
        );
        // Continue with other versions
      }
    }

    return updateCount;
  }

  /// 🔍 Simple change detection
  bool _hasVersionChanged(TrackVersionDTO local, TrackVersionDTO remote) {
    // Compare key fields that indicate change
    return local.status != remote.status ||
        local.fileRemoteUrl != remote.fileRemoteUrl ||
        local.durationMs != remote.durationMs ||
        (remote.lastModified != null &&
            (local.lastModified == null ||
                remote.lastModified!.isAfter(local.lastModified!)));
  }

  /// 📝 Mark versions as synced (simple timestamp update)
  Future<void> _markVersionsAsSynced() async {
    try {
      // For now, we rely on the fact that versions were just updated
      // with fresh remote data, so their timestamps are current
      AppLogger.info(
        'Track versions marked as synced',
        tag: 'TrackVersionSyncService',
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to mark versions as synced: $e',
        tag: 'TrackVersionSyncService',
      );
    }
  }

  /// 📊 Get simple sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics(String userId) async {
    try {
      final localResult = await _localDataSource.getAllVersions();
      final localCount = localResult.fold(
        (failure) => 0,
        (versions) => versions.length,
      );

      return {
        'userId': userId,
        'localVersionsCount': localCount,
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

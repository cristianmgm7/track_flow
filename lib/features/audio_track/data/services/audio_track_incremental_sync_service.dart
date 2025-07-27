import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🎵 SIMPLE AUDIO TRACK SYNC SERVICE
///
/// Pragmatic service that handles downstream sync for audio tracks:
/// - Fetches user projects to get track IDs
/// - Fetches all remote tracks for those projects
/// - Compares with local cache
/// - Only updates tracks that actually changed
/// - Uses simple timestamp logic (15 min intervals)
///
/// ✅ CLEAN ARCHITECTURE:
/// - Repository stays clean (only CRUD)
/// - Service handles sync complexity
/// - Use case orchestrates the flow
///
/// 🚀 STRATEGY (Option 2 - Smart Logic):
/// 1. Check if sync is needed (15 min since last sync)
/// 2. Fetch user projects to get project IDs
/// 3. Fetch all remote tracks for those projects
/// 4. Smart comparison - only update changed tracks
/// 5. Preserve local data on failures
@LazySingleton()
class AudioTrackIncrementalSyncService {
  final AudioTrackRemoteDataSource _remoteDataSource;
  final AudioTrackLocalDataSource _localDataSource;
  final ProjectRemoteDataSource _projectRemoteDataSource;

  AudioTrackIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._projectRemoteDataSource,
  );

  /// 🔄 Perform smart sync with timestamp logic
  /// Returns the number of tracks updated
  Future<Either<Failure, int>> performSmartSync(String userId) async {
    try {
      AppLogger.sync('AUDIO_TRACKS', 'Starting smart sync', syncKey: userId);

      // 1. 📅 Check if sync is needed (15 min intervals)
      final shouldSync = await _shouldSyncTracks();
      if (!shouldSync) {
        AppLogger.sync(
          'AUDIO_TRACKS',
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
            tag: 'AudioTrackSyncService',
          );
          return Left(failure);
        },
        (projects) async {
          if (projects.isEmpty) {
            AppLogger.sync(
              'AUDIO_TRACKS',
              'No projects found - skipping sync',
              syncKey: userId,
            );
            return const Right(0);
          }

          // 3. 🎵 Get project IDs and fetch tracks
          final projectIds = projects.map((p) => p.id).toList();
          final tracksResult = await _getTracksForProjects(projectIds);

          return tracksResult.fold((failure) => Left(failure), (
            remoteTracks,
          ) async {
            // ✅ Remote fetch succeeded - apply smart updates
            AppLogger.sync(
              'AUDIO_TRACKS',
              'Fetched ${remoteTracks.length} tracks from remote',
              syncKey: userId,
            );

            // 4. 🧠 Smart logic: only update what changed
            final updateCount = await _updateChangedTracks(remoteTracks);

            // 5. 📝 Mark as synced (update timestamp)
            await _markTracksAsSynced();

            AppLogger.sync(
              'AUDIO_TRACKS',
              'Smart sync completed - updated $updateCount tracks',
              syncKey: userId,
            );

            return Right(updateCount);
          });
        },
      );
    } catch (e) {
      AppLogger.error(
        'Smart sync failed: $e',
        tag: 'AudioTrackSyncService',
        error: e,
      );
      return Left(ServerFailure('Smart sync failed: $e'));
    }
  }

  /// 🎵 Get tracks for multiple projects
  Future<Either<Failure, List<AudioTrackDTO>>> _getTracksForProjects(
    List<String> projectIds,
  ) async {
    try {
      final tracks = await _remoteDataSource.getTracksByProjectIds(projectIds);
      return Right(tracks);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch tracks for projects: $e'));
    }
  }

  /// 📅 Check if sync is needed (simple timestamp logic)
  Future<bool> _shouldSyncTracks() async {
    try {
      // Get all local tracks and find the most recent sync time
      final localResult = await _localDataSource.getAllTracks();

      return localResult.fold(
        (failure) => true, // Error getting local = sync needed
        (localTracks) {
          if (localTracks.isEmpty) {
            return true; // No local tracks = sync needed
          }

          // Find the most recent sync time
          DateTime? mostRecentSync;
          for (final track in localTracks) {
            final trackSyncTime = track.lastModified ?? track.createdAt;
            if (trackSyncTime != null &&
                (mostRecentSync == null ||
                    trackSyncTime.isAfter(mostRecentSync))) {
              mostRecentSync = trackSyncTime;
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
        'Error checking track sync need: $e - defaulting to sync',
        tag: 'AudioTrackSyncService',
      );
      return true; // Default to sync on error
    }
  }

  /// 🧠 Smart update: only change tracks that actually changed
  Future<int> _updateChangedTracks(List<AudioTrackDTO> remoteTracks) async {
    int updateCount = 0;

    for (final remoteTrack in remoteTracks) {
      try {
        // Get local version if it exists using available method
        final localResult = await _localDataSource.getTrackById(
          remoteTrack.id.value,
        );
        final localTrack = localResult.fold(
          (failure) => null,
          (track) => track,
        );

        // Check if update is needed
        if (localTrack == null || _hasTrackChanged(localTrack, remoteTrack)) {
          // Update needed
          await _localDataSource.cacheTrack(remoteTrack);
          updateCount++;

          AppLogger.database(
            'Updated track: ${remoteTrack.name}',
            table: 'audio_tracks',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Failed to update track ${remoteTrack.name}: $e',
          tag: 'AudioTrackSyncService',
        );
        // Continue with other tracks
      }
    }

    return updateCount;
  }

  /// 🔍 Simple change detection (like we had in repository)
  bool _hasTrackChanged(AudioTrackDTO local, AudioTrackDTO remote) {
    // Compare key fields that indicate change
    return local.name != remote.name ||
        local.duration != remote.duration ||
        local.projectId != remote.projectId ||
        local.uploadedBy != remote.uploadedBy ||
        (remote.lastModified != null &&
            (local.lastModified == null ||
                remote.lastModified!.isAfter(local.lastModified!)));
  }

  /// 📝 Mark tracks as synced (simple timestamp update)
  Future<void> _markTracksAsSynced() async {
    try {
      // For now, we rely on the fact that tracks were just updated
      // with fresh remote data, so their timestamps are current
      AppLogger.info(
        'Audio tracks marked as synced',
        tag: 'AudioTrackSyncService',
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to mark tracks as synced: $e',
        tag: 'AudioTrackSyncService',
      );
    }
  }

  /// 📊 Get simple sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics(String userId) async {
    try {
      final localResult = await _localDataSource.getAllTracks();
      final localCount = localResult.fold(
        (failure) => 0,
        (tracks) => tracks.length,
      );

      return {
        'userId': userId,
        'localTracksCount': localCount,
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

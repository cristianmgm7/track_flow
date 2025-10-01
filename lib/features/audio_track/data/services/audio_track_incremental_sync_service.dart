import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';

@LazySingleton()
class AudioTrackIncrementalSyncService
    implements IncrementalSyncService<AudioTrackDTO> {
  final AudioTrackRemoteDataSource _remoteDataSource;
  final AudioTrackLocalDataSource _localDataSource;
  final ProjectsLocalDataSource _projectsLocalDataSource;

  AudioTrackIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._projectsLocalDataSource,
  );

  @override
  Future<Either<Failure, List<AudioTrackDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'AUDIO_TRACKS',
        'Getting modified audio tracks since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get user's project IDs
      final projectIdsResult = await _getUserProjectIds(userId);
      if (projectIdsResult.isLeft()) {
        return projectIdsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final projectIds = projectIdsResult.getOrElse(() => []);

      if (projectIds.isEmpty) {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'No projects found for user',
          syncKey: userId,
        );
        return const Right([]);
      }

      // Get modified tracks for these projects
      final result = await _remoteDataSource.getAudioTracksModifiedSince(
        lastSyncTime,
        projectIds,
      );

      return result.fold((failure) => Left(failure), (modifiedTracks) {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'Found ${modifiedTracks.length} modified audio tracks',
          syncKey: userId,
        );
        return Right(modifiedTracks);
      });
    } catch (e) {
      AppLogger.error(
        'Failed to get modified audio tracks: $e',
        tag: 'AudioTrackIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to get modified audio tracks: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<AudioTrackDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'AUDIO_TRACKS',
        'Starting incremental sync from ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get user's project IDs
      final projectIdsResult = await _getUserProjectIds(userId);
      if (projectIdsResult.isLeft()) {
        return projectIdsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final projectIds = projectIdsResult.getOrElse(() => []);

      if (projectIds.isEmpty) {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'No projects found for incremental sync',
          syncKey: userId,
        );
        return Right(
          IncrementalSyncResult(
            modifiedItems: [],
            deletedItemIds: [],
            serverTimestamp: DateTime.now().toUtc(),
            totalProcessed: 0,
          ),
        );
      }

      // 1. Get all modified tracks (including deleted ones)
      final modifiedResult = await getModifiedSince(lastSyncTime, userId);
      if (modifiedResult.isLeft()) {
        return modifiedResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final allModifiedTracks = modifiedResult.getOrElse(() => []);

      // 2. Separate active and deleted tracks
      final activeTracks =
          allModifiedTracks.where((t) => !t.isDeleted).toList();
      final deletedTracks =
          allModifiedTracks.where((t) => t.isDeleted).toList();
      final deletedIds = deletedTracks.map((t) => t.id.value).toList();

      AppLogger.sync(
        'AUDIO_TRACKS',
        'Found ${activeTracks.length} active tracks, ${deletedIds.length} deleted tracks',
        syncKey: userId,
      );

      if (deletedIds.isNotEmpty) {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'Deleted track IDs: ${deletedIds.join(", ")}',
          syncKey: userId,
        );
      }

      // 3. Update local cache
      await _updateLocalCache(activeTracks, deletedIds);

      // 4. Compute next cursor using max lastModified from server to avoid clock skew
      DateTime serverTimestamp = lastSyncTime;
      for (final t in allModifiedTracks) {
        if (t.lastModified != null &&
            t.lastModified!.isAfter(serverTimestamp)) {
          serverTimestamp = t.lastModified!;
        }
      }
      // Fallback to now when there are no modified items
      serverTimestamp =
          serverTimestamp == lastSyncTime
              ? DateTime.now().toUtc()
              : serverTimestamp.toUtc();

      final result = IncrementalSyncResult(
        modifiedItems: activeTracks,
        deletedItemIds: deletedIds,
        serverTimestamp: serverTimestamp,
        totalProcessed: activeTracks.length + deletedIds.length,
      );

      AppLogger.sync(
        'AUDIO_TRACKS',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'AudioTrackIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<AudioTrackDTO>>> performFullSync(
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'AUDIO_TRACKS',
        'Starting full sync for user $userId',
        syncKey: userId,
      );

      // Get user's project IDs
      final projectIdsResult = await _getUserProjectIds(userId);
      if (projectIdsResult.isLeft()) {
        return projectIdsResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }

      final projectIds = projectIdsResult.getOrElse(() => []);

      if (projectIds.isEmpty) {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'No projects found for full sync',
          syncKey: userId,
        );
        return Right(
          IncrementalSyncResult(
            modifiedItems: [],
            deletedItemIds: [],
            serverTimestamp: DateTime.now().toUtc(),
            wasFullSync: true,
            totalProcessed: 0,
          ),
        );
      }

      // Get all tracks for user's projects
      final tracks = await _remoteDataSource.getTracksByProjectIds(projectIds);

      AppLogger.sync(
        'AUDIO_TRACKS',
        'Fetched ${tracks.length} audio tracks for ${projectIds.length} projects',
        syncKey: userId,
      );

      // Update local cache with all tracks
      await _updateLocalCache(tracks, []);

      final syncResult = IncrementalSyncResult(
        modifiedItems: tracks,
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        wasFullSync: true,
        totalProcessed: tracks.length,
      );

      AppLogger.sync(
        'AUDIO_TRACKS',
        'Full sync completed: ${syncResult.totalChanges} tracks synced',
        syncKey: userId,
      );

      return Right(syncResult);
    } catch (e) {
      AppLogger.error(
        'Full sync failed: $e',
        tag: 'AudioTrackIncrementalSyncService',
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
      final projectIdsResult = await _getUserProjectIds(userId);
      final projectIds = projectIdsResult.getOrElse(() => []);

      return Right({
        'userId': userId,
        'totalProjects': projectIds.length,
        'syncStrategy': 'incremental_audio_tracks',
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }

  /// Get user's project IDs
  Future<Either<Failure, List<String>>> _getUserProjectIds(
    String userId,
  ) async {
    final projectsResult = await _projectsLocalDataSource.getAllProjects();
    return projectsResult.fold(
      (failure) => Left(failure),
      (projects) => Right(projects.map((p) => p.id).toList()),
    );
  }

  /// Update local cache with modified and deleted tracks
  Future<void> _updateLocalCache(
    List<AudioTrackDTO> modifiedTracks,
    List<String> deletedIds,
  ) async {
    // Update modified tracks with proper sync metadata
    for (final track in modifiedTracks) {
      final cacheResult = await _localDataSource.cacheTrack(track);
      if (cacheResult.isLeft()) {
        AppLogger.error(
          'Failed to cache audio track ${track.id}: ${cacheResult.fold((l) => l.message, (r) => '')}',
          tag: 'AudioTrackIncrementalSyncService',
        );
      }
    }

    // Soft delete removed tracks (mark as deleted for sync)
    for (final id in deletedIds) {
      AppLogger.sync(
        'AUDIO_TRACKS',
        'Deleting track $id from local cache',
        syncKey: 'sync',
      );
      final deleteResult = await _localDataSource.deleteTrack(id);
      if (deleteResult.isLeft()) {
        AppLogger.error(
          'Failed to delete audio track $id: ${deleteResult.fold((l) => l.message, (r) => '')}',
          tag: 'AudioTrackIncrementalSyncService',
        );
      } else {
        AppLogger.sync(
          'AUDIO_TRACKS',
          'Successfully deleted track $id from local cache',
          syncKey: 'sync',
        );
      }
    }
  }
}

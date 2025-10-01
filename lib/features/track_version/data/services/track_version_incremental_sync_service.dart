import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_remote_datasource.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';

@LazySingleton()
class TrackVersionIncrementalSyncService
    implements IncrementalSyncService<TrackVersionDTO> {
  final TrackVersionRemoteDataSource _remoteDataSource;
  final TrackVersionLocalDataSource _localDataSource;
  final AudioTrackLocalDataSource _trackLocalDataSource;

  TrackVersionIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._trackLocalDataSource,
  );
  @override
  Future<Either<Failure, List<TrackVersionDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'TRACK_VERSIONS',
        'Getting modified versions since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Get track IDs from local cache (only active tracks)
      final tracksResult = await _trackLocalDataSource.getAllTracks();
      final tracks = tracksResult.getOrElse(() => []);
      final trackIds =
          tracks.where((t) => !t.isDeleted).map((t) => t.id.value).toList();

      if (trackIds.isEmpty) {
        return const Right([]);
      }

      final result = await _remoteDataSource.getTrackVersionsModifiedSince(
        lastSyncTime,
        trackIds,
      );

      return result.fold(
        (failure) => Left(failure),
        (versions) => Right(versions),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get modified versions: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<TrackVersionDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'TRACK_VERSIONS',
        'Starting incremental sync from ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      final modifiedResult = await getModifiedSince(lastSyncTime, userId);
      if (modifiedResult.isLeft()) {
        return modifiedResult.fold(
          (l) => Left(l),
          (_) => throw UnimplementedError(),
        );
      }

      final allModified = modifiedResult.getOrElse(() => []);
      final active = allModified.where((v) => !(v.isDeleted)).toList();
      final deleted = allModified.where((v) => v.isDeleted).toList();

      // Update local cache
      for (final v in active) {
        final cacheResult = await _localDataSource.cacheVersion(v);
        if (cacheResult.isLeft()) {
          AppLogger.error(
            'Failed to cache track version ${v.id}: ${cacheResult.fold((l) => l.message, (r) => '')}',
            tag: 'TrackVersionIncrementalSyncService',
          );
        }
      }

      for (final v in deleted) {
        await _localDataSource.deleteVersion(
          TrackVersionId.fromUniqueString(v.id),
        );
      }

      // Compute next cursor from max lastModified
      DateTime serverTimestamp = lastSyncTime;
      for (final v in allModified) {
        if (v.lastModified != null &&
            v.lastModified!.isAfter(serverTimestamp)) {
          serverTimestamp = v.lastModified!;
        }
      }
      serverTimestamp =
          allModified.isEmpty ? lastSyncTime.toUtc() : serverTimestamp.toUtc();

      final result = IncrementalSyncResult(
        modifiedItems: active,
        deletedItemIds: deleted.map((v) => v.id).toList(),
        serverTimestamp: serverTimestamp,
        totalProcessed: allModified.length,
      );

      AppLogger.sync(
        'TRACK_VERSIONS',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Track versions incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<TrackVersionDTO>>>
  performFullSync(String userId) async {
    try {
      AppLogger.sync(
        'TRACK_VERSIONS',
        'Starting full sync for $userId',
        syncKey: userId,
      );

      // Get all active tracks locally to derive track IDs
      final tracksResult = await _trackLocalDataSource.getAllTracks();
      final tracks = tracksResult.getOrElse(() => []);
      final trackIds =
          tracks.where((t) => !t.isDeleted).map((t) => t.id.value).toList();

      if (trackIds.isEmpty) {
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

      // Pull all versions for these tracks
      // We can reuse modified since with a very old cursor to simplify
      final result = await _remoteDataSource.getTrackVersionsModifiedSince(
        DateTime.fromMillisecondsSinceEpoch(0),
        trackIds,
      );

      return result.fold((failure) => Left(failure), (versions) async {
        final active = versions.where((v) => !(v.isDeleted)).toList();
        final deleted = versions.where((v) => v.isDeleted).toList();

        for (final v in active) {
          await _localDataSource.cacheVersion(v);
        }

        for (final v in deleted) {
          await _localDataSource.deleteVersion(
            TrackVersionId.fromUniqueString(v.id),
          );
        }

        final cursor =
            versions.fold<DateTime>(DateTime.fromMillisecondsSinceEpoch(0), (
              acc,
              v,
            ) {
              if (v.lastModified != null && v.lastModified!.isAfter(acc))
                return v.lastModified!;
              return acc;
            }).toUtc();

        final syncResult = IncrementalSyncResult(
          modifiedItems: active,
          deletedItemIds: deleted.map((v) => v.id).toList(),
          serverTimestamp: cursor,
          wasFullSync: true,
          totalProcessed: versions.length,
        );

        AppLogger.sync(
          'TRACK_VERSIONS',
          'Full sync completed: ${syncResult.totalChanges} versions',
          syncKey: userId,
        );

        return Right(syncResult);
      });
    } catch (e) {
      return Left(ServerFailure('Track versions full sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    return Right({
      'userId': userId,
      'totalVersions': 0,
      'syncStrategy': 'placeholder',
      'lastSync': DateTime.now().toIso8601String(),
    });
  }
}

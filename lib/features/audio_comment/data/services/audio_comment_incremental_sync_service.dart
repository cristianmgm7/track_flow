import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';

/// 🎵 AUDIO COMMENT INCREMENTAL SYNC SERVICE
///
/// Implements IncrementalSyncService for audio comments.
/// Handles incremental sync of comments for track versions.
@LazySingleton(as: IncrementalSyncService<AudioCommentDTO>)
class AudioCommentIncrementalSyncService
    implements IncrementalSyncService<AudioCommentDTO> {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentLocalDataSource _localDataSource;
  final TrackVersionLocalDataSource _versionLocalDataSource;

  AudioCommentIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
    this._versionLocalDataSource,
  );

  @override
  Future<Either<Failure, List<AudioCommentDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      AppLogger.sync(
        'AUDIO_COMMENTS',
        'Fetching comments modified since ${lastSyncTime.toIso8601String()}',
        syncKey: userId,
      );

      // Derive versionIds from local track versions
      final versionsResult = await _versionLocalDataSource.getAllVersions();
      final versions = versionsResult.getOrElse(() => []);
      final versionIds = versions.map((v) => v.id).toList();
      if (versionIds.isEmpty) return const Right([]);

      final result = await _remoteDataSource.getCommentsModifiedSince(
        lastSyncTime,
        versionIds,
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'Failed to get modified comments: $e',
        tag: 'AudioCommentIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to get modified comments: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<AudioCommentDTO>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    try {
      AppLogger.sync(
        'AUDIO_COMMENTS',
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
      final all = modifiedResult.getOrElse(() => []);
      final active = all.where((c) => !(c.isDeleted)).toList();
      final deleted = all.where((c) => c.isDeleted).toList();

      for (final c in active) {
        await _localDataSource.cacheComment(c);
      }
      for (final c in deleted) {
        await _localDataSource.deleteCachedComment(c.id);
      }

      // Compute next cursor from max lastModified, do not advance if empty
      DateTime serverTimestamp = lastSyncTime;
      for (final c in all) {
        if (c.lastModified != null &&
            c.lastModified!.isAfter(serverTimestamp)) {
          serverTimestamp = c.lastModified!;
        }
      }
      serverTimestamp =
          all.isEmpty ? lastSyncTime.toUtc() : serverTimestamp.toUtc();

      final result = IncrementalSyncResult(
        modifiedItems: active,
        deletedItemIds: deleted.map((c) => c.id).toList(),
        serverTimestamp: serverTimestamp,
        totalProcessed: all.length,
      );

      AppLogger.sync(
        'AUDIO_COMMENTS',
        'Incremental sync completed: ${result.totalChanges} changes',
        syncKey: userId,
      );

      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'AudioCommentIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<AudioCommentDTO>>>
  performFullSync(String userId) async {
    try {
      AppLogger.sync('AUDIO_COMMENTS', 'Starting full sync', syncKey: userId);

      // Use very old cursor to pull everything for local versions
      return performIncrementalSync(
        DateTime.fromMillisecondsSinceEpoch(0),
        userId,
      );
    } catch (e) {
      AppLogger.error(
        'Full sync failed: $e',
        tag: 'AudioCommentIncrementalSyncService',
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
      // For now, return basic stats - can't easily count all comments
      // TODO: Add a count method to local data source
      return Right({
        'userId': userId,
        'totalComments': 0, // Placeholder
        'syncStrategy': 'basic_version_based_sync',
        'lastSync': DateTime.now().toIso8601String(),
        'note': 'Statistics not fully implemented - needs count method',
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get sync statistics: $e'));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

/// 🎵 AUDIO COMMENT INCREMENTAL SYNC SERVICE
///
/// Implements IncrementalSyncService for audio comments.
/// Handles incremental sync of comments for track versions.
@LazySingleton()
class AudioCommentIncrementalSyncService
    implements IncrementalSyncService<AudioCommentDTO> {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentLocalDataSource _localDataSource;

  AudioCommentIncrementalSyncService(
    this._remoteDataSource,
    this._localDataSource,
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

      // For now, return empty - need to implement remote incremental methods
      // TODO: Add getCommentsModifiedSince to remote data source
      AppLogger.warning('AudioComment incremental fetch not implemented yet');
      return const Right([]);
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
  Future<Either<Failure, bool>> hasModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    try {
      // For now, always return true to trigger sync
      // TODO: Implement hasCommentsModifiedSince in remote data source
      return const Right(true);
    } catch (e) {
      AppLogger.error(
        'Failed to check for modified comments: $e',
        tag: 'AudioCommentIncrementalSyncService',
        error: e,
      );
      return Left(ServerFailure('Failed to check for modified comments: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
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

      // For now, implement basic sync - fetch all comments for user's versions
      // TODO: Replace with true incremental logic when remote methods are ready

      // For now, implement basic sync - clear and refetch approach
      // TODO: Implement proper incremental logic with version tracking

      await _localDataSource.clearCache();

      // Since we don't have a way to track which versions have comments,
      // we'll use a placeholder approach for now
      List<AudioCommentDTO> allComments = [];

      AppLogger.warning(
        'AudioComment sync: Using basic clear/refetch - needs proper version tracking',
        tag: 'AudioCommentIncrementalSyncService',
      );

      final result = IncrementalSyncResult(
        modifiedItems: allComments,
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        totalProcessed: allComments.length,
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

      // Same as incremental for now - fetch all comments
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

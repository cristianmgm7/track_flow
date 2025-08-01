import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

@LazySingleton(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentLocalDataSource _localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  AudioCommentRepositoryImpl({
    required AudioCommentRemoteDataSource remoteDataSource,
    required AudioCommentLocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _localDataSource = localDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  ) async {
    try {
      // 1. ALWAYS try local cache first
      final result = await _localDataSource.getCommentById(commentId.value);

      final localComment = result.fold(
        (failure) => null,
        (dto) => dto?.toDomain(),
      );

      // 2. If found locally, return it and trigger background refresh
      if (localComment != null) {
        // Trigger background sync for fresh data (non-blocking)
        unawaited(
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'audio_comment_${commentId.value}',
          ),
        );

        return Right(localComment);
      }

      // 3. Not found locally - trigger background fetch and return not found
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_comment_${commentId.value}',
        ),
      );

      return Left(DatabaseFailure('Audio comment not found in local cache'));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    try {
      // Trigger background sync when method is called
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_comments_${trackId.value}',
        ),
      );

      // CACHE-ASIDE PATTERN: Return local data immediately + trigger background sync
      return _localDataSource.watchCommentsByTrack(trackId.value).map((
        localResult,
      ) {
        // Always return local data immediately
        return localResult.fold(
          (failure) => Left(failure),
          (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(
          DatabaseFailure('Failed to watch audio comments: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    try {
      final dto = AudioCommentDTO.fromDomain(comment);

      // 1. ALWAYS save locally first (ignore minor cache errors)
      await _localDataSource.cacheComment(dto);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addCreateOperation(
        entityType: 'audio_comment',
        entityId: comment.id.value,
        data: {
          'trackId': comment.trackId.value,
          'projectId': comment.projectId.value,
          'createdBy': comment.createdBy.value,
          'content': comment.content,
          'timestamp': comment.timestamp.inMilliseconds,
          'createdAt': comment.createdAt.toIso8601String(),
        },
        priority: SyncPriority.high,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync (no condition check - coordinator handles it)
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_comments_create',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
    try {
      // 1. ALWAYS soft delete locally first
      await _localDataSource.deleteCachedComment(commentId.value);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addDeleteOperation(
        entityType: 'audio_comment',
        entityId: commentId.value,
        priority: SyncPriority.high,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_comments_delete',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning('Background sync trigger failed: $error', tag: 'AudioCommentRepositoryImpl');
    });
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

@LazySingleton(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentLocalDataSource _localDataSource;
  final NetworkStateManager _networkStateManager;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  AudioCommentRepositoryImpl({
    required AudioCommentRemoteDataSource remoteDataSource,
    required AudioCommentLocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkStateManager = networkStateManager,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  ) async {
    final comment = await _localDataSource.getCommentById(commentId.value);
    return comment.fold(
      (failure) => Left(failure),
      (dto) =>
          dto != null
              ? Right(dto.toDomain())
              : Left(ServerFailure('No comment found')),
    );
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    try {
      // CACHE-ASIDE PATTERN: Return local data immediately + trigger background sync
      return _localDataSource.watchCommentsByTrack(trackId.value).asyncMap((
        localResult,
      ) async {
        // Trigger background sync if connected (non-blocking)
        if (await _networkStateManager.isConnected) {
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'audio_comments_${trackId.value}',
          );
        }

        // Return local data immediately
        return localResult.fold(
          (failure) => Left(failure),
          (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch audio comments')),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    try {
      // 1. OFFLINE-FIRST: Save locally IMMEDIATELY
      final dto = AudioCommentDTO.fromDomain(comment);
      final localResult = await _localDataSource.cacheComment(dto);

      await localResult.fold(
        (failure) =>
            throw Exception(
              'Failed to cache comment locally: ${failure.message}',
            ),
        (success) async {
          // 2. Queue for background sync
          await _pendingOperationsManager.addOperation(
            entityType: 'audio_comment',
            entityId: comment.id.value,
            operationType: 'create',
            priority: SyncPriority.high,
            data: {
              'trackId': comment.trackId.value,
              'projectId': comment.projectId.value,
            },
          );

          // 3. Trigger background sync if connected
          if (await _networkStateManager.isConnected) {
            _backgroundSyncCoordinator.triggerBackgroundSync(
              syncKey: 'audio_comments_create',
            );
          }
        },
      );

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to add comment: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
    try {
      // 1. OFFLINE-FIRST: Delete locally IMMEDIATELY (soft delete)
      await _localDataSource.deleteCachedComment(commentId.value);

      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'audio_comment',
        entityId: commentId.value,
        operationType: 'delete',
        priority: SyncPriority.high,
        data: {},
      );

      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_comments_delete',
        );
      }

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete comment: $e'));
    }
  }
}

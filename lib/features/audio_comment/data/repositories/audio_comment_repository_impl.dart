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
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

@LazySingleton(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentLocalDataSource _localDataSource;
  final AudioCommentRemoteDataSource _remoteDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;
  final TrackVersionRepository _trackVersionRepository;

  AudioCommentRepositoryImpl({
    required AudioCommentRemoteDataSource remoteDataSource,
    required AudioCommentLocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
    required TrackVersionRepository trackVersionRepository,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager,
       _trackVersionRepository = trackVersionRepository;

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
        // No sync in get methods - just return local data

        return Right(localComment);
      }

      // 3. Not found locally - return not found (no sync in get methods)

      return Left(DatabaseFailure('Audio comment not found in local cache'));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByTrackId(AudioTrackId trackId) async {
    try {
      final versionsEither = await _trackVersionRepository.getVersionsByTrack(
        trackId,
      );
      if (versionsEither.isLeft()) return versionsEither.map((_) => unit);
      final versions = versionsEither.getOrElse(() => []);

      // Delete comments per version (remote + local)
      for (final v in versions) {
        try {
          await _remoteDataSource.deleteByVersionId(v.id.value);
        } catch (_) {}
        try {
          await _localDataSource.deleteByVersion(v.id.value);
        } catch (_) {}
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete comments by track: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    // Deprecated in favor of version-scoped watcher. Return empty stream for now.
    return Stream.value(const Right(<AudioComment>[]));
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByVersion(
    TrackVersionId versionId,
  ) {
    try {
      // NO sync in watch methods - just return local data stream
      return _localDataSource.watchCommentsByVersion(versionId.value).map((
        localResult,
      ) {
        return localResult.fold(
          (failure) => Left(failure),
          (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(
          DatabaseFailure(
            'Failed to watch audio comments by version: ${e.toString()}',
          ),
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
          'trackId': comment.versionId.value,
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

      unawaited(_backgroundSyncCoordinator.pushUpstream());

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

      unawaited(_backgroundSyncCoordinator.pushUpstream());

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllComments() async {
    try {
      await _localDataSource.deleteAllComments();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete all comments: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCommentsByVersion(
    TrackVersionId versionId,
  ) async {
    try {
      // Delete remote comments first
      try {
        await _remoteDataSource.deleteByVersionId(versionId.value);
      } catch (_) {
        // Ignore remote deletion errors - continue with local deletion
      }

      // Delete local comments
      try {
        await _localDataSource.deleteByVersion(versionId.value);
      } catch (e) {
        return Left(DatabaseFailure('Failed to delete local comments: $e'));
      }

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete comments by version: $e'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning(
        'Background sync trigger failed: $error',
        tag: 'AudioCommentRepositoryImpl',
      );
    });
  }
}

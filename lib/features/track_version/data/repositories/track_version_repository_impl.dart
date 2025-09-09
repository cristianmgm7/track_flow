import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: TrackVersionRepository)
class TrackVersionRepositoryImpl implements TrackVersionRepository {
  final TrackVersionLocalDataSource _local;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  TrackVersionRepositoryImpl(
    this._local,
    this._backgroundSyncCoordinator,
    this._pendingOperationsManager,
  );

  @override
  Future<Either<Failure, TrackVersion>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
    Duration? duration,
  }) async {
    try {
      // 1. Create version locally first (offline-first approach)
      final localResult = await _local.addVersion(
        trackId: trackId,
        file: file,
        label: label,
        duration: duration,
      );

      if (localResult.isLeft()) {
        return localResult.map((_) => throw Exception());
      }

      final versionDTO = localResult.getOrElse(() => throw Exception());
      final version = versionDTO.toDomain();

      // 2. Queue upload operation for background sync
      await _queueUploadOperation(versionDTO);

      // 3. Trigger background sync to upload file
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_version_upload',
        ),
      );

      return Right(version);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add track version: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<TrackVersion>>> watchVersionsByTrack(
    AudioTrackId trackId,
  ) {
    return _local
        .watchVersionsByTrack(trackId)
        .map(
          (either) => either.map(
            (dtos) =>
                dtos.map((d) => d.toDomain()).toList()
                  ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber)),
          ),
        );
  }

  @override
  Future<Either<Failure, List<TrackVersion>>> getVersionsByTrack(
    AudioTrackId trackId,
  ) async {
    final dtoEither = await _local.getVersionsByTrack(trackId);
    return dtoEither.map(
      (dtos) =>
          dtos.map((dto) => dto.toDomain()).toList()
            ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber)),
    );
  }

  @override
  Future<Either<Failure, TrackVersion>> getActiveVersion(
    AudioTrackId trackId,
  ) async {
    final dtoEither = await _local.getActiveVersion(trackId);
    return dtoEither.map((dto) => dto.toDomain());
  }

  @override
  Future<Either<Failure, TrackVersion>> getById(TrackVersionId id) async {
    final dtoEither = await _local.getById(id);
    return dtoEither.map((dto) => dto.toDomain());
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    try {
      final result = await _local.setActiveVersion(
        trackId: trackId,
        versionId: versionId,
      );

      if (result.isLeft()) {
        return result;
      }

      // Queue update operation for background sync
      await _queueUpdateOperation(trackId, versionId);

      // Trigger upstream sync only (more efficient for local changes)
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_versions_update',
        ),
      );

      return result;
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId) async {
    try {
      final result = await _local.deleteVersion(versionId);

      if (result.isLeft()) {
        return result;
      }

      // Queue delete operation for background sync
      await _queueDeleteOperation(versionId);

      // Trigger upstream sync only (more efficient for local changes)
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_versions_update',
        ),
      );

      return result;
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> renameVersion({
    required TrackVersionId versionId,
    required String? newLabel,
  }) async {
    try {
      final result = await _local.renameVersion(
        versionId: versionId,
        newLabel: newLabel,
      );

      if (result.isLeft()) {
        return result;
      }

      // Queue update operation for background sync
      await _queueRenameOperation(versionId, newLabel);

      // Trigger upstream sync only (more efficient for local changes)
      unawaited(
        _backgroundSyncCoordinator.triggerUpstreamSync(
          syncKey: 'track_versions_update',
        ),
      );

      return result;
    } catch (e) {
      return Left(DatabaseFailure('Failed to rename version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      return await _local.clearCache();
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear track versions cache: $e'));
    }
  }

  /// Queue upload operation for background sync
  Future<void> _queueUploadOperation(dynamic versionDTO) async {
    try {
      final operationData = {
        'versionId': versionDTO.id,
        'trackId': versionDTO.trackId,
        'versionNumber': versionDTO.versionNumber,
        'label': versionDTO.label,
        'fileLocalPath': versionDTO.fileLocalPath,
        'durationMs': versionDTO.durationMs,
        'createdBy': versionDTO.createdBy,
        'createdAt': versionDTO.createdAt.toIso8601String(),
      };

      await _pendingOperationsManager.addCreateOperation(
        entityType: 'track_version',
        entityId: versionDTO.id,
        data: operationData,
        priority: SyncPriority.high, // High priority for audio uploads
      );
    } catch (e) {
      AppLogger.error(
        'Failed to queue track version upload operation: $e',
        tag: 'TrackVersionRepositoryImpl',
        error: e,
      );
    }
  }

  /// Queue update operation for background sync
  Future<void> _queueUpdateOperation(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    try {
      final operationData = {
        'versionId': versionId.value,
        'trackId': trackId.value,
        'status': 'active',
      };

      await _pendingOperationsManager.addUpdateOperation(
        entityType: 'track_version',
        entityId: versionId.value,
        data: operationData,
        priority: SyncPriority.medium,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to queue track version update operation: $e',
        tag: 'TrackVersionRepositoryImpl',
        error: e,
      );
    }
  }

  /// Queue delete operation for background sync
  Future<void> _queueDeleteOperation(TrackVersionId versionId) async {
    try {
      await _pendingOperationsManager.addDeleteOperation(
        entityType: 'track_version',
        entityId: versionId.value,
        priority: SyncPriority.medium,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to queue track version delete operation: $e',
        tag: 'TrackVersionRepositoryImpl',
        error: e,
      );
    }
  }

  /// Queue rename operation for background sync
  Future<void> _queueRenameOperation(
    TrackVersionId versionId,
    String? newLabel,
  ) async {
    try {
      final operationData = {
        'versionId': versionId.value,
        'newLabel': newLabel,
        'field': 'label',
      };

      await _pendingOperationsManager.addUpdateOperation(
        entityType: 'track_version',
        entityId: versionId.value,
        data: operationData,
        priority: SyncPriority.medium,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to queue track version rename operation: $e',
        tag: 'TrackVersionRepositoryImpl',
        error: e,
      );
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning(
        'Background sync trigger failed: $error',
        tag: 'TrackVersionRepositoryImpl',
      );
    });
  }
}

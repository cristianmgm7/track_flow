import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: AudioTrackRepository)
class AudioTrackRepositoryImpl implements AudioTrackRepository {
  final AudioTrackLocalDataSource localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  AudioTrackRepositoryImpl(
    this.localDataSource,
    this._backgroundSyncCoordinator,
    this._pendingOperationsManager,
  );

  @override
  Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id) async {
    try {
      // 1. ALWAYS try local cache first
      final result = await localDataSource.getTrackById(id.value);

      final localTrack = result.fold(
        (failure) => null,
        (dto) => dto?.toDomain(),
      );

      // 2. If found locally, return it and trigger background refresh
      if (localTrack != null) {
        return Right(localTrack);
      }

      // 3. Not found locally - trigger background fetch and return not found
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      return Left(DatabaseFailure('Audio track not found in local cache'));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, AudioTrack>> watchTrackById(AudioTrackId id) {
    try {
      return localDataSource.watchTrackById(id.value).map((eitherDto) {
        return eitherDto.fold(
          (failure) => Left(failure),
          (dto) =>
              dto != null
                  ? Right(dto.toDomain())
                  : Left(
                    DatabaseFailure('Audio track not found in local cache'),
                  ),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch audio track: ${e.toString()}')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    try {
      // CACHE-ASIDE PATTERN: Return local data immediately + trigger background sync
      return localDataSource.watchTracksByProject(projectId.value).map((
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
        Left(DatabaseFailure('Failed to watch audio tracks: ${e.toString()}')),
      );
    }
  }

  @override
  Future<Either<Failure, AudioTrack>> createTrack(AudioTrack track) async {
    try {
      final dto = AudioTrackDTO.fromDomain(track, extension: 'mp3');

      // 1. Save locally first
      final cacheResult = await localDataSource.cacheTrack(dto);
      if (cacheResult.isLeft()) {
        return cacheResult.map(
          (_) => track,
        ); // Return track even if cache fails
      }

      // 2. Queue for background sync
      final queueResult = await _pendingOperationsManager.addCreateOperation(
        entityType: 'audio_track',
        entityId: track.id.value,
        data: {
          'projectId': track.projectId.value,
          'name': track.name,
          'duration': track.duration.inMilliseconds,
          'uploadedBy': track.uploadedBy.value,
          'createdAt': track.createdAt.toIso8601String(),
        },
        priority: SyncPriority.high,
      );

      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      unawaited(_backgroundSyncCoordinator.pushUpstream());

      return Right(track);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(
    AudioTrackId trackId,
    ProjectId projectId,
  ) async {
    try {
      // 1. Get track data before deletion for sync operation
      final trackResult = await localDataSource.getTrackById(trackId.value);
      if (trackResult.isLeft()) {
        return Left(DatabaseFailure('Track not found: ${trackId.value}'));
      }

      final trackDto = trackResult.getOrElse(() => null);
      if (trackDto == null) {
        return Left(DatabaseFailure('Track not found: ${trackId.value}'));
      }

      // 2. ALWAYS soft delete locally first
      await localDataSource.deleteTrack(trackId.value);

      // 3. Try to queue for background sync with complete track data
      final queueResult = await _pendingOperationsManager.addOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        operationType: 'delete',
        priority: SyncPriority.high,
        data: {
          'name': trackDto.name,
          'url': trackDto.url,
          'duration': trackDto.duration,
          'projectId': trackDto.projectId.value,
          'uploadedBy': trackDto.uploadedBy.value,
          'createdAt': trackDto.createdAt?.toIso8601String(),
          'extension': trackDto.extension,
          'version': trackDto.version,
          'lastModified': trackDto.lastModified?.toIso8601String(),
        },
      );

      // 4. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 5. Trigger upstream sync only (more efficient for local changes)
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      // 6. Ensure local URL remains pointing to remote (not cache)
      // We cannot compute remote URL here; keep current local value (remote URL
      // should already be persisted from upload). If local was pointing to a
      // cache path, the player will fallback to remote when cache is missing.

      // 7. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> editTrackName({
    required AudioTrackId trackId,
    required ProjectId projectId,
    required String newName,
  }) async {
    try {
      // 1. ALWAYS update locally first
      await localDataSource.updateTrackName(trackId.value, newName);

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        data: {
          'projectId': projectId.value,
          'newName': newName,
          'field': 'name',
        },
        priority: SyncPriority.medium,
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

      // 4. Trigger upstream sync only (more efficient for local changes)
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    try {
      // 1. Update local first
      final localResult = await localDataSource.setActiveVersion(
        trackId.value,
        versionId.value,
      );

      if (localResult.isLeft()) {
        return localResult;
      }

      // 2. Queue operation for sync (consistent with offline-first architecture)
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        data: {'activeVersionId': versionId.value, 'field': 'activeVersion'},
        priority: SyncPriority.medium,
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

      // 4. Trigger upstream sync only (more efficient for local changes)
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      return localResult;
    } catch (e) {
      return Left(DatabaseFailure('Failed to set active version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllTracks() async {
    try {
      await localDataSource.deleteAllTracks();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete all tracks: $e'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning(
        'Background sync trigger failed: $error',
        tag: 'AudioTrackRepositoryImpl',
      );
    });
  }
}

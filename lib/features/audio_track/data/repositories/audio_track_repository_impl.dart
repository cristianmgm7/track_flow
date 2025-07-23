import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'dart:io';

@LazySingleton(as: AudioTrackRepository)
class AudioTrackRepositoryImpl implements AudioTrackRepository {
  final AudioTrackRemoteDataSource remoteDataSource;
  final AudioTrackLocalDataSource localDataSource;
  final NetworkStateManager _networkStateManager;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  AudioTrackRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this._networkStateManager,
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
        // Trigger background sync for fresh data (non-blocking)
        unawaited(
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: 'audio_track_${id.value}',
          ),
        );

        return Right(localTrack);
      }

      // 3. Not found locally - trigger background fetch and return not found
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_track_${id.value}',
        ),
      );

      return Left(DatabaseFailure('Audio track not found in local cache'));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    try {
      // Trigger background sync when method is called
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_${projectId.value}',
        ),
      );

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
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  }) async {
    try {
      final dto = AudioTrackDTO.fromDomain(
        track,
        extension: file.path.split('.').last,
      );

      // 1. ALWAYS save locally first (ignore minor cache errors)
      await localDataSource.cacheTrack(dto);

      // 2. ALWAYS queue for background sync
      await _pendingOperationsManager.addCreateOperation(
        entityType: 'audio_track',
        entityId: track.id.value,
        data: {
          'filePath': file.path,
          'projectId': track.projectId.value,
          'name': track.name,
          'duration': track.duration.inMilliseconds,
          'extension': file.path.split('.').last,
          'uploadedBy': track.uploadedBy.value,
          'createdAt': track.createdAt.toIso8601String(),
        },
        priority: SyncPriority.high,
      );

      // 3. Trigger background sync (no condition check - coordinator handles it)
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_upload',
        ),
      );

      // 4. ALWAYS return success immediately
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(
    AudioTrackId trackId,
    ProjectId projectId,
  ) async {
    try {
      // 1. ALWAYS soft delete locally first
      await localDataSource.deleteTrack(trackId.value);

      // 2. ALWAYS queue for background sync
      await _pendingOperationsManager.addDeleteOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        priority: SyncPriority.high,
      );

      // 3. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_delete',
        ),
      );

      // 4. ALWAYS return success immediately
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

      // 2. ALWAYS queue for background sync
      await _pendingOperationsManager.addUpdateOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        data: {
          'projectId': projectId.value,
          'newName': newName,
          'field': 'name',
        },
        priority: SyncPriority.medium,
      );

      // 3. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_update',
        ),
      );

      // 4. ALWAYS return success immediately
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      print('Background sync trigger failed: $error');
    });
  }
}

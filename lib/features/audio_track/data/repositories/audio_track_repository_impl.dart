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
import 'package:trackflow/core/sync/background_sync_coordinator.dart';
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
      final result = await localDataSource.getTrackById(id.value);
      return result.fold(
        (failure) => Left(failure), // Pass failure through without wrapping
        (dto) =>
            dto != null
                ? Right(dto.toDomain())
                : Left(ServerFailure('Track not found')),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    try {
      // CACHE-ASIDE PATTERN: Return local data immediately + trigger background sync
      return localDataSource
          .watchTracksByProject(projectId.value)
          .asyncMap((localResult) async {
            // Trigger background sync if connected (non-blocking)
            if (await _networkStateManager.isConnected) {
              _backgroundSyncCoordinator.triggerBackgroundSync(
                syncKey: 'audio_tracks_${projectId.value}',
              );
            }

            // Return local data immediately
            return localResult.fold(
              (failure) => Left(failure),
              (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
            );
          });
    } catch (e) {
      return Stream.value(Left(DatabaseFailure('Failed to watch audio tracks')));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  }) async {
    try {
      // 1. OFFLINE-FIRST: Save locally IMMEDIATELY
      final dto = AudioTrackDTO.fromDomain(track, extension: file.path.split('.').last);
      final localResult = await localDataSource.cacheTrack(dto);
      
      await localResult.fold(
        (failure) => throw Exception('Failed to cache track locally: ${failure.message}'),
        (success) async {
          // 2. Queue for background sync
          await _pendingOperationsManager.addOperation(
            entityType: 'audio_track',
            entityId: track.id.value,
            operationType: 'upload',
            priority: SyncPriority.high,
            data: {'filePath': file.path}, // Store file path for later upload
          );

          // 3. Trigger background sync if connected
          if (await _networkStateManager.isConnected) {
            _backgroundSyncCoordinator.triggerBackgroundSync(
              syncKey: 'audio_tracks_upload',
            );
          }
        },
      );

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to prepare track upload: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(
    AudioTrackId trackId,
    ProjectId projectId,
  ) async {
    try {
      // 1. OFFLINE-FIRST: Mark as deleted locally IMMEDIATELY (soft delete)
      await localDataSource.deleteTrack(trackId.value);

      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        operationType: 'delete',
        priority: SyncPriority.high,
        data: {'projectId': projectId.value},
      );

      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_delete',
        );
      }

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> editTrackName({
    required AudioTrackId trackId,
    required ProjectId projectId,
    required String newName,
  }) async {
    try {
      // 1. OFFLINE-FIRST: Update locally IMMEDIATELY
      await localDataSource.updateTrackName(trackId.value, newName);

      // 2. Queue for background sync
      await _pendingOperationsManager.addOperation(
        entityType: 'audio_track',
        entityId: trackId.value,
        operationType: 'update',
        priority: SyncPriority.medium,
        data: {
          'projectId': projectId.value,
          'newName': newName,
          'field': 'name',
        },
      );

      // 3. Trigger background sync if connected
      if (await _networkStateManager.isConnected) {
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'audio_tracks_update',
        );
      }

      return Right(unit); // ✅ IMMEDIATE SUCCESS - no network blocking
    } catch (e) {
      return Left(DatabaseFailure('Failed to update track name: $e'));
    }
  }
}

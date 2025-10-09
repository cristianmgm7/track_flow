import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';

@Injectable(as: WaveformRepository)
class WaveformRepositoryImpl implements WaveformRepository {
  final WaveformLocalDataSource _localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  WaveformRepositoryImpl({
    required WaveformLocalDataSource localDataSource,
    required WaveformRemoteDataSource remoteDataSource,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _localDataSource = localDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, AudioWaveform>> getWaveformByVersionId(
    TrackVersionId versionId,
  ) async {
    try {
      final waveform = await _localDataSource.getWaveformByVersionId(versionId);
      if (waveform == null) {
        return Left(
          ServerFailure('Waveform not found for version: ${versionId.value}'),
        );
      }
      return Right(waveform);
    } catch (e) {
      return Left(ServerFailure('Failed to get waveform: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWaveformsForVersion(
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) async {
    try {
      // 1. ALWAYS delete locally first (offline-first principle)
      await _localDataSource.deleteWaveformsForVersion(versionId);

      // 2. Queue for background sync to delete remotely
      final queueResult = await _pendingOperationsManager.addOperation(
        entityType: 'audio_waveform',
        entityId: versionId.value,
        operationType: 'delete',
        priority: SyncPriority.medium,
        data: {'trackId': trackId.value, 'versionId': versionId.value},
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue waveform deletion: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger upstream sync only (more efficient for deletions)
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      // 5. Return success after successful local deletion and queuing
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical waveform deletion error: $e'));
    }
  }

  @override
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId) {
    return _localDataSource.watchWaveformChanges(versionId);
  }

  @override
  Future<Either<Failure, Unit>> clearAllWaveforms() async {
    try {
      await _localDataSource.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to clear waveforms: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> storeCanonicalWaveform({
    required AudioTrackId trackId,
    required AudioWaveform waveform,
  }) async {
    try {
      await _localDataSource.saveWaveform(waveform);
      // Queue upstream sync operation instead of calling remote directly
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: 'audio_waveform',
        entityId: waveform.versionId.value,
        priority: SyncPriority.medium,
        data: {
          'trackId': trackId.value,
          'id': waveform.id.value,
          'versionId': waveform.versionId.value,
          'amplitudes': waveform.data.amplitudes,
          'sampleRate': waveform.data.sampleRate,
          'durationMs': waveform.data.duration.inMilliseconds,
          'targetSampleCount': waveform.data.targetSampleCount,
          'maxAmplitude': waveform.metadata.maxAmplitude,
          'rmsLevel': waveform.metadata.rmsLevel,
          'compressionLevel': waveform.metadata.compressionLevel,
          'generationMethod': waveform.metadata.generationMethod,
          'generatedAt': waveform.generatedAt.toIso8601String(),
        },
      );

      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // Trigger upstream-only sync (non-blocking)
      _backgroundSyncCoordinator.pushUpstream();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to store canonical waveform: $e'));
    }
  }
}

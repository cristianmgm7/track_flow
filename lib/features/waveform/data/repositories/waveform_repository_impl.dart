import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';

@Injectable(as: WaveformRepository)
class WaveformRepositoryImpl implements WaveformRepository {
  final WaveformLocalDataSource _localDataSource;
  final WaveformRemoteDataSource _remoteDataSource;

  WaveformRepositoryImpl({
    required WaveformLocalDataSource localDataSource,
    required WaveformRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, AudioWaveform>> getWaveformByVersionId(
    TrackVersionId versionId,
  ) async {
    try {
      AppLogger.debug(
        'WaveformRepositoryImpl: Looking up waveform for version ${versionId.value} (no hash)',
        tag: 'WAVEFORM_REPO',
      );
      final waveform = await _localDataSource.getWaveformByVersionId(versionId);
      if (waveform == null) {
        AppLogger.warning(
          'WaveformRepositoryImpl: No waveform found locally for version ${versionId.value}',
          tag: 'WAVEFORM_REPO',
        );
        return Left(
          ServerFailure('Waveform not found for version: ${versionId.value}'),
        );
      }
      AppLogger.debug(
        'WaveformRepositoryImpl: Found waveform locally for version ${versionId.value}',
        tag: 'WAVEFORM_REPO',
      );
      return Right(waveform);
    } catch (e) {
      AppLogger.error(
        'WaveformRepositoryImpl: Error getting waveform for version ${versionId.value}: $e',
        tag: 'WAVEFORM_REPO',
      );
      return Left(ServerFailure('Failed to get waveform: $e'));
    }
  }

  // getOrGenerate removed; generation handled by use case, remote/local by canonical methods

  @override
  Future<Either<Failure, Unit>> invalidate({
    required TrackVersionId versionId,
  }) {
    return deleteWaveformsForVersion(versionId);
  }

  @override
  Future<Either<Failure, Unit>> saveWaveform(AudioWaveform waveform) async {
    try {
      await _localDataSource.saveWaveform(waveform);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to save waveform: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWaveformsForVersion(
    TrackVersionId versionId,
  ) async {
    try {
      // Delete remote waveforms first (if available)
      // Note: We would need trackId to call remote deletion, but it's not available here
      // The remote waveform deletion should be handled by the track deletion process
      // since waveforms are associated with track versions and should be cleaned up
      // when the version is deleted from Firebase

      // Delete local waveforms
      await _localDataSource.deleteWaveformsForVersion(versionId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete waveforms: $e'));
    }
  }

  @override
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId) {
    // The local data source now handles version filtering internally
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
      // Fire-and-forget upload canonical
      try {
        await _remoteDataSource.uploadCanonical(
          trackId: trackId.value,
          waveform: waveform,
        );
      } catch (_) {}
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to store canonical waveform: $e'));
    }
  }
}

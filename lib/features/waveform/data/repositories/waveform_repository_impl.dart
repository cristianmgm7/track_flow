import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';

@Injectable(as: WaveformRepository)
class WaveformRepositoryImpl implements WaveformRepository {
  final WaveformLocalDataSource _localDataSource;

  WaveformRepositoryImpl({
    required WaveformLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AudioWaveform>> getWaveformByTrackId(
    AudioTrackId trackId,
  ) async {
    try {
      final waveform = await _localDataSource.getWaveformByTrackId(trackId);
      if (waveform == null) {
        return Left(ServerFailure('Waveform not found for track: ${trackId.value}'));
      }
      return Right(waveform);
    } catch (e) {
      return Left(ServerFailure('Failed to get waveform: $e'));
    }
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
  Future<Either<Failure, Unit>> deleteWaveformsForTrack(
    AudioTrackId trackId,
  ) async {
    try {
      await _localDataSource.deleteWaveformsForTrack(trackId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete waveforms: $e'));
    }
  }

  @override
  Stream<AudioWaveform> watchWaveformChanges(AudioTrackId trackId) {
    return _localDataSource.watchWaveformChanges(trackId);
  }
}
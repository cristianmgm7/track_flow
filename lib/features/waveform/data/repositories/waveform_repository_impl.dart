import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart';
import 'package:trackflow/features/waveform/data/services/just_waveform_generator_service.dart';

@Injectable(as: WaveformRepository)
class WaveformRepositoryImpl implements WaveformRepository {
  final WaveformLocalDataSource _localDataSource;
  final WaveformRemoteDataSource _remoteDataSource;
  final WaveformGeneratorService _generatorService;

  WaveformRepositoryImpl({
    required WaveformLocalDataSource localDataSource,
    required WaveformRemoteDataSource remoteDataSource,
    required WaveformGeneratorService generatorService,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _generatorService = generatorService;

  @override
  Future<Either<Failure, AudioWaveform>> getWaveformByTrackId(
    AudioTrackId trackId,
  ) async {
    try {
      final waveform = await _localDataSource.getWaveformByTrackId(trackId);
      if (waveform == null) {
        return Left(
          ServerFailure('Waveform not found for track: ${trackId.value}'),
        );
      }
      return Right(waveform);
    } catch (e) {
      return Left(ServerFailure('Failed to get waveform: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioWaveform>> getOrGenerate({
    required AudioTrackId trackId,
    TrackVersionId? versionId,
    String? audioFilePath,
    required String audioSourceHash,
    required int algorithmVersion,
    int? targetSampleCount,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final local = await _localDataSource.getByKey(
          trackId: trackId,
          versionId: versionId,
          audioSourceHash: audioSourceHash,
          algorithmVersion: algorithmVersion,
          targetSampleCount:
              targetSampleCount ??
              JustWaveformGeneratorService.defaultTargetSampleCount,
        );
        if (local != null) return Right(local);
      }

      // Try remote cache
      final remote = await _remoteDataSource.fetchByKey(
        trackId: trackId,
        versionId: versionId,
        audioSourceHash: audioSourceHash,
        algorithmVersion: algorithmVersion,
        targetSampleCount:
            targetSampleCount ??
            JustWaveformGeneratorService.defaultTargetSampleCount,
      );
      if (remote != null) {
        await _localDataSource.saveWaveformWithKey(
          remote,
          audioSourceHash: audioSourceHash,
          algorithmVersion: algorithmVersion,
        );
        return Right(remote);
      }

      // Generate locally (only if audioFilePath provided)
      if (audioFilePath == null) {
        return Left(
          ServerFailure('Audio file path required to generate waveform'),
        );
      }
      final generatedResult = await _generatorService.generateWaveform(
        trackId,
        audioFilePath,
        targetSampleCount: targetSampleCount,
      );
      return await generatedResult.fold((f) => Left(f), (generated) async {
        await _localDataSource.saveWaveformWithKey(
          generated,
          audioSourceHash: audioSourceHash,
          algorithmVersion: algorithmVersion,
        );
        // fire-and-forget upload
        try {
          await _remoteDataSource.uploadByKey(
            waveform: generated,
            audioSourceHash: audioSourceHash,
            algorithmVersion: algorithmVersion,
          );
        } catch (_) {}
        return Right(generated);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get or generate waveform: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> invalidate({required AudioTrackId trackId}) {
    return deleteWaveformsForTrack(trackId);
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

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
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

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
  Future<Either<Failure, AudioWaveform>> getWaveformByVersionId(
    TrackVersionId versionId,
  ) async {
    try {
      // Use the getByKey method to find waveform by version
      final waveform = await _localDataSource.getByKey(
        versionId: versionId,
        audioSourceHash: '', // Empty string for lookup without hash
        algorithmVersion: 0, // Default algorithm version
        targetSampleCount: 1000, // Default sample count
      );
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
  Future<Either<Failure, AudioWaveform>> getOrGenerate({
    required TrackVersionId versionId,
    String? audioFilePath,
    required String audioSourceHash,
    required int algorithmVersion,
    int? targetSampleCount,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final local = await _localDataSource.getByKey(
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
      final generatedResult = await _generatorService.generateWaveformData(
        audioFilePath,
        targetSampleCount: targetSampleCount,
      );
      return await generatedResult.fold((f) => Left(f), (data) async {
        // Create the AudioWaveform entity with the generated data
        final waveform = AudioWaveform.create(
          versionId: versionId,
          data: data,
          metadata: WaveformMetadata.create(
            amplitudes: data.amplitudes,
            generationMethod: 'just_waveform',
          ),
        );

        await _localDataSource.saveWaveformWithKey(
          waveform,
          audioSourceHash: audioSourceHash,
          algorithmVersion: algorithmVersion,
        );
        // fire-and-forget upload
        try {
          await _remoteDataSource.uploadByKey(
            waveform: waveform,
            audioSourceHash: audioSourceHash,
            algorithmVersion: algorithmVersion,
          );
        } catch (_) {}
        return Right(waveform);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get or generate waveform: $e'));
    }
  }

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
      // The local data source now handles version-specific deletion internally
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
}

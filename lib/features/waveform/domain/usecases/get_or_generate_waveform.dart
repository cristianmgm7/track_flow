import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';

class GetOrGenerateWaveformParams {
  final TrackVersionId versionId;
  final String audioFilePath;
  final String audioSourceHash;
  final int algorithmVersion;
  final int? targetSampleCount;
  final bool forceRefresh;

  GetOrGenerateWaveformParams({
    required this.versionId,
    required this.audioFilePath,
    required this.audioSourceHash,
    required this.algorithmVersion,
    this.targetSampleCount,
    this.forceRefresh = false,
  });
}

@injectable
class GetOrGenerateWaveform {
  final WaveformRepository _repository;
  GetOrGenerateWaveform(this._repository);

  Future<Either<Failure, AudioWaveform>> call(
    GetOrGenerateWaveformParams params,
  ) {
    return _repository.getOrGenerate(
      versionId: params.versionId,
      audioFilePath: params.audioFilePath,
      audioSourceHash: params.audioSourceHash,
      algorithmVersion: params.algorithmVersion,
      targetSampleCount: params.targetSampleCount,
      forceRefresh: params.forceRefresh,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

class GenerateAndStoreWaveformParams {
  final AudioTrackId trackId;
  final TrackVersionId versionId;
  final String audioFilePath;
  final int? targetSampleCount;

  GenerateAndStoreWaveformParams({
    required this.trackId,
    required this.versionId,
    required this.audioFilePath,
    this.targetSampleCount,
  });
}

@injectable
class GenerateAndStoreWaveform {
  final WaveformRepository _repository;
  final WaveformGeneratorService _generator;

  GenerateAndStoreWaveform(this._repository, this._generator);

  Future<Either<Failure, AudioWaveform>> call(
    GenerateAndStoreWaveformParams params,
  ) async {
    final dataEither = await _generator.generateWaveformData(
      params.audioFilePath,
      targetSampleCount: params.targetSampleCount,
    );

    return dataEither.fold((failure) => Left(failure), (data) async {
      final waveform = AudioWaveform.create(
        versionId: params.versionId,
        data: data,
        metadata: WaveformMetadata.create(
          amplitudes: data.amplitudes,
          generationMethod: 'just_waveform',
        ),
      );

      final storeEither = await _repository.storeCanonicalWaveform(
        trackId: params.trackId,
        waveform: waveform,
      );
      return storeEither.fold(
        (failure) => Left(failure),
        (_) => Right(waveform),
      );
    });
  }
}

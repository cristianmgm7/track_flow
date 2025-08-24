import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';

abstract class WaveformGeneratorService {
  Future<Either<Failure, AudioWaveform>> generateWaveform(
    AudioTrackId trackId,
    String audioFilePath, {
    int? targetSampleCount,
  });
}
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';

abstract class WaveformGeneratorService {
  Future<Either<Failure, WaveformData>> generateWaveformData(
    String audioFilePath, {
    int? targetSampleCount,
  });
}

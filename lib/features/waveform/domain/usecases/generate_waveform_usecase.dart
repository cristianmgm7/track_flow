import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart';

class GenerateWaveformParams {
  final AudioTrackId trackId;
  final String audioFilePath;
  final int? targetSampleCount;

  GenerateWaveformParams({
    required this.trackId,
    required this.audioFilePath,
    this.targetSampleCount,
  });
}

@injectable
class GenerateWaveformUseCase {
  final WaveformGeneratorService _generatorService;
  final WaveformRepository _repository;

  GenerateWaveformUseCase({
    required WaveformGeneratorService generatorService,
    required WaveformRepository repository,
  }) : _generatorService = generatorService,
       _repository = repository;

  Future<Either<Failure, AudioWaveform>> call(
    GenerateWaveformParams params,
  ) async {
    // Check if waveform already exists
    final existingResult = await _repository.getWaveformByTrackId(params.trackId);
    
    return existingResult.fold(
      // Waveform doesn't exist, generate it
      (failure) async {
        final generationResult = await _generatorService.generateWaveform(
          params.trackId,
          params.audioFilePath,
          targetSampleCount: params.targetSampleCount,
        );

        return generationResult.fold(
          (generationFailure) => Left(generationFailure),
          (waveform) async {
            // Save the generated waveform
            final saveResult = await _repository.saveWaveform(waveform);
            return saveResult.fold(
              (saveFailure) => Left(saveFailure),
              (_) => Right(waveform),
            );
          },
        );
      },
      // Waveform already exists, return it
      (existingWaveform) async => Right(existingWaveform),
    );
  }
}
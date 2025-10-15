import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../../waveform/domain/services/waveform_generator_service.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Creates a voice memo from a completed recording
@lazySingleton
class CreateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;
  final WaveformGeneratorService _waveformGenerator;

  CreateVoiceMemoUseCase(
    this._repository,
    this._waveformGenerator,
  );

  Future<Either<Failure, VoiceMemo>> call(AudioRecording recording) async {
    // Generate waveform data (non-blocking failure)
    final waveformDataEither = await _waveformGenerator.generateWaveformData(
      recording.localPath,
      targetSampleCount: 80, // Default for voice memos
    );

    // Log if waveform generation fails but continue
    final waveformData = waveformDataEither.fold(
      (failure) {
        AppLogger.warning(
          'Failed to generate waveform for voice memo: ${failure.message}',
          tag: 'CreateVoiceMemoUseCase',
        );
        return null; // Graceful degradation
      },
      (data) {
        AppLogger.info(
          'Successfully generated waveform with ${data.amplitudes.length} samples',
          tag: 'CreateVoiceMemoUseCase',
        );
        return data;
      },
    );

    // Create memo entity with waveform data
    final memo = VoiceMemo.create(
      fileLocalPath: recording.localPath,
      duration: recording.duration,
      waveformData: waveformData,
    );

    // Save to repository
    final result = await _repository.saveMemo(memo);

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(memo),
    );
  }
}

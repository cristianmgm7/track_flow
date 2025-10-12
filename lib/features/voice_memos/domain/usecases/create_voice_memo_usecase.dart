import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Creates a voice memo from a completed recording
@lazySingleton
class CreateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  CreateVoiceMemoUseCase(this._repository);

  Future<Either<Failure, VoiceMemo>> call(AudioRecording recording) async {
    // Create memo entity from recording
    final memo = VoiceMemo.create(
      fileLocalPath: recording.localPath,
      duration: recording.duration,
    );

    // Save to repository
    final result = await _repository.saveMemo(memo);

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(memo),
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/audio_recording.dart';
import '../services/recording_service.dart';

@injectable
class StopRecordingUseCase {
  final RecordingService _recordingService;

  StopRecordingUseCase(this._recordingService);

  Future<Either<Failure, AudioRecording>> call() async {
    return await _recordingService.stopRecording();
  }
}

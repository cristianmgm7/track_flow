import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import '../services/recording_service.dart';

@injectable
class CancelRecordingUseCase {
  final RecordingService _recordingService;

  CancelRecordingUseCase(this._recordingService);

  Future<Either<Failure, Unit>> call() async {
    // RecordingService handles temp file cleanup internally
    return await _recordingService.cancelRecording();
  }
}

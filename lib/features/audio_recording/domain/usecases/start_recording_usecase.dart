import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/file_system_utils.dart';
import '../services/recording_service.dart';

@injectable
class StartRecordingUseCase {
  final RecordingService _recordingService;

  StartRecordingUseCase(this._recordingService);

  Future<Either<Failure, String>> call({
    String? customOutputPath,
  }) async {
    // Check permission first
    final hasPermission = await _recordingService.hasPermission();
    if (!hasPermission) {
      final granted = await _recordingService.requestPermission();
      if (!granted) {
        return Left(PermissionFailure('Microphone permission denied'));
      }
    }

    // Generate output path if not provided
    final outputPath = customOutputPath ?? await _generateOutputPath();

    // Start recording
    return await _recordingService.startRecording(outputPath: outputPath);
  }

  Future<String> _generateOutputPath() async {
    final tempDir = await getTemporaryDirectory();
    final fileName = FileSystemUtils.generateUniqueFilename('.m4a');
    return '${tempDir.path}/$fileName';
  }
}

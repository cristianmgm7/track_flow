import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/audio_recording.dart';
import '../entities/recording_session.dart';

/// Abstract service for audio recording operations
/// This is the primary interface that consumers will use
abstract class RecordingService {
  /// Check if recording permission is available
  Future<bool> hasPermission();

  /// Request recording permission from user
  Future<bool> requestPermission();

  /// Start a new recording session
  /// [outputPath] - Where to save the recording
  /// Returns session ID on success
  Future<Either<Failure, String>> startRecording({
    required String outputPath,
  });

  /// Stop the current recording
  /// Returns the completed AudioRecording on success
  Future<Either<Failure, AudioRecording>> stopRecording();

  /// Pause the current recording
  Future<Either<Failure, Unit>> pauseRecording();

  /// Resume a paused recording
  Future<Either<Failure, Unit>> resumeRecording();

  /// Cancel the current recording (discards the file)
  Future<Either<Failure, Unit>> cancelRecording();

  /// Get current recording session state
  Stream<RecordingSession> get sessionStream;

  /// Check if currently recording
  bool get isRecording;
}

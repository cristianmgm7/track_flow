import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/file_system_utils.dart';
import '../../domain/entities/audio_recording.dart';
import '../../domain/entities/recording_session.dart';
import '../../domain/services/recording_service.dart';

@LazySingleton(as: RecordingService)
class PlatformRecordingService implements RecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  final _sessionController = StreamController<RecordingSession>.broadcast();
  RecordingSession? _currentSession;
  Timer? _elapsedTimer;
  Timer? _amplitudeTimer;

  PlatformRecordingService();

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> requestPermission() async {
    // Record package handles permission request automatically on first recording
    return await _recorder.hasPermission();
  }

  @override
  Future<Either<Failure, String>> startRecording({
    required String outputPath,
  }) async {
    try {
      // Check permission
      if (!await hasPermission()) {
        return Left(PermissionFailure('Microphone permission not granted'));
      }

      // Ensure output directory exists
      final file = File(outputPath);
      await file.parent.create(recursive: true);

      // Start recording with RecordConfig
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,  // M4A format
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: outputPath,
      );

      // Create session
      final sessionId = const Uuid().v4();
      _currentSession = RecordingSession(
        sessionId: sessionId,
        startedAt: DateTime.now(),
        elapsed: Duration.zero,
        state: RecordingState.recording,
        outputPath: outputPath,
      );

      // Start timers
      _startElapsedTimer();
      _startAmplitudeMonitoring();

      _sessionController.add(_currentSession!);

      return Right(sessionId);
    } catch (e) {
      return Left(RecordingFailure('Failed to start recording: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioRecording>> stopRecording() async {
    try {
      if (_currentSession == null) {
        return Left(RecordingFailure('No active recording session'));
      }

      // Stop recording
      final path = await _recorder.stop();
      if (path == null) {
        return Left(RecordingFailure('Recording failed to save'));
      }

      // Stop timers
      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      // Get file size
      final fileSize = await FileSystemUtils.getFileSize(path);

      // Create AudioRecording entity
      final recording = AudioRecording.create(
        localPath: path,
        duration: _currentSession!.elapsed,
        format: AudioFormat.m4a,
        fileSizeBytes: fileSize,
      );

      // Update session state
      _currentSession = _currentSession!.copyWith(
        state: RecordingState.stopped,
      );
      _sessionController.add(_currentSession!);

      // Clear session
      _currentSession = null;

      return Right(recording);
    } catch (e) {
      return Left(RecordingFailure('Failed to stop recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> pauseRecording() async {
    try {
      await _recorder.pause();

      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      _currentSession = _currentSession?.copyWith(
        state: RecordingState.paused,
      );
      _sessionController.add(_currentSession!);

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to pause recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resumeRecording() async {
    try {
      await _recorder.resume();

      _startElapsedTimer();
      _startAmplitudeMonitoring();

      _currentSession = _currentSession?.copyWith(
        state: RecordingState.recording,
      );
      _sessionController.add(_currentSession!);

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to resume recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelRecording() async {
    try {
      await _recorder.stop();

      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      // Delete temporary file
      if (_currentSession != null) {
        await FileSystemUtils.deleteFileIfExists(_currentSession!.outputPath);
      }

      _currentSession = null;
      _sessionController.add(RecordingSession(
        sessionId: '',
        startedAt: DateTime.now(),
        elapsed: Duration.zero,
        state: RecordingState.idle,
        outputPath: '',
      ));

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to cancel recording: $e'));
    }
  }

  @override
  Stream<RecordingSession> get sessionStream => _sessionController.stream;

  @override
  bool get isRecording => _currentSession?.state == RecordingState.recording;

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_currentSession != null) {
        final elapsed = DateTime.now().difference(_currentSession!.startedAt);
        _currentSession = _currentSession!.copyWith(elapsed: elapsed);
        _sessionController.add(_currentSession!);
      }
    });
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (_currentSession != null && isRecording) {
        final amplitude = await _recorder.getAmplitude();
        _currentSession = _currentSession!.copyWith(
          currentAmplitude: amplitude.current.abs(),
        );
        _sessionController.add(_currentSession!);
      }
    });
  }

  void dispose() {
    _elapsedTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    _sessionController.close();
  }
}

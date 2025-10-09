import 'package:equatable/equatable.dart';

/// Represents an active recording session
class RecordingSession extends Equatable {
  final String sessionId;
  final DateTime startedAt;
  final Duration elapsed;
  final RecordingState state;
  final String outputPath;
  final double? currentAmplitude;  // For waveform visualization

  const RecordingSession({
    required this.sessionId,
    required this.startedAt,
    required this.elapsed,
    required this.state,
    required this.outputPath,
    this.currentAmplitude,
  });

  RecordingSession copyWith({
    String? sessionId,
    DateTime? startedAt,
    Duration? elapsed,
    RecordingState? state,
    String? outputPath,
    double? currentAmplitude,
  }) {
    return RecordingSession(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
      state: state ?? this.state,
      outputPath: outputPath ?? this.outputPath,
      currentAmplitude: currentAmplitude ?? this.currentAmplitude,
    );
  }

  @override
  List<Object?> get props => [sessionId, startedAt, elapsed, state, outputPath, currentAmplitude];
}

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

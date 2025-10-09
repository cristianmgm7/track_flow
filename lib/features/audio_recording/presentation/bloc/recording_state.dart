import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_recording.dart';
import '../../domain/entities/recording_session.dart';

sealed class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {
  const RecordingInitial();
}

class RecordingInProgress extends RecordingState {
  final RecordingSession session;

  const RecordingInProgress(this.session);

  @override
  List<Object?> get props => [session];
}

class RecordingPaused extends RecordingState {
  final RecordingSession session;

  const RecordingPaused(this.session);

  @override
  List<Object?> get props => [session];
}

class RecordingCompleted extends RecordingState {
  final AudioRecording recording;

  const RecordingCompleted(this.recording);

  @override
  List<Object?> get props => [recording];
}

class RecordingError extends RecordingState {
  final String message;

  const RecordingError(this.message);

  @override
  List<Object?> get props => [message];
}

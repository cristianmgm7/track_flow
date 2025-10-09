import 'package:equatable/equatable.dart';
import '../../domain/entities/recording_session.dart';

sealed class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecordingRequested extends RecordingEvent {
  final String? customOutputPath;

  const StartRecordingRequested({this.customOutputPath});

  @override
  List<Object?> get props => [customOutputPath];
}

class StopRecordingRequested extends RecordingEvent {
  const StopRecordingRequested();
}

class PauseRecordingRequested extends RecordingEvent {
  const PauseRecordingRequested();
}

class ResumeRecordingRequested extends RecordingEvent {
  const ResumeRecordingRequested();
}

class CancelRecordingRequested extends RecordingEvent {
  const CancelRecordingRequested();
}

class RecordingSessionUpdated extends RecordingEvent {
  final RecordingSession session;

  const RecordingSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}

import 'package:equatable/equatable.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../domain/entities/voice_memo.dart';
import '../../../../core/entities/unique_id.dart';

/// Base event class
abstract class VoiceMemoEvent extends Equatable {
  const VoiceMemoEvent();

  @override
  List<Object?> get props => [];
}

/// Watch all voice memos with reactive updates
class WatchVoiceMemosRequested extends VoiceMemoEvent {
  const WatchVoiceMemosRequested();
}

/// Create memo from completed recording
class CreateVoiceMemoRequested extends VoiceMemoEvent {
  final AudioRecording recording;

  const CreateVoiceMemoRequested(this.recording);

  @override
  List<Object?> get props => [recording];
}

/// Play a voice memo
class PlayVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemo memo;

  const PlayVoiceMemoRequested(this.memo);

  @override
  List<Object?> get props => [memo];
}

/// Update memo title (rename)
class UpdateVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemo memo;
  final String newTitle;

  const UpdateVoiceMemoRequested(this.memo, this.newTitle);

  @override
  List<Object?> get props => [memo, newTitle];
}

/// Delete a memo
class DeleteVoiceMemoRequested extends VoiceMemoEvent {
  final VoiceMemoId memoId;

  const DeleteVoiceMemoRequested(this.memoId);

  @override
  List<Object?> get props => [memoId];
}

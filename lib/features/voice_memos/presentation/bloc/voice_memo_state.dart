import 'package:equatable/equatable.dart';
import '../models/voice_memo_ui_model.dart';

/// Base state class
abstract class VoiceMemoState extends Equatable {
  const VoiceMemoState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VoiceMemoInitial extends VoiceMemoState {
  const VoiceMemoInitial();
}

/// Loading state
class VoiceMemoLoading extends VoiceMemoState {
  const VoiceMemoLoading();
}

/// Memos loaded successfully
class VoiceMemosLoaded extends VoiceMemoState {
  final List<VoiceMemoUiModel> memos;

  const VoiceMemosLoaded(this.memos);

  @override
  List<Object?> get props => [memos];
}

/// Error state
class VoiceMemoError extends VoiceMemoState {
  final String message;

  const VoiceMemoError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Memo action success (for create/update/delete feedback)
class VoiceMemoActionSuccess extends VoiceMemoState {
  final String message;

  const VoiceMemoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

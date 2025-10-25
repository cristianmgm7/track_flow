import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';

abstract class AudioCommentState extends Equatable {
  const AudioCommentState();
  @override
  List<Object?> get props => [];
}

class AudioCommentInitial extends AudioCommentState {
  const AudioCommentInitial();
}

class AudioCommentLoading extends AudioCommentState {
  const AudioCommentLoading();
}

class AudioCommentOperationSuccess extends AudioCommentState {
  final String message;

  const AudioCommentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AudioCommentError extends AudioCommentState {
  final String message;

  const AudioCommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class AudioCommentsLoaded extends AudioCommentState {
  final List<AudioCommentUiModel> comments;
  final List<UserProfileUiModel> collaborators;
  final bool isSyncing;
  final double? syncProgress;

  const AudioCommentsLoaded({
    required this.comments,
    required this.collaborators,
    this.isSyncing = false,
    this.syncProgress,
  });

  AudioCommentsLoaded copyWith({
    List<AudioCommentUiModel>? comments,
    List<UserProfileUiModel>? collaborators,
    bool? isSyncing,
    double? syncProgress,
  }) {
    return AudioCommentsLoaded(
      comments: comments ?? this.comments,
      collaborators: collaborators ?? this.collaborators,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }

  @override
  List<Object?> get props => [comments, collaborators, isSyncing, syncProgress ?? 0.0];
}

// Playback states moved to dedicated CommentAudioCubit

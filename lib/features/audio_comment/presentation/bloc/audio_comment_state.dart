import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

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
  final List<AudioComment> comments;
  const AudioCommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

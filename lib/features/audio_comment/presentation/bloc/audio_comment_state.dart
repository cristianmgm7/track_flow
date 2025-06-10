import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/error/failures.dart';

// Base State
abstract class AudioCommentState extends Equatable {
  @override
  List<Object?> get props => [];
}

// State for watching audio comments
class WatchingAudioCommentsState extends AudioCommentState {
  final List<AudioComment> comments;
  final bool isLoading;
  final Failure? failure;

  WatchingAudioCommentsState({
    required this.comments,
    this.isLoading = false,
    this.failure,
  });

  @override
  List<Object?> get props => [comments, isLoading, failure];
}

// State for adding an audio comment
class AddingAudioCommentState extends AudioCommentState {
  final bool isAdding;
  final Failure? failure;

  AddingAudioCommentState({this.isAdding = false, this.failure});

  @override
  List<Object?> get props => [isAdding, failure];
}

// State for removing an audio comment
class RemovingAudioCommentState extends AudioCommentState {
  final bool isRemoving;
  final Failure? failure;

  RemovingAudioCommentState({this.isRemoving = false, this.failure});

  @override
  List<Object?> get props => [isRemoving, failure];
}

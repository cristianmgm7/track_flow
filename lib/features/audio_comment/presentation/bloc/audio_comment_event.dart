import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddAudioCommentEvent extends AudioCommentEvent {
  final AudioComment comment;

  AddAudioCommentEvent(this.comment);

  @override
  List<Object?> get props => [comment];
}

class DeleteAudioCommentEvent extends AudioCommentEvent {
  final AudioCommentId commentId;

  DeleteAudioCommentEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class WatchCommentsByTrackEvent extends AudioCommentEvent {
  final AudioTrackId trackId;

  WatchCommentsByTrackEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

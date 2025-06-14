import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class AudioCommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final String content;

  AddAudioCommentEvent(this.projectId, this.trackId, this.content);

  @override
  List<Object?> get props => [projectId, trackId, content];
}

class DeleteAudioCommentEvent extends AudioCommentEvent {
  final AudioCommentId commentId;
  final ProjectId projectId;
  final AudioTrackId trackId;

  DeleteAudioCommentEvent(this.commentId, this.projectId, this.trackId);

  @override
  List<Object?> get props => [commentId, projectId, trackId];
}

class WatchCommentsByTrackEvent extends AudioCommentEvent {
  final AudioTrackId trackId;

  WatchCommentsByTrackEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

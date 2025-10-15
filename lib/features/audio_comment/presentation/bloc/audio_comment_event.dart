import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;

  // Audio recording fields
  final String? localAudioPath;
  final Duration? audioDuration;
  final CommentType commentType;

  AddAudioCommentEvent(
    this.projectId,
    this.versionId,
    this.content,
    this.timestamp, {
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
  });

  @override
  List<Object?> get props => [
    projectId,
    versionId,
    content,
    timestamp,
    localAudioPath,
    audioDuration,
    commentType,
  ];
}

class DeleteAudioCommentEvent extends AudioCommentEvent {
  final AudioCommentId commentId;
  final ProjectId projectId;
  final TrackVersionId versionId;

  DeleteAudioCommentEvent(this.commentId, this.projectId, this.versionId);

  @override
  List<Object?> get props => [commentId, projectId, versionId];
}

// Removed legacy track-only watcher and comments-updated event in favor of bundle

class WatchAudioCommentsBundleEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final TrackVersionId versionId;

  WatchAudioCommentsBundleEvent(this.projectId, this.trackId, this.versionId);

  @override
  List<Object?> get props => [projectId, trackId, versionId];
}

// Internal update event removed; now handled with emit.onEach stream handler

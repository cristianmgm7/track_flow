import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart';

abstract class AudioCommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final String content;
  final Duration timestamp;

  AddAudioCommentEvent(
    this.projectId,
    this.trackId,
    this.content,
    this.timestamp,
  );

  @override
  List<Object?> get props => [projectId, trackId, content, timestamp];
}

class DeleteAudioCommentEvent extends AudioCommentEvent {
  final AudioCommentId commentId;
  final ProjectId projectId;
  final AudioTrackId trackId;

  DeleteAudioCommentEvent(this.commentId, this.projectId, this.trackId);

  @override
  List<Object?> get props => [commentId, projectId, trackId];
}

// Removed legacy track-only watcher and comments-updated event in favor of bundle

class WatchAudioCommentsBundleEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final AudioTrackId trackId;

  WatchAudioCommentsBundleEvent(this.projectId, this.trackId);

  @override
  List<Object?> get props => [projectId, trackId];
}

class AudioCommentsBundleUpdated extends AudioCommentEvent {
  final Either<Failure, AudioCommentsBundle> result;
  AudioCommentsBundleUpdated(this.result);

  @override
  List<Object?> get props => [result];
}

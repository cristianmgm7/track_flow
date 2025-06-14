import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class AudioComment extends Equatable {
  final AudioCommentId id;
  final ProjectId projectId;
  final AudioTrackId trackId;
  final UserId createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;

  const AudioComment({
    required this.id,
    required this.projectId,
    required this.trackId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  factory AudioComment.create({
    required ProjectId projectId,
    required AudioTrackId trackId,
    required UserId createdBy,
    required String content,
  }) {
    return AudioComment(
      id: AudioCommentId(),
      projectId: projectId,
      trackId: trackId,
      createdBy: createdBy,
      content: content,
      timestamp: Duration.zero,
      createdAt: DateTime.now(),
    );
  }
  @override
  List<Object> get props => [
    id,
    projectId,
    trackId,
    createdBy,
    content,
    timestamp,
    createdAt,
  ];

  AudioComment copyWith({
    AudioCommentId? id,
    ProjectId? projectId,
    AudioTrackId? trackId,
    UserId? createdBy,
    String? content,
    Duration? timestamp,
    DateTime? createdAt,
  }) {
    return AudioComment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      trackId: trackId ?? this.trackId,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool belongsToProject(Project project) {
    return projectId == project.id;
  }

  bool belongsToTrack(AudioTrack track) {
    return trackId == track.id;
  }
}

import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

/// Type of audio comment
enum CommentType {
  text,    // Text-only comment
  audio,   // Audio-only comment
  hybrid,  // Audio with text transcription/note
}

class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final UserId createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;

  // NEW: Audio recording fields
  final String? audioStorageUrl;      // Firebase Storage URL (null for text comments)
  final String? localAudioPath;       // Local cache path (null until downloaded)
  final Duration? audioDuration;      // Recording duration (null for text comments)
  final CommentType commentType;      // Type of comment

  const AudioComment({
    required AudioCommentId id,
    required this.projectId,
    required this.versionId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    this.audioStorageUrl,
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
  }) : super(id);

  factory AudioComment.create({
    required ProjectId projectId,
    required TrackVersionId versionId,
    required UserId createdBy,
    required String content,
    String? audioStorageUrl,
    String? localAudioPath,
    Duration? audioDuration,
    CommentType commentType = CommentType.text,
  }) {
    return AudioComment(
      id: AudioCommentId(),
      projectId: projectId,
      versionId: versionId,
      createdBy: createdBy,
      content: content,
      timestamp: Duration.zero,
      createdAt: DateTime.now(),
      audioStorageUrl: audioStorageUrl,
      localAudioPath: localAudioPath,
      audioDuration: audioDuration,
      commentType: commentType,
    );
  }

  AudioComment copyWith({
    AudioCommentId? id,
    ProjectId? projectId,
    TrackVersionId? versionId,
    UserId? createdBy,
    String? content,
    Duration? timestamp,
    DateTime? createdAt,
    String? audioStorageUrl,
    String? localAudioPath,
    Duration? audioDuration,
    CommentType? commentType,
  }) {
    return AudioComment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      versionId: versionId ?? this.versionId,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      audioStorageUrl: audioStorageUrl ?? this.audioStorageUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      commentType: commentType ?? this.commentType,
    );
  }

  bool belongsToProject(Project project) {
    return projectId == project.id;
  }

  bool belongsToVersion(TrackVersionId versionId) {
    return this.versionId == versionId;
  }
}

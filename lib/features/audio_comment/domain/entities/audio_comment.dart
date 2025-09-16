import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final UserId createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;

  const AudioComment({
    required AudioCommentId id,
    required this.projectId,
    required this.versionId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  }) : super(id);

  factory AudioComment.create({
    required ProjectId projectId,
    required TrackVersionId versionId,
    required UserId createdBy,
    required String content,
  }) {
    return AudioComment(
      id: AudioCommentId(),
      projectId: projectId,
      versionId: versionId,
      createdBy: createdBy,
      content: content,
      timestamp: Duration.zero,
      createdAt: DateTime.now(),
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
  }) {
    return AudioComment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      versionId: versionId ?? this.versionId,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool belongsToProject(Project project) {
    return projectId == project.id;
  }

  bool belongsToVersion(TrackVersionId versionId) {
    return this.versionId == versionId;
  }
}

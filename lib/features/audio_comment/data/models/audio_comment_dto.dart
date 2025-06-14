import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioCommentDTO {
  final String id;
  final String projectId;
  final String trackId;
  final String createdBy;
  final String content;
  final int timestamp;
  final String createdAt;

  AudioCommentDTO({
    required this.id,
    required this.projectId,
    required this.trackId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  static const String collection = 'audio_comments';

  factory AudioCommentDTO.fromDomain(AudioComment audioComment) {
    return AudioCommentDTO(
      id: audioComment.id.value,
      projectId: audioComment.projectId.value,
      trackId: audioComment.trackId.value,
      createdBy: audioComment.createdBy.value,
      content: audioComment.content,
      timestamp: audioComment.timestamp.inMilliseconds,
      createdAt: audioComment.createdAt.toIso8601String(),
    );
  }

  AudioComment toDomain() {
    return AudioComment(
      id: AudioCommentId.fromUniqueString(id),
      projectId: ProjectId.fromUniqueString(projectId),
      trackId: AudioTrackId.fromUniqueString(trackId),
      createdBy: UserId.fromUniqueString(createdBy),
      content: content,
      timestamp: Duration(milliseconds: timestamp),
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'trackId': trackId,
      'createdBy': createdBy,
      'content': content,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  factory AudioCommentDTO.fromJson(Map<String, dynamic> json) {
    return AudioCommentDTO(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      trackId: json['trackId'] as String,
      createdBy: json['createdBy'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}

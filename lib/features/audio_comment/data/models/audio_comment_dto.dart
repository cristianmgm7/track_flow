import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioCommentDTO {
  final String id;
  final String projectId;
  final String trackId; // stores TrackVersionId for now (pre-schema rename)
  final String createdBy;
  final String content;
  final int timestamp;
  final String createdAt;

  // ⭐ NEW: Sync metadata fields for proper offline-first sync
  final int version;
  final DateTime? lastModified;

  AudioCommentDTO({
    required this.id,
    required this.projectId,
    required this.trackId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    // ⭐ NEW: Sync metadata fields
    this.version = 1,
    this.lastModified,
  });

  static const String collection = 'audio_comments';

  factory AudioCommentDTO.fromDomain(AudioComment audioComment) {
    return AudioCommentDTO(
      id: audioComment.id.value,
      projectId: audioComment.projectId.value,
      trackId: audioComment.versionId.value,
      createdBy: audioComment.createdBy.value,
      content: audioComment.content,
      timestamp: audioComment.timestamp.inMilliseconds,
      createdAt: audioComment.createdAt.toIso8601String(),
      // ⭐ NEW: Include sync metadata for new comments
      version: 1, // Initial version for new comments
      lastModified:
          audioComment.createdAt, // Use createdAt as initial lastModified
    );
  }

  AudioComment toDomain() {
    return AudioComment(
      id: AudioCommentId.fromUniqueString(id),
      projectId: ProjectId.fromUniqueString(projectId),
      versionId: TrackVersionId.fromUniqueString(trackId),
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
      // ⭐ NEW: Include sync metadata in JSON
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
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
      // ⭐ NEW: Parse sync metadata from JSON
      version: json['version'] as int? ?? 1,
      lastModified:
          json['lastModified'] != null
              ? DateTime.tryParse(json['lastModified'] as String)
              : null,
    );
  }
}

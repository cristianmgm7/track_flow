import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioCommentDTO {
  final String id;
  final String projectId;
  final String trackId; // stores TrackVersionId for now (pre-schema rename)
  // Backward-compatible alias: prefer versionId, fallback to trackId on read
  final String createdBy;
  final String content;
  final int timestamp;
  final String createdAt;

  // ⭐ Sync metadata fields for proper offline-first sync
  final bool isDeleted;
  final int version;
  final DateTime? lastModified;

  // ⭐ NEW: Audio recording fields
  final String? audioStorageUrl;
  final String? localAudioPath;
  final int? audioDurationMs;
  final String commentType; // 'text', 'audio', 'hybrid'

  AudioCommentDTO({
    required this.id,
    required this.projectId,
    required this.trackId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    // Sync metadata fields
    this.isDeleted = false,
    this.version = 1,
    this.lastModified,
    // Audio fields
    this.audioStorageUrl,
    this.localAudioPath,
    this.audioDurationMs,
    this.commentType = 'text',
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
      // Include sync metadata for new comments
      version: 1, // Initial version for new comments
      lastModified:
          audioComment.createdAt, // Use createdAt as initial lastModified
      // Audio fields
      audioStorageUrl: audioComment.audioStorageUrl,
      localAudioPath: audioComment.localAudioPath,
      audioDurationMs: audioComment.audioDuration?.inMilliseconds,
      commentType: audioComment.commentType.toString().split('.').last,
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
      // Audio fields
      audioStorageUrl: audioStorageUrl,
      localAudioPath: localAudioPath,
      audioDuration:
          audioDurationMs != null ? Duration(milliseconds: audioDurationMs!) : null,
      commentType: _parseCommentType(commentType),
    );
  }

  static CommentType _parseCommentType(String type) {
    switch (type.toLowerCase()) {
      case 'audio':
        return CommentType.audio;
      case 'hybrid':
        return CommentType.hybrid;
      default:
        return CommentType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'trackId': trackId,
      // During migration also emit versionId for clarity
      'versionId': trackId,
      'createdBy': createdBy,
      'content': content,
      'timestamp': timestamp,
      'createdAt': createdAt,
      // Include sync metadata in JSON
      'isDeleted': isDeleted,
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
      // Audio fields (do NOT serialize localAudioPath - local-only)
      'audioStorageUrl': audioStorageUrl,
      'audioDurationMs': audioDurationMs,
      'commentType': commentType,
    };
  }

  factory AudioCommentDTO.fromJson(Map<String, dynamic> json) {
    final versionId =
        (json['versionId'] as String?) ?? (json['trackId'] as String);

    // Parse lastModified - handle both Timestamp and String types
    DateTime? lastModified;
    if (json['lastModified'] != null) {
      final lastModifiedValue = json['lastModified'];
      if (lastModifiedValue is Timestamp) {
        lastModified = lastModifiedValue.toDate();
      } else if (lastModifiedValue is String) {
        lastModified = DateTime.tryParse(lastModifiedValue);
      }
    }

    return AudioCommentDTO(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      trackId: versionId,
      createdBy: json['createdBy'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      createdAt: json['createdAt'] as String,
      // Parse sync metadata from JSON
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      lastModified: lastModified,
      // Audio fields (with backward compatibility)
      audioStorageUrl: json['audioStorageUrl'] as String?,
      audioDurationMs: json['audioDurationMs'] as int?,
      commentType: json['commentType'] as String? ?? 'text',
    );
  }

  AudioCommentDTO copyWith({
    String? id,
    String? projectId,
    String? trackId,
    String? createdBy,
    String? content,
    int? timestamp,
    String? createdAt,
    bool? isDeleted,
    int? version,
    DateTime? lastModified,
    String? audioStorageUrl,
    String? localAudioPath,
    int? audioDurationMs,
    String? commentType,
  }) {
    return AudioCommentDTO(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      trackId: trackId ?? this.trackId,
      createdBy: createdBy ?? this.createdBy,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      audioStorageUrl: audioStorageUrl ?? this.audioStorageUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      commentType: commentType ?? this.commentType,
    );
  }
}

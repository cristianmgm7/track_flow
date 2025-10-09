import 'package:isar/isar.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';

part 'audio_comment_document.g.dart';

/// Isar-compatible enum for comment types
enum CommentTypeEnum {
  text,
  audio,
  hybrid,
}

@collection
class AudioCommentDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String projectId;

  @Index()
  late String trackId; // stores TrackVersionId for now (pre-schema rename)
  // TODO(migration): add versionId field and migrate; for now trackId holds versionId

  late String createdBy;
  late String content;
  late int timestamp; // Duration in milliseconds
  late DateTime createdAt;

  /// Sync metadata for offline-first functionality
  SyncMetadataDocument? syncMetadata;

  // ⭐ NEW: Audio recording fields
  late String? audioStorageUrl;
  late String? localAudioPath;
  late int? audioDurationMs;

  @enumerated
  late CommentTypeEnum commentType;

  AudioCommentDocument();

  factory AudioCommentDocument.fromDTO(
    AudioCommentDTO dto, {
    SyncMetadataDocument? syncMeta,
  }) {
    return AudioCommentDocument()
      ..id = dto.id
      ..projectId = dto.projectId
      ..trackId = dto.trackId
      ..createdBy = dto.createdBy
      ..content = dto.content
      ..timestamp = dto.timestamp
      ..createdAt = DateTime.parse(dto.createdAt)
      // Use sync metadata from DTO if available (from remote)
      ..syncMetadata =
          syncMeta ??
          SyncMetadataDocument.fromRemote(
            version: dto.version,
            lastModified: dto.lastModified ?? DateTime.parse(dto.createdAt),
          )
      // Audio fields
      ..audioStorageUrl = dto.audioStorageUrl
      ..localAudioPath = dto.localAudioPath
      ..audioDurationMs = dto.audioDurationMs
      ..commentType = _commentTypeFromString(dto.commentType);
  }

  static CommentTypeEnum _commentTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'audio':
        return CommentTypeEnum.audio;
      case 'hybrid':
        return CommentTypeEnum.hybrid;
      default:
        return CommentTypeEnum.text;
    }
  }

  /// Create AudioCommentDocument from remote DTO with sync metadata
  factory AudioCommentDocument.fromRemoteDTO(
    AudioCommentDTO dto, {
    int? version,
    DateTime? lastModified,
  }) {
    return AudioCommentDocument()
      ..id = dto.id
      ..projectId = dto.projectId
      ..trackId = dto.trackId
      ..createdBy = dto.createdBy
      ..content = dto.content
      ..timestamp = dto.timestamp
      ..createdAt = DateTime.parse(dto.createdAt)
      ..syncMetadata = SyncMetadataDocument.fromRemote(
        version: version ?? 1,
        lastModified: lastModified ?? DateTime.now(),
      )
      // Audio fields
      ..audioStorageUrl = dto.audioStorageUrl
      ..localAudioPath = dto.localAudioPath
      ..audioDurationMs = dto.audioDurationMs
      ..commentType = _commentTypeFromString(dto.commentType);
  }

  /// Create AudioCommentDocument for local creation
  factory AudioCommentDocument.forLocalCreation({
    required String id,
    required String projectId,
    required String trackId,
    required String createdBy,
    required String content,
    required int timestamp,
    String? audioStorageUrl,
    String? localAudioPath,
    int? audioDurationMs,
    CommentTypeEnum commentType = CommentTypeEnum.text,
  }) {
    return AudioCommentDocument()
      ..id = id
      ..projectId = projectId
      ..trackId = trackId
      ..createdBy = createdBy
      ..content = content
      ..timestamp = timestamp
      ..createdAt = DateTime.now()
      ..syncMetadata = SyncMetadataDocument.initial()
      // Audio fields
      ..audioStorageUrl = audioStorageUrl
      ..localAudioPath = localAudioPath
      ..audioDurationMs = audioDurationMs
      ..commentType = commentType;
  }

  AudioCommentDTO toDTO() {
    return AudioCommentDTO(
      id: id,
      projectId: projectId,
      trackId: trackId,
      createdBy: createdBy,
      content: content,
      timestamp: timestamp,
      createdAt: createdAt.toIso8601String(),
      // Include sync metadata from document
      version: syncMetadata?.version ?? 1,
      lastModified: syncMetadata?.lastModified ?? createdAt,
      // Audio fields
      audioStorageUrl: audioStorageUrl,
      localAudioPath: localAudioPath,
      audioDurationMs: audioDurationMs,
      commentType: _commentTypeToString(commentType),
    );
  }

  static String _commentTypeToString(CommentTypeEnum type) {
    switch (type) {
      case CommentTypeEnum.audio:
        return 'audio';
      case CommentTypeEnum.hybrid:
        return 'hybrid';
      case CommentTypeEnum.text:
        return 'text';
    }
  }
}

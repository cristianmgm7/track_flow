import 'package:isar/isar.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';

part 'audio_comment_document.g.dart';

@collection
class AudioCommentDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String projectId;

  @Index()
  late String trackId;

  late String createdBy;
  late String content;
  late int timestamp; // Duration in milliseconds
  late DateTime createdAt;

  AudioCommentDocument();

  factory AudioCommentDocument.fromDTO(AudioCommentDTO dto) {
    return AudioCommentDocument()
      ..id = dto.id
      ..projectId = dto.projectId
      ..trackId = dto.trackId
      ..createdBy = dto.createdBy
      ..content = dto.content
      ..timestamp = dto.timestamp
      ..createdAt = DateTime.parse(dto.createdAt);
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
    );
  }
}

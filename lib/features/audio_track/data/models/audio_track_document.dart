import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';

part 'audio_track_document.g.dart';

@collection
class AudioTrackDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;
  late String url;
  late int duration;

  @Index()
  late String projectId;

  late String uploadedBy;
  late DateTime createdAt;
  late String extension;

  AudioTrackDocument();

  factory AudioTrackDocument.fromDTO(AudioTrackDTO dto) {
    return AudioTrackDocument()
      ..id = dto.id.value
      ..name = dto.name
      ..url = dto.url
      ..duration = dto.duration
      ..projectId = dto.projectId.value
      ..uploadedBy = dto.uploadedBy.value
      ..createdAt = dto.createdAt ?? DateTime.now()
      ..extension = dto.extension;
  }

  AudioTrackDTO toDTO() {
    return AudioTrackDTO(
      id: AudioTrackId.fromUniqueString(_cleanId(id)),
      name: name,
      url: url,
      duration: duration,
      projectId: ProjectId.fromUniqueString(_cleanId(projectId)),
      uploadedBy: UserId.fromUniqueString(_cleanId(uploadedBy)),
      createdAt: createdAt,
      extension: extension.isNotEmpty ? extension : '',
    );
  }

  /// Clean ID string by removing wrapper format like "UserId(id)" -> "id"
  String _cleanId(String id) {
    // Remove patterns like "UserId(...)", "AudioTrackId(...)", etc.
    final regex = RegExp(r'^[A-Za-z]+\((.+)\)$');
    final match = regex.firstMatch(id);
    return match?.group(1) ?? id;
  }
}

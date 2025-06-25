import 'package:isar/isar.dart';
import 'package:trackflow/features/playlist/data/models/playlist_dto.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';

@Collection()
class PlaylistDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;
  late List<String> trackIds;
  late String playlistSource;

  PlaylistDocument();

  factory PlaylistDocument.fromDTO(PlaylistDto dto) {
    return PlaylistDocument()
      ..id = dto.id.toString()
      ..name = dto.name
      ..trackIds = dto.trackIds
      ..playlistSource = dto.playlistSource;
  }

  PlaylistDto toDTO() {
    return PlaylistDto(
      id: int.parse(id),
      name: name,
      trackIds: trackIds,
      playlistSource: playlistSource,
    );
  }
}

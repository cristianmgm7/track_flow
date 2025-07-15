import 'package:isar/isar.dart';
import 'package:trackflow/features/playlist/data/models/playlist_dto.dart';
part 'playlist_document.g.dart';

@collection
class PlaylistDocument {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late List<String> trackIds;
  late String playlistSource;

  PlaylistDocument();

  factory PlaylistDocument.fromDTO(PlaylistDto dto) {
    return PlaylistDocument()
      ..uuid = dto.id
      ..name = dto.name
      ..trackIds = dto.trackIds
      ..playlistSource = dto.playlistSource;
  }

  PlaylistDto toDTO() {
    return PlaylistDto(
      id: uuid,
      name: name,
      trackIds: trackIds,
      playlistSource: playlistSource,
    );
  }
}

import 'package:trackflow/core/entities/unique_id.dart';
import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';

class CreatePlaylist {
  final PlaylistRepository repository;

  CreatePlaylist(this.repository);

  Future<void> call(
    String name,
    List<String> trackIds,
    PlaylistSource source,
  ) async {
    final playlist = Playlist(
      id: PlaylistId(),
      name: name,
      trackIds: trackIds,
      playlistSource: source,
    );
    await repository.addPlaylist(playlist);
  }
}

import 'package:trackflow/features/playlist/domain/entities/playlist_id.dart';

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
      id: PlaylistId(_generateId()),
      name: name,
      trackIds: trackIds,
      playlistSource: source,
    );
    await repository.addPlaylist(playlist);
  }

  String _generateId() {
    // Implement a method to generate a unique ID for the playlist
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

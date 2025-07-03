import 'package:trackflow/core/entities/unique_id.dart';
import '../repositories/playlist_repository.dart';

class RemoveTrackFromPlaylist {
  final PlaylistRepository repository;

  RemoveTrackFromPlaylist(this.repository);

  Future<void> call(String playlistId, String trackId) async {
    final playlist = await repository.getPlaylistById(PlaylistId.fromUniqueString(playlistId));
    if (playlist != null) {
      final updatedPlaylist = playlist.copyWith(
        trackIds: List.from(playlist.trackIds)..remove(trackId),
      );
      await repository.updatePlaylist(updatedPlaylist);
    }
  }
}

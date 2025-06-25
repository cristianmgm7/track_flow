import '../repositories/playlist_repository.dart';

class AddTrackToPlaylist {
  final PlaylistRepository repository;

  AddTrackToPlaylist(this.repository);

  Future<void> call(String playlistId, String trackId) async {
    final playlist = await repository.getPlaylistById(playlistId);
    if (playlist != null) {
      final updatedPlaylist = playlist.copyWith(
        trackIds: List.from(playlist.trackIds)..add(trackId),
      );
      await repository.updatePlaylist(updatedPlaylist);
    }
  }
}

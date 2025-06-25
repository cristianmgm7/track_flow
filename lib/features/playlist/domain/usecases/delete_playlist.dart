import '../repositories/playlist_repository.dart';

class DeletePlaylist {
  final PlaylistRepository repository;

  DeletePlaylist(this.repository);

  Future<void> call(String playlistId) async {
    await repository.deletePlaylist(playlistId);
  }
}

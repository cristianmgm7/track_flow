import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<void> addPlaylist(Playlist playlist);
  Future<List<Playlist>> getAllPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String id);
}

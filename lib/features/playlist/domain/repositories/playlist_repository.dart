import 'package:trackflow/core/entities/unique_id.dart';
import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<void> addPlaylist(Playlist playlist);
  Future<List<Playlist>> getAllPlaylists();
  Future<Playlist?> getPlaylistById(PlaylistId id);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(PlaylistId id);
}

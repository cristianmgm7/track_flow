import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';

class GetPlaylists {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  Future<List<Playlist>> call() async {
    return await repository.getAllPlaylists();
  }
}

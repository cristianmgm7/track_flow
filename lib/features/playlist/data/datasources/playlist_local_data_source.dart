import 'package:isar/isar.dart';
import '../models/playlist_dto.dart';

abstract class PlaylistLocalDataSource {
  Future<void> addPlaylist(PlaylistDto playlist);
  Future<List<PlaylistDto>> getAllPlaylists();
  Future<PlaylistDto?> getPlaylistById(String id);
  Future<void> updatePlaylist(PlaylistDto playlist);
  Future<void> deletePlaylist(String id);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  final Isar isar;

  PlaylistLocalDataSourceImpl(this.isar);

  @override
  Future<void> addPlaylist(PlaylistDto playlist) async {
    await isar.writeTxn(() async {
      await isar.playlistDocuments.put(playlist);
    });
  }

  @override
  Future<List<PlaylistDto>> getAllPlaylists() async {
    return await isar.playlistDto.where().findAll();
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String id) async {
    return await isar.playlistDtos.get(id);
  }

  @override
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    await isar.writeTxn(() async {
      await isar.playlistDocuments.put(playlist);
    });
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await isar.writeTxn(() async {
      await isar.playlistDtos.delete(id);
    });
  }
}

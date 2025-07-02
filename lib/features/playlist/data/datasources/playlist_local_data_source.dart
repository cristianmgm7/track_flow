import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/playlist/data/models/playlist_document.dart';
import '../models/playlist_dto.dart';

abstract class PlaylistLocalDataSource {
  Future<void> addPlaylist(PlaylistDto playlist);
  Future<List<PlaylistDto>> getAllPlaylists();
  Future<PlaylistDto?> getPlaylistById(String uuid);
  Future<void> updatePlaylist(PlaylistDto playlist);
  Future<void> deletePlaylist(String uuid);
}

@LazySingleton(as: PlaylistLocalDataSource)
class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  final Isar isar;

  PlaylistLocalDataSourceImpl(this.isar);

  @override
  Future<void> addPlaylist(PlaylistDto playlist) async {
    await isar.writeTxn(() async {
      await isar.playlistDocuments.put(PlaylistDocument.fromDTO(playlist));
    });
  }

  @override
  Future<List<PlaylistDto>> getAllPlaylists() async {
    final docs = await isar.playlistDocuments.where().findAll();
    return docs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String uuid) async {
    final doc =
        await isar.playlistDocuments.filter().uuidEqualTo(uuid).findFirst();
    return doc?.toDTO();
  }

  @override
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    await isar.writeTxn(() async {
      await isar.playlistDocuments.put(PlaylistDocument.fromDTO(playlist));
    });
  }

  @override
  Future<void> deletePlaylist(String uuid) async {
    await isar.writeTxn(() async {
      final doc =
          await isar.playlistDocuments.filter().uuidEqualTo(uuid).findFirst();
      if (doc != null) {
        await isar.playlistDocuments.delete(doc.id);
      }
    });
  }
}

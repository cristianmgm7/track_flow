import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playlist_dto.dart';

abstract class PlaylistRemoteDataSource {
  Future<void> addPlaylist(PlaylistDto playlist);
  Future<List<PlaylistDto>> getAllPlaylists();
  Future<PlaylistDto?> getPlaylistById(String id);
  Future<void> updatePlaylist(PlaylistDto playlist);
  Future<void> deletePlaylist(String id);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final FirebaseFirestore firestore;

  PlaylistRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> addPlaylist(PlaylistDto playlist) async {
    await firestore
        .collection('playlists')
        .doc(playlist.id.toString())
        .set(playlist.toJson());
  }

  @override
  Future<List<PlaylistDto>> getAllPlaylists() async {
    final querySnapshot = await firestore.collection('playlists').get();
    return querySnapshot.docs
        .map((doc) => PlaylistDto.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<PlaylistDto?> getPlaylistById(String id) async {
    final doc = await firestore.collection('playlists').doc(id).get();
    if (doc.exists) {
      return PlaylistDto.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updatePlaylist(PlaylistDto playlist) async {
    await firestore
        .collection('playlists')
        .doc(playlist.id.toString())
        .update(playlist.toJson());
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await firestore.collection('playlists').doc(id).delete();
  }
}

import 'package:isar/isar.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist_id.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_local_data_source.dart';
import '../datasources/playlist_remote_data_source.dart';
import '../models/playlist_dto.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;
  final PlaylistRemoteDataSource remoteDataSource;

  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addPlaylist(Playlist playlist) async {
    final dto = PlaylistDto(
      id: int.tryParse(playlist.id.value) ?? Isar.autoIncrement,
      name: playlist.name,
      trackIds: playlist.trackIds,
      playlistSource: playlist.playlistSource.toString(),
    );
    await localDataSource.addPlaylist(dto);
    await remoteDataSource.addPlaylist(dto);
  }

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final dtos = await localDataSource.getAllPlaylists();
    return dtos
        .map(
          (dto) => Playlist(
            id: PlaylistId(dto.id.toString()),
            name: dto.name,
            trackIds: dto.trackIds,
            playlistSource: PlaylistSource.values.firstWhere(
              (e) => e.toString() == dto.playlistSource,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final dto = await localDataSource.getPlaylistById(id);
    if (dto != null) {
      return Playlist(
        id: PlaylistId(dto.id.toString()),
        name: dto.name,
        trackIds: dto.trackIds,
        playlistSource: PlaylistSource.values.firstWhere(
          (e) => e.toString() == dto.playlistSource,
        ),
      );
    }
    return null;
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final dto = PlaylistDto(
      id: int.tryParse(playlist.id.value) ?? Isar.autoIncrement,
      name: playlist.name,
      trackIds: playlist.trackIds,
      playlistSource: playlist.playlistSource.toString(),
    );
    await localDataSource.updatePlaylist(dto);
    await remoteDataSource.updatePlaylist(dto);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await localDataSource.deletePlaylist(id);
    await remoteDataSource.deletePlaylist(id);
  }
}

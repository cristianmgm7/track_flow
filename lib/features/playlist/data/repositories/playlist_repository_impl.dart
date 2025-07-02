import 'package:injectable/injectable.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_local_data_source.dart';
import '../datasources/playlist_remote_data_source.dart';
import '../models/playlist_dto.dart';

@LazySingleton(as: PlaylistRepository)
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource localDataSource;
  final PlaylistRemoteDataSource remoteDataSource;

  PlaylistRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> addPlaylist(Playlist playlist) async {
    final dto = PlaylistDto.fromDomain(playlist);
    await localDataSource.addPlaylist(dto);
    await remoteDataSource.addPlaylist(dto);
  }

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final dtos = await localDataSource.getAllPlaylists();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final dto = await localDataSource.getPlaylistById(id);
    return dto?.toDomain();
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final dto = PlaylistDto.fromDomain(playlist);
    await localDataSource.updatePlaylist(dto);
    await remoteDataSource.updatePlaylist(dto);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await localDataSource.deletePlaylist(id);
    await remoteDataSource.deletePlaylist(id);
  }
}

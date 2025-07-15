import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

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
    final either = await localDataSource.getAllPlaylists();
    return either.fold(
      (failure) => [], // or handle the failure as needed
      (dtos) => dtos.map((dto) => dto.toDomain()).toList(),
    );
  }

  @override
  Future<Playlist?> getPlaylistById(PlaylistId id) async {
    final either = await localDataSource.getPlaylistById(id.value);
    return either.fold(
      (failure) => null, // or handle the failure as needed
      (dto) => dto?.toDomain(),
    );
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final dto = PlaylistDto.fromDomain(playlist);
    await localDataSource.updatePlaylist(dto);
    await remoteDataSource.updatePlaylist(dto);
  }

  @override
  Future<void> deletePlaylist(PlaylistId id) async {
    await localDataSource.deletePlaylist(id.value);
    await remoteDataSource.deletePlaylist(id.value);
  }
}

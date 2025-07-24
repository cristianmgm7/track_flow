import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, Unit>> addPlaylist(Playlist playlist);
  Future<Either<Failure, List<Playlist>>> getAllPlaylists();
  Future<Either<Failure, Playlist?>> getPlaylistById(PlaylistId id);
  Future<Either<Failure, Unit>> updatePlaylist(Playlist playlist);
  Future<Either<Failure, Unit>> deletePlaylist(PlaylistId id);
}

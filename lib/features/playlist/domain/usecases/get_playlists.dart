import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import '../entities/playlist.dart';
import '../repositories/playlist_repository.dart';

class GetPlaylists {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  Future<Either<Failure, List<Playlist>>> call() async {
    return await repository.getAllPlaylists();
  }
}

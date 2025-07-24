import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import '../repositories/playlist_repository.dart';

class AddTrackToPlaylist {
  final PlaylistRepository repository;

  AddTrackToPlaylist(this.repository);

  Future<Either<Failure, Unit>> call(String playlistId, String trackId) async {
    final playlistResult = await repository.getPlaylistById(PlaylistId.fromUniqueString(playlistId));
    
    return await playlistResult.fold(
      (failure) async => Left(failure),
      (playlist) async {
        if (playlist == null) {
          return Left(DatabaseFailure('Playlist not found: $playlistId'));
        }
        
        final updatedPlaylist = playlist.copyWith(
          trackIds: List.from(playlist.trackIds)..add(trackId),
        );
        
        return await repository.updatePlaylist(updatedPlaylist);
      },
    );
  }
}

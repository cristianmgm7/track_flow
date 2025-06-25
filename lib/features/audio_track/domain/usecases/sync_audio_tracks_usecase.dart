import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';

@lazySingleton
class SyncAudioTracksUseCase {
  final AudioTrackRemoteDataSource remote;
  final AudioTrackLocalDataSource local;
  final ProjectRemoteDataSource projectRemoteDataSource;
  final SessionStorage sessionStorage;

  SyncAudioTracksUseCase(
    this.remote,
    this.local,
    this.projectRemoteDataSource,
    this.sessionStorage,
  );

  Future<void> call() async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      // No user signed in, clear local tracks.
      await local.deleteAllTracks();
      return;
    }

    final projectsEither = await projectRemoteDataSource.getUserProjects(
      userId,
    );
    await projectsEither.fold(
      (failure) async {
        // Handle failure to get projects, maybe log the error.
      },
      (projects) async {
        // Clear existing tracks before caching new ones
        await local.deleteAllTracks();

        if (projects.isEmpty) {
          return;
        }
        final projectIds = projects.map((p) => p.id.value).toList();
        final List<AudioTrackDTO> tracks = await remote.getTracksByProjectIds(
          projectIds,
        );

        for (final track in tracks) {
          await local.cacheTrack(track);
        }
      },
    );
  }
}

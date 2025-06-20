import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

@lazySingleton
class SyncAudioTracksUseCase {
  final AudioTrackRemoteDataSource remote;
  final AudioTrackLocalDataSource local;

  SyncAudioTracksUseCase(this.remote, this.local);

  Future<void> call() async {
    final List<AudioTrackDTO> tracks = await remote.getAllTracks();
    for (final track in tracks) {
      await local.cacheTrack(track);
    }
  }
}

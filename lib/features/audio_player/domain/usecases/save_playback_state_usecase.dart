import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';

@lazySingleton
class SavePlaybackStateUseCase {
  final PlaybackStatePersistence _playbackStatePersistence;

  SavePlaybackStateUseCase(this._playbackStatePersistence);

  Future<Either<Failure, Unit>> call({
    required AudioTrack currentTrack,
    required List<String> queue,
    required int currentIndex,
    required RepeatMode repeatMode,
    required PlaybackQueueMode queueMode,
    required bool isPlaying,
    Playlist? currentPlaylist,
    Duration lastPosition = Duration.zero,
  }) async {
    final persistedState = PersistedPlaybackState(
      currentTrackId: currentTrack.id.value,
      queue: queue,
      currentIndex: currentIndex,
      repeatMode: repeatMode,
      queueMode: queueMode,
      lastPosition: lastPosition,
      playlistId: currentPlaylist?.id,
      wasPlaying: isPlaying,
      lastUpdated: DateTime.now(),
    );

    return await _playbackStatePersistence.savePlaybackState(persistedState);
  }

  Future<Either<Failure, Unit>> savePosition(Duration position) async {
    return await _playbackStatePersistence.savePosition(position);
  }
}
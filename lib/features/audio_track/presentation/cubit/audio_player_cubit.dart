import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerCubit()
    : super(
        AudioPlayerInitial(
          AudioTrack(
            id: AudioTrackId(),
            name: '',
            url: '',
            duration: Duration.zero,
            projectId: ProjectId(),
            uploadedBy: UserId(),
            createdAt: DateTime.now(),
          ),
        ),
      );

  Future<void> play(AudioTrack track) async {
    try {
      await _player.setUrl(track.url);
      await _player.play();
      emit(AudioPlayerPlaying(track));
    } catch (e) {
      emit(AudioPlayerError("Failed to play track", state.track));
    }
  }

  Future<void> pause() async {
    await _player.pause();
    emit(AudioPlayerPaused(state.track));
  }

  Future<void> resume() async {
    await _player.play();
    emit(AudioPlayerPlaying(state.track));
  }

  Future<void> stop() async {
    await _player.stop();
    emit(AudioPlayerStopped(state.track));
  }

  AudioPlayer get player => _player;

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }
}

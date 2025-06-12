import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerCubit() : super(AudioPlayerInitial());

  Future<void> play(String url) async {
    debugPrint('play: $url');
    try {
      await _player.setUrl(url);
      await _player.play();
      emit(AudioPlayerPlaying(url));
    } catch (e) {
      emit(AudioPlayerError("Failed to play track"));
    }
  }

  Future<void> pause() async {
    await _player.pause();
    emit(AudioPlayerPaused());
  }

  Future<void> resume() async {
    await _player.play();
    emit(AudioPlayerPlaying(state.url));
  }

  Future<void> stop() async {
    await _player.stop();
    emit(AudioPlayerStopped());
  }

  AudioPlayer get player => _player;

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }
}

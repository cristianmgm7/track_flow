import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  AudioPlayerBloc() : super(AudioPlayerIdle()) {
    on<PlayAudioRequested>(_onPlayAudioRequested);
    on<PauseAudioRequested>(_onPauseAudioRequested);
    on<ResumeAudioRequested>(_onResumeAudioRequested);
    on<StopAudioRequested>(_onStopAudioRequested);
    on<ChangeVisualContext>(_onChangeVisualContext);
  }

  Future<void> _onPlayAudioRequested(
    PlayAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerLoading(event.source, event.visualContext));
    await _player.setUrl(event.source.track.url);
    await _player.play();
    emit(AudioPlayerPlaying(event.source, event.visualContext));
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _player.pause();
    emit(AudioPlayerPaused(state.source, state.visualContext));
  }

  Future<void> _onResumeAudioRequested(
    ResumeAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _player.play();
    emit(AudioPlayerPlaying(state.source, state.visualContext));
  }

  Future<void> _onStopAudioRequested(
    StopAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _player.stop();
    emit(AudioPlayerIdle());
  }

  void _onChangeVisualContext(
    ChangeVisualContext event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state is AudioPlayerActiveState) {
      emit(
        (state as AudioPlayerActiveState).copyWith(
          visualContext: event.visualContext,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }
}

Duration getCurrentPosition(AudioPlayerBloc bloc) {
  return bloc.player.position;
}

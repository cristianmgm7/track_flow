import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final PlaybackService playbackService;
  final GetCachedAudioPath getCachedAudioPath;

  // Playback queue state
  List<String> _queue = [];
  int _currentIndex = 0;
  Playlist? _currentPlaylist;

  // TODO: Inyección de repositorio de tracks para obtener AudioTrack por id
  // final AudioTrackRepository audioTrackRepository;

  AudioPlayerBloc(this.playbackService, this.getCachedAudioPath)
    : super(AudioPlayerIdle()) {
    on<PlayAudioRequested>(_onPlayAudioRequested);
    on<PauseAudioRequested>(_onPauseAudioRequested);
    on<ResumeAudioRequested>(_onResumeAudioRequested);
    on<StopAudioRequested>(_onStopAudioRequested);
    on<ChangeVisualContext>(_onChangeVisualContext);
    on<PlayPlaylistRequested>(_onPlayPlaylistRequested);
  }

  @override
  void onEvent(AudioPlayerEvent event) {
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<AudioPlayerEvent, AudioPlayerState> transition) {
    super.onTransition(transition);
  }

  Future<void> _onPlayAudioRequested(
    PlayAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(
      AudioPlayerLoading(
        event.source,
        event.visualContext,
        event.track,
        event.collaborator,
      ),
    );
    final path = await getCachedAudioPath(event.track.url);
    await playbackService.play(url: path);
    emit(
      AudioPlayerPlaying(
        event.source,
        event.visualContext,
        event.track,
        event.collaborator,
      ),
    );
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await playbackService.pause();
    if (state is AudioPlayerActiveState) {
      final s = state as AudioPlayerActiveState;
      emit(
        AudioPlayerPaused(s.source, s.visualContext, s.track, s.collaborator),
      );
    }
  }

  Future<void> _onResumeAudioRequested(
    ResumeAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await playbackService.resume();
    if (state is AudioPlayerActiveState) {
      final s = state as AudioPlayerActiveState;
      emit(
        AudioPlayerPlaying(s.source, s.visualContext, s.track, s.collaborator),
      );
    }
  }

  Future<void> _onStopAudioRequested(
    StopAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await playbackService.stop();
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

  Future<void> _onPlayPlaylistRequested(
    PlayPlaylistRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    _queue = event.playlist.trackIds;
    _currentIndex = event.startIndex;
    _currentPlaylist = event.playlist;

    // TODO: Obtener el AudioTrack real por id (aquí simulado)
    final trackId = _queue[_currentIndex];
    final track = await _getAudioTrackById(trackId); // Implementa este método
    // TODO: Obtener el colaborador/uploader si es necesario
    final collaborator = await _getCollaboratorForTrack(
      track,
    ); // Implementa este método

    emit(
      AudioPlayerLoading(
        PlaybackSource(type: PlaybackSourceType.track),
        PlayerVisualContext.miniPlayer,
        track,
        collaborator,
      ),
    );

    await playbackService.play(url: track.url);

    emit(
      AudioPlayerPlaying(
        PlaybackSource(type: PlaybackSourceType.track),
        PlayerVisualContext.miniPlayer,
        track,
        collaborator,
      ),
    );
  }

  // Métodos simulados para obtener AudioTrack y colaborador
  Future<AudioTrack> _getAudioTrackById(String id) async {
    // TODO: Inyecta y usa tu repositorio real de tracks
    throw UnimplementedError('Implementa la obtención de AudioTrack por id');
  }

  Future<dynamic> _getCollaboratorForTrack(AudioTrack track) async {
    // TODO: Implementa la lógica para obtener el colaborador
    throw UnimplementedError(
      'Implementa la obtención de colaborador para el track',
    );
  }

  @override
  Future<void> close() {
    playbackService.dispose();
    return super.close();
  }

  Stream<Duration> get positionStream => playbackService.positionStream;
  Stream<Duration?> get durationStream => playbackService.durationStream;
}

Duration getCurrentPosition(AudioPlayerBloc bloc) {
  // Suponiendo que playbackService tiene un getter para la posición actual
  // Aquí podrías suscribirte al stream o exponer un método en la interfaz
  // Por ahora, retornamos Duration.zero como placeholder
  return Duration.zero;
}

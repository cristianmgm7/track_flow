import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_player/domain/usecases/play_audio_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/pause_audio_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/resume_audio_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/stop_audio_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/play_playlist_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_next_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/skip_to_previous_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/toggle_shuffle_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/toggle_repeat_mode_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/seek_to_position_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/save_playback_state_usecase.dart';
import 'package:trackflow/features/audio_player/domain/usecases/restore_playback_state_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'dart:async';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final PlaybackService playbackService;
  final PlayAudioUseCase _playAudioUseCase;
  final PauseAudioUseCase _pauseAudioUseCase;
  final ResumeAudioUseCase _resumeAudioUseCase;
  final StopAudioUseCase _stopAudioUseCase;
  final PlayPlaylistUseCase _playPlaylistUseCase;
  final SkipToNextUseCase _skipToNextUseCase;
  final SkipToPreviousUseCase _skipToPreviousUseCase;
  final ToggleShuffleUseCase _toggleShuffleUseCase;
  final ToggleRepeatModeUseCase _toggleRepeatModeUseCase;
  final SeekToPositionUseCase _seekToPositionUseCase;
  final SavePlaybackStateUseCase _savePlaybackStateUseCase;
  final RestorePlaybackStateUseCase _restorePlaybackStateUseCase;

  // Playback queue state
  List<String> _queue = [];
  int _currentIndex = 0;
  Playlist? _currentPlaylist;
  RepeatMode _repeatMode = RepeatMode.none;
  PlaybackQueueMode _queueMode = PlaybackQueueMode.normal;
  List<String> _shuffledQueue = [];
  Timer? _positionSaveTimer;

  AudioPlayerBloc(
    this.playbackService,
    this._playAudioUseCase,
    this._pauseAudioUseCase,
    this._resumeAudioUseCase,
    this._stopAudioUseCase,
    this._playPlaylistUseCase,
    this._skipToNextUseCase,
    this._skipToPreviousUseCase,
    this._toggleShuffleUseCase,
    this._toggleRepeatModeUseCase,
    this._seekToPositionUseCase,
    this._savePlaybackStateUseCase,
    this._restorePlaybackStateUseCase,
  ) : super(const AudioPlayerIdle()) {
    on<PlayAudioRequested>(_onPlayAudioRequested);
    on<PauseAudioRequested>(_onPauseAudioRequested);
    on<ResumeAudioRequested>(_onResumeAudioRequested);
    on<StopAudioRequested>(_onStopAudioRequested);
    on<ChangeVisualContext>(_onChangeVisualContext);
    on<PlayPlaylistRequested>(_onPlayPlaylistRequested);
    on<SkipToNextRequested>(_onSkipToNextRequested);
    on<SkipToPreviousRequested>(_onSkipToPreviousRequested);
    on<ToggleShuffleRequested>(_onToggleShuffleRequested);
    on<ToggleRepeatModeRequested>(_onToggleRepeatModeRequested);
    on<SeekToPositionRequested>(_onSeekToPositionRequested);
    on<RestorePlaybackStateRequested>(_onRestorePlaybackStateRequested);
    on<SavePlaybackStateRequested>(_onSavePlaybackStateRequested);
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
    // Initialize single track queue
    _queue = [event.track.id.value];
    _currentIndex = 0;

    emit(
      AudioPlayerLoading(
        event.source,
        event.visualContext,
        event.track,
        event.collaborator,
        _queue,
        _currentIndex,
        _repeatMode,
        _queueMode,
      ),
    );

    final result = await _playAudioUseCase(event.track);
    result.fold(
      (failure) {
        // Handle error - could emit error state
      },
      (playResult) {
        _startPositionSaveTimer();
        emit(
          AudioPlayerPlaying(
            event.source,
            event.visualContext,
            playResult.track,
            playResult.collaborator,
            _queue,
            _currentIndex,
            _repeatMode,
            _queueMode,
          ),
        );
        _saveCurrentState();
      },
    );
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _pauseAudioUseCase();
    _stopPositionSaveTimer();

    if (state is AudioPlayerActiveState) {
      final s = state as AudioPlayerActiveState;
      emit(
        AudioPlayerPaused(
          s.source,
          s.visualContext,
          s.track,
          s.collaborator,
          s.queue,
          s.currentIndex,
          s.repeatMode,
          s.queueMode,
        ),
      );
      _saveCurrentState();
    }
  }

  Future<void> _onResumeAudioRequested(
    ResumeAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _resumeAudioUseCase();
    _startPositionSaveTimer();

    if (state is AudioPlayerActiveState) {
      final s = state as AudioPlayerActiveState;
      emit(
        AudioPlayerPlaying(
          s.source,
          s.visualContext,
          s.track,
          s.collaborator,
          s.queue,
          s.currentIndex,
          s.repeatMode,
          s.queueMode,
        ),
      );
    }
  }

  Future<void> _onStopAudioRequested(
    StopAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _stopAudioUseCase();
    _stopPositionSaveTimer();
    _queue.clear();
    _currentIndex = 0;
    emit(const AudioPlayerIdle());
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
    _currentPlaylist = event.playlist;

    final result = await _playPlaylistUseCase(
      playlist: event.playlist,
      startIndex: event.startIndex,
      queueMode: _queueMode,
    );

    result.fold(
      (failure) {
        // Handle error - could emit error state
      },
      (playlistResult) {
        _queue = playlistResult.queue;
        _currentIndex = playlistResult.currentIndex;
        _shuffledQueue = playlistResult.shuffledQueue;

        emit(
          AudioPlayerLoading(
            const PlaybackSource(type: PlaybackSourceType.track),
            PlayerVisualContext.miniPlayer,
            playlistResult.track,
            playlistResult.collaborator,
            _queue,
            _currentIndex,
            _repeatMode,
            _queueMode,
          ),
        );

        emit(
          AudioPlayerPlaying(
            const PlaybackSource(type: PlaybackSourceType.track),
            PlayerVisualContext.miniPlayer,
            playlistResult.track,
            playlistResult.collaborator,
            _queue,
            _currentIndex,
            _repeatMode,
            _queueMode,
          ),
        );
      },
    );
  }

  // Queue navigation methods
  Future<void> _onSkipToNextRequested(
    SkipToNextRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_queue.isEmpty) return;

    final result = await _skipToNextUseCase(
      queue: _queue,
      shuffledQueue: _shuffledQueue,
      currentIndex: _currentIndex,
      repeatMode: _repeatMode,
      queueMode: _queueMode,
    );

    result.fold(
      (failure) {
        // Handle error
      },
      (skipResult) {
        if (skipResult != null) {
          _currentIndex = skipResult.newIndex;
          _emitPlayingState(emit, skipResult.track, skipResult.collaborator);
        }
      },
    );
  }

  Future<void> _onSkipToPreviousRequested(
    SkipToPreviousRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_queue.isEmpty) return;

    final result = await _skipToPreviousUseCase(
      queue: _queue,
      shuffledQueue: _shuffledQueue,
      currentIndex: _currentIndex,
      repeatMode: _repeatMode,
      queueMode: _queueMode,
    );

    result.fold(
      (failure) {
        // Handle error
      },
      (skipResult) {
        if (skipResult != null) {
          _currentIndex = skipResult.newIndex;
          _emitPlayingState(emit, skipResult.track, skipResult.collaborator);
        }
      },
    );
  }

  void _onToggleShuffleRequested(
    ToggleShuffleRequested event,
    Emitter<AudioPlayerState> emit,
  ) {
    final result = _toggleShuffleUseCase(
      currentMode: _queueMode,
      queue: _queue,
    );

    _queueMode = result.newMode;
    _shuffledQueue = result.shuffledQueue;

    _emitCurrentStateWithUpdatedMode(emit);
  }

  void _onToggleRepeatModeRequested(
    ToggleRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) {
    _repeatMode = _toggleRepeatModeUseCase(_repeatMode);
    _emitCurrentStateWithUpdatedMode(emit);
  }

  Future<void> _onSeekToPositionRequested(
    SeekToPositionRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _seekToPositionUseCase(event.position);
  }

  // Helper methods
  void _emitPlayingState(
    Emitter<AudioPlayerState> emit,
    AudioTrack track,
    UserProfile collaborator,
  ) {
    if (state is AudioPlayerActiveState) {
      final currentState = state as AudioPlayerActiveState;
      emit(
        AudioPlayerPlaying(
          currentState.source,
          currentState.visualContext,
          track,
          collaborator,
          _queue,
          _currentIndex,
          _repeatMode,
          _queueMode,
        ),
      );
    }
  }

  List<String> get _currentQueue =>
      _queueMode == PlaybackQueueMode.shuffle ? _shuffledQueue : _queue;

  bool get hasNext {
    if (_repeatMode == RepeatMode.single) return true;
    if (_currentIndex + 1 < _currentQueue.length) return true;
    return _repeatMode == RepeatMode.queue;
  }

  bool get hasPrevious {
    if (_currentIndex > 0) return true;
    return _repeatMode == RepeatMode.queue;
  }

  void _emitCurrentStateWithUpdatedMode(Emitter<AudioPlayerState> emit) {
    if (state is AudioPlayerActiveState) {
      final currentState = state as AudioPlayerActiveState;
      emit(
        currentState.copyWith(
          queue: _queue,
          currentIndex: _currentIndex,
          repeatMode: _repeatMode,
          queueMode: _queueMode,
        ),
      );
      _saveCurrentState();
    }
  }

  // Persistence methods
  Future<void> _onRestorePlaybackStateRequested(
    RestorePlaybackStateRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _restorePlaybackStateUseCase();
    result.fold(
      (failure) => null, // Ignore restore failures
      (restoreResult) {
        if (restoreResult != null) {
          _queue = restoreResult.queue;
          _currentIndex = restoreResult.currentIndex;
          _repeatMode = restoreResult.repeatMode;
          _queueMode = restoreResult.queueMode;
          _shuffledQueue = restoreResult.shuffledQueue;

          // Don't auto-play, just restore to paused state
          emit(
            AudioPlayerPaused(
              const PlaybackSource(type: PlaybackSourceType.track),
              PlayerVisualContext.miniPlayer,
              restoreResult.track,
              restoreResult.collaborator,
              _queue,
              _currentIndex,
              _repeatMode,
              _queueMode,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSavePlaybackStateRequested(
    SavePlaybackStateRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _saveCurrentState();
  }

  Future<void> _saveCurrentState() async {
    if (state is AudioPlayerActiveState) {
      final currentState = state as AudioPlayerActiveState;
      await _savePlaybackStateUseCase(
        currentTrack: currentState.track,
        queue: _queue,
        currentIndex: _currentIndex,
        repeatMode: _repeatMode,
        queueMode: _queueMode,
        isPlaying: state is AudioPlayerPlaying,
        currentPlaylist: _currentPlaylist,
      );
    }
  }

  void _startPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (state is AudioPlayerPlaying) {
        // Save position every 5 seconds during playback
        try {
          final position = await positionStream.first.timeout(
            const Duration(milliseconds: 100),
          );
          await _savePlaybackStateUseCase.savePosition(position);
        } catch (e) {
          // Ignore position save errors
        }
      }
    });
  }

  void _stopPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
  }

  @override
  Future<void> close() {
    _stopPositionSaveTimer();
    playbackService.dispose();
    return super.close();
  }

  Stream<Duration> get positionStream => playbackService.positionStream;
  Stream<Duration?> get durationStream => playbackService.durationStream;

  // Public getters for current state
  List<String> get currentQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  RepeatMode get repeatMode => _repeatMode;
  PlaybackQueueMode get queueMode => _queueMode;
}

Duration getCurrentPosition(AudioPlayerBloc bloc) {
  // Suponiendo que playbackService tiene un getter para la posición actual
  // Aquí podrías suscribirte al stream o exponer un método en la interfaz
  // Por ahora, retornamos Duration.zero como placeholder
  return Duration.zero;
}

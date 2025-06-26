import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'dart:async';
import 'dart:math';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final PlaybackService playbackService;
  final GetCachedAudioPath getCachedAudioPath;
  final AudioTrackRepository audioTrackRepository;
  final UserProfileRepository userProfileRepository;
  final AudioSourceResolver audioSourceResolver;
  final PlaybackStatePersistence playbackStatePersistence;

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
    this.getCachedAudioPath,
    this.audioTrackRepository,
    this.userProfileRepository,
    this.audioSourceResolver,
    this.playbackStatePersistence,
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
    
    final pathResult = await audioSourceResolver.resolveAudioSource(event.track.url);
    final path = pathResult.getOrElse(() => event.track.url);
    await playbackService.play(url: path);
    
    _startPositionSaveTimer();
    
    emit(
      AudioPlayerPlaying(
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
    
    _saveCurrentState();
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await playbackService.pause();
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
    await playbackService.resume();
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
    await playbackService.stop();
    _stopPositionSaveTimer();
    _queue.clear();
    _currentIndex = 0;
    await playbackStatePersistence.clearPlaybackState();
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
    _queue = event.playlist.trackIds;
    _currentIndex = event.startIndex;
    _currentPlaylist = event.playlist;
    _generateShuffledQueue();

    final trackId = _queue[_currentIndex];
    final track = await _getAudioTrackById(trackId);
    final collaborator = await _getCollaboratorForTrack(track);

    emit(
      AudioPlayerLoading(
        const PlaybackSource(type: PlaybackSourceType.track),
        PlayerVisualContext.miniPlayer,
        track,
        collaborator,
        _queue,
        _currentIndex,
        _repeatMode,
        _queueMode,
      ),
    );

    final pathResult = await audioSourceResolver.resolveAudioSource(track.url);
    final path = pathResult.getOrElse(() => track.url);
    await playbackService.play(url: path);

    emit(
      AudioPlayerPlaying(
        const PlaybackSource(type: PlaybackSourceType.track),
        PlayerVisualContext.miniPlayer,
        track,
        collaborator,
        _queue,
        _currentIndex,
        _repeatMode,
        _queueMode,
      ),
    );
  }

  // Queue navigation methods
  Future<void> _onSkipToNextRequested(
    SkipToNextRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_queue.isEmpty) return;
    
    final nextIndex = _getNextTrackIndex();
    if (nextIndex == -1) return; // No next track available
    
    await _playTrackAtIndex(nextIndex, emit);
  }

  Future<void> _onSkipToPreviousRequested(
    SkipToPreviousRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_queue.isEmpty) return;
    
    final previousIndex = _getPreviousTrackIndex();
    if (previousIndex == -1) return; // No previous track available
    
    await _playTrackAtIndex(previousIndex, emit);
  }

  void _onToggleShuffleRequested(
    ToggleShuffleRequested event,
    Emitter<AudioPlayerState> emit,
  ) {
    _queueMode = _queueMode == PlaybackQueueMode.normal 
        ? PlaybackQueueMode.shuffle 
        : PlaybackQueueMode.normal;
    
    if (_queueMode == PlaybackQueueMode.shuffle) {
      _generateShuffledQueue();
    }
    
    _emitCurrentStateWithUpdatedMode(emit);
  }

  void _onToggleRepeatModeRequested(
    ToggleRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.single;
        break;
      case RepeatMode.single:
        _repeatMode = RepeatMode.queue;
        break;
      case RepeatMode.queue:
        _repeatMode = RepeatMode.none;
        break;
    }
    
    _emitCurrentStateWithUpdatedMode(emit);
  }

  Future<void> _onSeekToPositionRequested(
    SeekToPositionRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await playbackService.seek(event.position);
  }

  // Helper methods
  Future<AudioTrack> _getAudioTrackById(String id) async {
    final result = await audioTrackRepository.getTrackById(AudioTrackId.fromUniqueString(id));
    return result.fold(
      (failure) => throw Exception('Failed to get track: $failure'),
      (track) => track,
    );
  }

  Future<UserProfile> _getCollaboratorForTrack(AudioTrack track) async {
    final result = await userProfileRepository.getUserProfilesByIds([track.uploadedBy.value]);
    return result.fold(
      (failure) => throw Exception('Failed to get collaborator: $failure'),
      (profiles) => profiles.isNotEmpty 
          ? profiles.first 
          : throw Exception('Collaborator not found'),
    );
  }

  void _generateShuffledQueue() {
    if (_queue.isEmpty) return;
    
    _shuffledQueue = List.from(_queue);
    _shuffledQueue.shuffle(Random());
  }

  List<String> get _currentQueue => 
      _queueMode == PlaybackQueueMode.shuffle ? _shuffledQueue : _queue;

  int _getNextTrackIndex() {
    if (_repeatMode == RepeatMode.single) {
      return _currentIndex; // Same track
    }
    
    final queue = _currentQueue;
    final nextIndex = _currentIndex + 1;
    
    if (nextIndex < queue.length) {
      return nextIndex;
    } else if (_repeatMode == RepeatMode.queue) {
      return 0; // Loop back to start
    }
    
    return -1; // End of queue, no repeat
  }

  int _getPreviousTrackIndex() {
    final queue = _currentQueue;
    final previousIndex = _currentIndex - 1;
    
    if (previousIndex >= 0) {
      return previousIndex;
    } else if (_repeatMode == RepeatMode.queue) {
      return queue.length - 1; // Loop to end
    }
    
    return -1; // Beginning of queue
  }

  Future<void> _playTrackAtIndex(
    int index,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (index < 0 || index >= _currentQueue.length) return;
    
    _currentIndex = index;
    final trackId = _currentQueue[index];
    
    try {
      final track = await _getAudioTrackById(trackId);
      final collaborator = await _getCollaboratorForTrack(track);
      
      if (state is AudioPlayerActiveState) {
        final currentState = state as AudioPlayerActiveState;
        
        emit(
          AudioPlayerLoading(
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
        
        final pathResult = await audioSourceResolver.resolveAudioSource(track.url);
        final path = pathResult.getOrElse(() => track.url);
        await playbackService.play(url: path);
        
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
    } catch (e) {
      // Handle error - could emit error state or skip to next track
    }
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
    final result = await playbackStatePersistence.restorePlaybackState();
    result.fold(
      (failure) => null, // Ignore restore failures
      (persistedState) async {
        if (persistedState != null && persistedState.queue.isNotEmpty) {
          _queue = persistedState.queue;
          _currentIndex = persistedState.currentIndex;
          _repeatMode = persistedState.repeatMode;
          _queueMode = persistedState.queueMode;
          _generateShuffledQueue();

          if (persistedState.currentTrackId != null) {
            try {
              final track = await _getAudioTrackById(persistedState.currentTrackId!);
              final collaborator = await _getCollaboratorForTrack(track);

              // Don't auto-play, just restore to paused state with position
              emit(
                AudioPlayerPaused(
                  const PlaybackSource(type: PlaybackSourceType.track),
                  PlayerVisualContext.miniPlayer,
                  track,
                  collaborator,
                  _queue,
                  _currentIndex,
                  _repeatMode,
                  _queueMode,
                ),
              );

              // Optionally seek to last position when user resumes
              if (persistedState.lastPosition > Duration.zero) {
                await playbackService.seek(persistedState.lastPosition);
              }
            } catch (e) {
              // Handle error - track might not exist anymore
            }
          }
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
      final persistedState = PersistedPlaybackState(
        currentTrackId: currentState.track.id.value,
        queue: _queue,
        currentIndex: _currentIndex,
        repeatMode: _repeatMode,
        queueMode: _queueMode,
        lastPosition: Duration.zero, // Could get from position stream
        playlistId: _currentPlaylist?.id,
        wasPlaying: state is AudioPlayerPlaying,
        lastUpdated: DateTime.now(),
      );

      await playbackStatePersistence.savePlaybackState(persistedState);
    }
  }

  void _startPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (state is AudioPlayerPlaying) {
          // Save position every 5 seconds during playback
          try {
            final position = await positionStream.first.timeout(
              const Duration(milliseconds: 100),
            );
            await playbackStatePersistence.savePosition(position);
          } catch (e) {
            // Ignore position save errors
          }
        }
      },
    );
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
  bool get hasNext => _getNextTrackIndex() != -1;
  bool get hasPrevious => _getPreviousTrackIndex() != -1;
}

Duration getCurrentPosition(AudioPlayerBloc bloc) {
  // Suponiendo que playbackService tiene un getter para la posición actual
  // Aquí podrías suscribirte al stream o exponer un método en la interfaz
  // Por ahora, retornamos Duration.zero como placeholder
  return Duration.zero;
}

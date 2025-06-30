import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/playback_session.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/audio_failure.dart';
import '../../domain/services/audio_playback_service.dart';
import '../../domain/usecases/play_audio_usecase.dart';
import '../../domain/usecases/play_playlist_usecase.dart';
import '../../domain/usecases/pause_audio_usecase.dart';
import '../../domain/usecases/resume_audio_usecase.dart';
import '../../domain/usecases/stop_audio_usecase.dart';
import '../../domain/usecases/skip_to_next_usecase.dart';
import '../../domain/usecases/skip_to_previous_usecase.dart';
import '../../domain/usecases/seek_to_position_usecase.dart';
import '../../domain/usecases/toggle_shuffle_usecase.dart';
import '../../domain/usecases/toggle_repeat_mode_usecase.dart';
import '../../domain/usecases/set_volume_usecase.dart';
import '../../domain/usecases/set_playback_speed_usecase.dart';
import '../../domain/usecases/save_playback_state_usecase.dart';
import '../../domain/usecases/restore_playback_state_usecase.dart';

import 'audio_player_event.dart';
import 'audio_player_state.dart';

/// Pure audio player BLoC - ONLY audio operations
/// NO: UserProfile, ProjectId, collaborators, or business context
/// Responsibilities:
/// - Audio playback control (play, pause, resume, stop, seek)
/// - Queue management (next, previous, shuffle, repeat)
/// - Settings management (volume, speed)
/// - State persistence and restoration
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc({
    required PlayAudioUseCase playAudioUseCase,
    required PlayPlaylistUseCase playPlaylistUseCase,
    required PauseAudioUseCase pauseAudioUseCase,
    required ResumeAudioUseCase resumeAudioUseCase,
    required StopAudioUseCase stopAudioUseCase,
    required SkipToNextUseCase skipToNextUseCase,
    required SkipToPreviousUseCase skipToPreviousUseCase,
    required SeekToPositionUseCase seekToPositionUseCase,
    required ToggleShuffleUseCase toggleShuffleUseCase,
    required ToggleRepeatModeUseCase toggleRepeatModeUseCase,
    required SetVolumeUseCase setVolumeUseCase,
    required SetPlaybackSpeedUseCase setPlaybackSpeedUseCase,
    required SavePlaybackStateUseCase savePlaybackStateUseCase,
    required RestorePlaybackStateUseCase restorePlaybackStateUseCase,
    required AudioPlaybackService playbackService,
  })  : _playAudioUseCase = playAudioUseCase,
        _playPlaylistUseCase = playPlaylistUseCase,
        _pauseAudioUseCase = pauseAudioUseCase,
        _resumeAudioUseCase = resumeAudioUseCase,
        _stopAudioUseCase = stopAudioUseCase,
        _skipToNextUseCase = skipToNextUseCase,
        _skipToPreviousUseCase = skipToPreviousUseCase,
        _seekToPositionUseCase = seekToPositionUseCase,
        _toggleShuffleUseCase = toggleShuffleUseCase,
        _toggleRepeatModeUseCase = toggleRepeatModeUseCase,
        _setVolumeUseCase = setVolumeUseCase,
        _setPlaybackSpeedUseCase = setPlaybackSpeedUseCase,
        _savePlaybackStateUseCase = savePlaybackStateUseCase,
        _restorePlaybackStateUseCase = restorePlaybackStateUseCase,
        _playbackService = playbackService,
        super(const AudioPlayerInitial()) {
    
    // Register event handlers
    on<AudioPlayerInitializeRequested>(_onInitializeRequested);
    on<PlayAudioRequested>(_onPlayAudioRequested);
    on<PlayPlaylistRequested>(_onPlayPlaylistRequested);
    on<PauseAudioRequested>(_onPauseAudioRequested);
    on<ResumeAudioRequested>(_onResumeAudioRequested);
    on<StopAudioRequested>(_onStopAudioRequested);
    on<SkipToNextRequested>(_onSkipToNextRequested);
    on<SkipToPreviousRequested>(_onSkipToPreviousRequested);
    on<SeekToPositionRequested>(_onSeekToPositionRequested);
    on<ToggleShuffleRequested>(_onToggleShuffleRequested);
    on<ToggleRepeatModeRequested>(_onToggleRepeatModeRequested);
    on<SetRepeatModeRequested>(_onSetRepeatModeRequested);
    on<SetVolumeRequested>(_onSetVolumeRequested);
    on<SetPlaybackSpeedRequested>(_onSetPlaybackSpeedRequested);
    on<SavePlaybackStateRequested>(_onSavePlaybackStateRequested);
    on<SessionStateChanged>(_onSessionStateChanged);
    on<PlaybackPositionUpdated>(_onPlaybackPositionUpdated);

    // Listen to playback service session changes
    _sessionSubscription = _playbackService.sessionStream.listen(
      (session) => add(SessionStateChanged(session)),
    );
  }

  // Use cases - pure audio operations only
  final PlayAudioUseCase _playAudioUseCase;
  final PlayPlaylistUseCase _playPlaylistUseCase;
  final PauseAudioUseCase _pauseAudioUseCase;
  final ResumeAudioUseCase _resumeAudioUseCase;
  final StopAudioUseCase _stopAudioUseCase;
  final SkipToNextUseCase _skipToNextUseCase;
  final SkipToPreviousUseCase _skipToPreviousUseCase;
  final SeekToPositionUseCase _seekToPositionUseCase;
  final ToggleShuffleUseCase _toggleShuffleUseCase;
  final ToggleRepeatModeUseCase _toggleRepeatModeUseCase;
  final SetVolumeUseCase _setVolumeUseCase;
  final SetPlaybackSpeedUseCase _setPlaybackSpeedUseCase;
  final SavePlaybackStateUseCase _savePlaybackStateUseCase;
  final RestorePlaybackStateUseCase _restorePlaybackStateUseCase;
  
  // Playback service for direct session access
  final AudioPlaybackService _playbackService;
  
  // Subscription to playback service updates
  late final StreamSubscription<PlaybackSession> _sessionSubscription;

  /// Get current playback session
  PlaybackSession get currentSession => _playbackService.currentSession;

  @override
  Future<void> close() {
    _sessionSubscription.cancel();
    return super.close();
  }

  // Event handlers - pure audio operations only
  
  Future<void> _onInitializeRequested(
    AudioPlayerInitializeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(const AudioPlayerLoading());
    
    try {
      // Attempt to restore previous playback state
      final result = await _restorePlaybackStateUseCase();
      
      result.fold(
        (failure) {
          // No saved state or restoration failed - start fresh
          emit(const AudioPlayerReady());
        },
        (restoredSession) {
          if (restoredSession != null) {
            // Session restored successfully
            _emitStateForSession(restoredSession, emit);
          } else {
            // No saved state to restore
            emit(const AudioPlayerReady());
          }
        },
      );
    } catch (e) {
      emit(const AudioPlayerReady());
    }
  }

  Future<void> _onPlayAudioRequested(
    PlayAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerBuffering(currentSession));
    
    final result = await _playAudioUseCase(event.trackId);
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
        // from playback service stream
      },
    );
  }

  Future<void> _onPlayPlaylistRequested(
    PlayPlaylistRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerBuffering(currentSession));
    
    final result = await _playPlaylistUseCase(
      event.playlistId,
      startIndex: event.startIndex,
    );
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _pauseAudioUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onResumeAudioRequested(
    ResumeAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _resumeAudioUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onStopAudioRequested(
    StopAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _stopAudioUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onSkipToNextRequested(
    SkipToNextRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _skipToNextUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (hasNext) {
        if (!hasNext) {
          // Reached end of queue, handle based on repeat mode
          _emitStateForSession(currentSession, emit);
        }
        // State will be updated via SessionStateChanged event if track changed
      },
    );
  }

  Future<void> _onSkipToPreviousRequested(
    SkipToPreviousRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _skipToPreviousUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (hasPrevious) {
        if (!hasPrevious) {
          // Reached beginning of queue
          _emitStateForSession(currentSession, emit);
        }
        // State will be updated via SessionStateChanged event if track changed
      },
    );
  }

  Future<void> _onSeekToPositionRequested(
    SeekToPositionRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _seekToPositionUseCase(event.position);
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onToggleShuffleRequested(
    ToggleShuffleRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _toggleShuffleUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (newShuffleState) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onToggleRepeatModeRequested(
    ToggleRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _toggleRepeatModeUseCase();
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (newRepeatMode) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onSetRepeatModeRequested(
    SetRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _playbackService.setRepeatMode(event.mode);
      // State will be updated via SessionStateChanged event
    } catch (e) {
      emit(AudioPlayerError(
        AudioPlayerFailure('Failed to set repeat mode: ${e.toString()}'),
        currentSession,
      ));
    }
  }

  Future<void> _onSetVolumeRequested(
    SetVolumeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _setVolumeUseCase(event.volume);
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onSetPlaybackSpeedRequested(
    SetPlaybackSpeedRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _setPlaybackSpeedUseCase(event.speed);
    
    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) {
        // State will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onSavePlaybackStateRequested(
    SavePlaybackStateRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _savePlaybackStateUseCase();
    
    result.fold(
      (failure) {
        // Saving state failed, but don't change playback state
        // Could emit a temporary message or log error
      },
      (_) {
        // State saved successfully, no need to change current state
      },
    );
  }

  void _onSessionStateChanged(
    SessionStateChanged event,
    Emitter<AudioPlayerState> emit,
  ) {
    _emitStateForSession(event.session, emit);
  }

  void _onPlaybackPositionUpdated(
    PlaybackPositionUpdated event,
    Emitter<AudioPlayerState> emit,
  ) {
    // Position updates are handled through session updates
    // This could be used for more granular position tracking if needed
    if (state is AudioPlayerSessionState) {
      final currentState = state as AudioPlayerSessionState;
      final updatedSession = currentState.session.copyWith(position: event.position);
      _emitStateForSession(updatedSession, emit);
    }
  }

  /// Convert playback session state to appropriate BLoC state
  void _emitStateForSession(PlaybackSession session, Emitter<AudioPlayerState> emit) {
    switch (session.state) {
      case PlaybackState.playing:
        emit(AudioPlayerPlaying(session));
      case PlaybackState.paused:
        emit(AudioPlayerPaused(session));
      case PlaybackState.stopped:
        emit(AudioPlayerStopped(session));
      case PlaybackState.loading:
        emit(AudioPlayerBuffering(session));
      case PlaybackState.completed:
        emit(AudioPlayerCompleted(session));
      case PlaybackState.error:
        emit(AudioPlayerError(
          AudioPlayerFailure(session.error ?? 'Unknown playback error'),
          session,
        ));
    }
  }
}
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/playback_session.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/audio_failure.dart';
import '../../domain/services/audio_player_service.dart';

import 'audio_player_event.dart';
import 'audio_player_state.dart';

/// Pure audio player BLoC - ONLY audio operations
/// NO: UserProfile, ProjectId, collaborators, or business context
/// Responsibilities:
/// - Audio playback control (play, pause, resume, stop, seek)
/// - Queue management (next, previous, shuffle, repeat)
/// - Settings management (volume, speed)
/// - State persistence and restoration
@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc({required AudioPlayerService audioPlayerService})
    : _audioPlayerService = audioPlayerService,
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
    _sessionSubscription = _audioPlayerService.sessionStream.listen(
      (session) => add(SessionStateChanged(session)),
    );
  }

  // Single service that encapsulates all audio operations
  final AudioPlayerService _audioPlayerService;

  // Subscription to playback service updates
  late final StreamSubscription<PlaybackSession> _sessionSubscription;

  /// Get current playback session
  PlaybackSession get currentSession => _audioPlayerService.currentSession;

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
      // Initialize the audio player first
      await _audioPlayerService.initialize();

      // Attempt to restore previous playback state
      try {
        await _audioPlayerService.restorePlaybackState();
        // Check if state was restored by examining current session
        final session = currentSession;
        if (session.queue.isNotEmpty) {
          _emitStateForSession(session, emit);
        } else {
          emit(const AudioPlayerReady());
        }
      } catch (restoreError) {
        // No saved state or restoration failed - start fresh
        emit(const AudioPlayerReady());
      }
    } catch (e) {
      emit(
        AudioPlayerError(
          AudioPlayerFailure(
            'Failed to initialize audio player: ${e.toString()}',
          ),
          currentSession,
        ),
      );
    }
  }

  Future<void> _onPlayAudioRequested(
    PlayAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerBuffering(currentSession));

    final result = await _audioPlayerService.playAudio(event.trackId);

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
      // from playback service stream
    });
  }

  Future<void> _onPlayPlaylistRequested(
    PlayPlaylistRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerBuffering(currentSession));

    Either<AudioFailure, void> result;

    if (event.tracks != null) {
      // Use provided tracks directly for on-the-fly playlists
      result = await _audioPlayerService.playTracks(
        event.tracks!,
        startIndex: event.startIndex,
      );
    } else if (event.playlistId != null) {
      // Use playlist ID via PlayPlaylistUseCase
      result = await _audioPlayerService.playPlaylist(
        event.playlistId!,
        startIndex: event.startIndex,
      );
    } else {
      emit(
        AudioPlayerError(
          AudioPlayerFailure('No playlist data provided'),
          currentSession,
        ),
      );
      return;
    }

    result.fold(
      (failure) {
        emit(AudioPlayerError(failure, currentSession));
      },
      (_) {
        // Success - state will be updated via SessionStateChanged event
      },
    );
  }

  Future<void> _onPauseAudioRequested(
    PauseAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.pause();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onResumeAudioRequested(
    ResumeAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.resume();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onStopAudioRequested(
    StopAudioRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.stop();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onSkipToNextRequested(
    SkipToNextRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.skipToNext();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      hasNext,
    ) {
      if (!hasNext) {
        // Reached end of queue, handle based on repeat mode
        _emitStateForSession(currentSession, emit);
      }
      // State will be updated via SessionStateChanged event if track changed
    });
  }

  Future<void> _onSkipToPreviousRequested(
    SkipToPreviousRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.skipToPrevious();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      hasPrevious,
    ) {
      if (!hasPrevious) {
        // Reached beginning of queue
        _emitStateForSession(currentSession, emit);
      }
      // State will be updated via SessionStateChanged event if track changed
    });
  }

  Future<void> _onSeekToPositionRequested(
    SeekToPositionRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.seek(event.position);
      // State will be updated via SessionStateChanged event
    } catch (e) {
      emit(
        AudioPlayerError(
          AudioPlayerFailure('Failed to seek: ${e.toString()}'),
          currentSession,
        ),
      );
    }
  }

  Future<void> _onToggleShuffleRequested(
    ToggleShuffleRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.toggleShuffle();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      newShuffleState,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onToggleRepeatModeRequested(
    ToggleRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.toggleRepeatMode();

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      newRepeatMode,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onSetRepeatModeRequested(
    SetRepeatModeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.setRepeatMode(event.mode);
      // State will be updated via SessionStateChanged event
    } catch (e) {
      emit(
        AudioPlayerError(
          AudioPlayerFailure('Failed to set repeat mode: ${e.toString()}'),
          currentSession,
        ),
      );
    }
  }

  Future<void> _onSetVolumeRequested(
    SetVolumeRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.setVolume(event.volume);

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onSetPlaybackSpeedRequested(
    SetPlaybackSpeedRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.setPlaybackSpeed(event.speed);

    result.fold((failure) => emit(AudioPlayerError(failure, currentSession)), (
      _,
    ) {
      // State will be updated via SessionStateChanged event
    });
  }

  Future<void> _onSavePlaybackStateRequested(
    SavePlaybackStateRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final result = await _audioPlayerService.savePlaybackState();

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
      final updatedSession = currentState.session.copyWith(
        position: event.position,
      );
      _emitStateForSession(updatedSession, emit);
    }
  }

  /// Convert playback session state to appropriate BLoC state
  void _emitStateForSession(
    PlaybackSession session,
    Emitter<AudioPlayerState> emit,
  ) {
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
        emit(
          AudioPlayerError(
            AudioPlayerFailure(session.error ?? 'Unknown playback error'),
            session,
          ),
        );
    }
  }
}

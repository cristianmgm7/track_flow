import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

import '../entities/playback_session.dart';
import '../entities/audio_failure.dart';
import '../entities/repeat_mode.dart';
import '../entities/audio_source.dart';
import '../usecases/initialize_audio_player_usecase.dart';
import '../usecases/play_version_usecase.dart';
import '../usecases/play_playlist_usecase.dart';
import '../usecases/pause_audio_usecase.dart';
import '../usecases/resume_audio_usecase.dart';
import '../usecases/stop_audio_usecase.dart';
import '../usecases/skip_to_next_usecase.dart';
import '../usecases/skip_to_previous_usecase.dart';
import '../usecases/seek_audio_usecase.dart';
import '../usecases/toggle_shuffle_usecase.dart';
import '../usecases/toggle_repeat_mode_usecase.dart';
import '../usecases/set_volume_usecase.dart';
import '../usecases/set_playback_speed_usecase.dart';
import '../usecases/save_playback_state_usecase.dart';
import '../usecases/restore_playback_state_usecase.dart';
import 'audio_playback_service.dart';

/// Facade service that encapsulates all audio player operations
/// Provides a clean interface for the BLoC without exposing individual use cases
@injectable
class AudioPlayerService {
  const AudioPlayerService({
    required InitializeAudioPlayerUseCase initializeAudioPlayerUseCase,
    required PlayVersionUseCase playVersionUseCase,
    required PlayPlaylistUseCase playPlaylistUseCase,
    required AudioTrackRepository audioTrackRepository,
    required PauseAudioUseCase pauseAudioUseCase,
    required ResumeAudioUseCase resumeAudioUseCase,
    required StopAudioUseCase stopAudioUseCase,
    required SkipToNextUseCase skipToNextUseCase,
    required SkipToPreviousUseCase skipToPreviousUseCase,
    required SeekAudioUseCase seekAudioUseCase,
    required ToggleShuffleUseCase toggleShuffleUseCase,
    required ToggleRepeatModeUseCase toggleRepeatModeUseCase,
    required SetVolumeUseCase setVolumeUseCase,
    required SetPlaybackSpeedUseCase setPlaybackSpeedUseCase,
    required SavePlaybackStateUseCase savePlaybackStateUseCase,
    required RestorePlaybackStateUseCase restorePlaybackStateUseCase,
    required AudioPlaybackService playbackService,
  }) : _initializeAudioPlayerUseCase = initializeAudioPlayerUseCase,
       _playVersionUseCase = playVersionUseCase,
       _playPlaylistUseCase = playPlaylistUseCase,
       _audioTrackRepository = audioTrackRepository,
       _pauseAudioUseCase = pauseAudioUseCase,
       _resumeAudioUseCase = resumeAudioUseCase,
       _stopAudioUseCase = stopAudioUseCase,
       _skipToNextUseCase = skipToNextUseCase,
       _skipToPreviousUseCase = skipToPreviousUseCase,
       _seekAudioUseCase = seekAudioUseCase,
       _toggleShuffleUseCase = toggleShuffleUseCase,
       _toggleRepeatModeUseCase = toggleRepeatModeUseCase,
       _setVolumeUseCase = setVolumeUseCase,
       _setPlaybackSpeedUseCase = setPlaybackSpeedUseCase,
       _savePlaybackStateUseCase = savePlaybackStateUseCase,
       _restorePlaybackStateUseCase = restorePlaybackStateUseCase,
       _playbackService = playbackService;

  // Use cases - pure audio operations only
  final InitializeAudioPlayerUseCase _initializeAudioPlayerUseCase;
  final PlayVersionUseCase _playVersionUseCase;
  final PlayPlaylistUseCase _playPlaylistUseCase;

  // Repositories
  final AudioTrackRepository _audioTrackRepository;
  final PauseAudioUseCase _pauseAudioUseCase;
  final ResumeAudioUseCase _resumeAudioUseCase;
  final StopAudioUseCase _stopAudioUseCase;
  final SkipToNextUseCase _skipToNextUseCase;
  final SkipToPreviousUseCase _skipToPreviousUseCase;
  final SeekAudioUseCase _seekAudioUseCase;
  final ToggleShuffleUseCase _toggleShuffleUseCase;
  final ToggleRepeatModeUseCase _toggleRepeatModeUseCase;
  final SetVolumeUseCase _setVolumeUseCase;
  final SetPlaybackSpeedUseCase _setPlaybackSpeedUseCase;
  final SavePlaybackStateUseCase _savePlaybackStateUseCase;
  final RestorePlaybackStateUseCase _restorePlaybackStateUseCase;

  // Playback service for direct session access
  final AudioPlaybackService _playbackService;

  /// Get current playback session
  PlaybackSession get currentSession => _playbackService.currentSession;

  /// Get session stream for state updates
  Stream<PlaybackSession> get sessionStream => _playbackService.sessionStream;

  /// Initialize the audio player
  Future<void> initialize() async {
    await _initializeAudioPlayerUseCase();
  }

  /// Play specific version by ID
  Future<Either<AudioFailure, void>> playVersion(
    TrackVersionId versionId,
  ) async {
    return await _playVersionUseCase(versionId);
  }

  /// Get the active version ID for a track
  /// This is a helper method for transitioning from track-centric to version-centric
  Future<Either<AudioFailure, TrackVersionId>> getActiveVersionForTrack(
    AudioTrackId trackId,
  ) async {
    try {
      // Get track to find active version
      final trackResult = await _audioTrackRepository.getTrackById(trackId);

      return await trackResult.fold(
        (failure) async => Left(TrackNotFoundFailure(trackId.value)),
        (audioTrack) async {
          if (audioTrack.activeVersionId == null) {
            return Left(
              AudioSourceFailure(
                'Track ${trackId.value} has no active version',
              ),
            );
          }
          return Right(audioTrack.activeVersionId!);
        },
      );
    } catch (e) {
      return Left(
        PlaybackFailure('Failed to get active version: ${e.toString()}'),
      );
    }
  }

  /// Play playlist starting from specified track index
  Future<Either<AudioFailure, void>> playPlaylist(
    PlaylistId playlistId, {
    int startIndex = 0,
  }) async {
    return await _playPlaylistUseCase(
      playlistId: playlistId,
      startIndex: startIndex,
    );
  }

  /// Play tracks directly starting from specified track index
  Future<Either<AudioFailure, void>> playTracks(
    List<AudioTrack> tracks, {
    int startIndex = 0,
  }) async {
    return await _playPlaylistUseCase(tracks: tracks, startIndex: startIndex);
  }

  /// Pause current audio playback
  Future<Either<AudioFailure, void>> pause() async {
    return await _pauseAudioUseCase();
  }

  /// Resume paused audio playback
  Future<Either<AudioFailure, void>> resume() async {
    return await _resumeAudioUseCase();
  }

  /// Stop audio playback and reset position
  Future<Either<AudioFailure, void>> stop() async {
    return await _stopAudioUseCase();
  }

  /// Skip to next track in the queue
  Future<Either<AudioFailure, bool>> skipToNext() async {
    return await _skipToNextUseCase();
  }

  /// Skip to previous track in the queue
  Future<Either<AudioFailure, bool>> skipToPrevious() async {
    return await _skipToPreviousUseCase();
  }

  /// Seek to the specified position in the current track
  Future<void> seek(Duration position) async {
    await _seekAudioUseCase(position);
  }

  /// Toggle shuffle mode on/off
  Future<Either<AudioFailure, bool>> toggleShuffle() async {
    return await _toggleShuffleUseCase();
  }

  /// Toggle repeat mode cycling
  Future<Either<AudioFailure, RepeatMode>> toggleRepeatMode() async {
    return await _toggleRepeatModeUseCase();
  }

  /// Set repeat mode directly
  Future<void> setRepeatMode(RepeatMode mode) async {
    await _playbackService.setRepeatMode(mode);
  }

  /// Set audio volume (0.0 to 1.0)
  Future<Either<AudioFailure, void>> setVolume(double volume) async {
    return await _setVolumeUseCase(volume);
  }

  /// Set audio playback speed (1.0 = normal speed)
  Future<Either<AudioFailure, void>> setPlaybackSpeed(double speed) async {
    return await _setPlaybackSpeedUseCase(speed);
  }

  /// Save current playback session state
  Future<Either<AudioFailure, void>> savePlaybackState() async {
    return await _savePlaybackStateUseCase();
  }

  /// Restore previously saved playback session
  Future<Either<AudioFailure, PlaybackSession?>> restorePlaybackState() async {
    return await _restorePlaybackStateUseCase();
  }

  /// Load a queue of audio sources and start playing from specified index
  Future<void> loadQueue(
    List<AudioSource> sources, {
    int startIndex = 0,
  }) async {
    await _playbackService.loadQueue(sources, startIndex: startIndex);
  }
}

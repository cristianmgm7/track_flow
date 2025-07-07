import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;

import '../../domain/entities/audio_source.dart';
import '../../domain/entities/audio_queue.dart';
import '../../domain/entities/playback_session.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/services/audio_playback_service.dart';

/// Pure audio playback service implementation using just_audio
/// NO business logic - only audio playback operations
/// Clean implementation following AudioPlaybackService interface exactly
@LazySingleton(as: AudioPlaybackService)
class AudioPlaybackServiceImpl implements AudioPlaybackService {
  AudioPlaybackServiceImpl();

  final AudioPlayer _audioPlayer = AudioPlayer(); // use this to play audio
  PlaybackSession _currentSession = PlaybackSession.initial();

  final StreamController<PlaybackSession> _sessionController =
      StreamController<PlaybackSession>.broadcast();

  @override
  Stream<PlaybackSession> get sessionStream => _sessionController.stream;

  @override
  PlaybackSession get currentSession => _currentSession;

  @override
  Future<void> play(AudioSource source) async {
    try {
      // Set up audio player listeners if not already set
      _setupListeners();

      // Update session with current track and loading state
      _updateSession(_currentSession.copyWith(
        currentTrack: source.metadata,
        state: PlaybackState.loading,
      ));

      // Load the audio source
      await _audioPlayer.setUrl(source.url);

      // Start playback
      await _audioPlayer.play();
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to play audio: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to pause: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to resume: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.stopped,
          position: Duration.zero,
        ),
      );
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to stop: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to seek: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _audioPlayer.setSpeed(clampedSpeed);
      _updateSession(_currentSession.copyWith(playbackSpeed: clampedSpeed));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to set playback speed: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      _updateSession(_currentSession.copyWith(volume: clampedVolume));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to set volume: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> setRepeatMode(RepeatMode mode) async {
    try {
      _updateSession(_currentSession.copyWith(repeatMode: mode));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to set repeat mode: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<bool> skipToNext() async {
    try {
      final queue = _currentSession.queue;
      if (!queue.hasNext) {
        return false;
      }

      final nextSource = queue.next();
      if (nextSource != null) {
        await play(nextSource);
        // Update the queue in session to reflect the new current index
        _updateSession(_currentSession.copyWith(
          queue: queue,
          currentTrack: nextSource.metadata,
        ));
        return true;
      }
      return false;
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to skip to next: $e',
        ),
      );
      return false;
    }
  }

  @override
  Future<bool> skipToPrevious() async {
    try {
      final queue = _currentSession.queue;
      if (!queue.hasPrevious) {
        return false;
      }

      final previousSource = queue.previous();
      if (previousSource != null) {
        await play(previousSource);
        // Update the queue in session to reflect the new current index
        _updateSession(_currentSession.copyWith(
          queue: queue,
          currentTrack: previousSource.metadata,
        ));
        return true;
      }
      return false;
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to skip to previous: $e',
        ),
      );
      return false;
    }
  }

  @override
  Future<void> setShuffleEnabled(bool enabled) async {
    try {
      final updatedQueue = _currentSession.queue.copyWith(
        shuffleEnabled: enabled,
      );
      _updateSession(_currentSession.copyWith(queue: updatedQueue));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to set shuffle: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> loadQueue(
    List<AudioSource> sources, {
    int startIndex = 0,
  }) async {
    try {
      if (sources.isEmpty) {
        throw ArgumentError('Cannot load empty queue');
      }

      if (startIndex < 0 || startIndex >= sources.length) {
        throw ArgumentError('Start index out of bounds');
      }

      // Create new queue with sources
      final newQueue = AudioQueue.fromSources(sources, startIndex: startIndex);

      // Update session with new queue
      _updateSession(
        _currentSession.copyWith(queue: newQueue, state: PlaybackState.stopped),
      );

      // Play the track at start index
      final startSource = sources[startIndex];
      await play(startSource);
      
      // Update session with the current track from the queue
      _updateSession(_currentSession.copyWith(
        currentTrack: startSource.metadata,
      ));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to load queue: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> addToQueue(AudioSource source) async {
    try {
      final updatedQueue = _currentSession.queue.add(source);
      _updateSession(_currentSession.copyWith(queue: updatedQueue));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to add to queue: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> insertInQueue(AudioSource source, int index) async {
    try {
      final updatedQueue = _currentSession.queue.insert(source, index);
      _updateSession(_currentSession.copyWith(queue: updatedQueue));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to insert in queue: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> removeFromQueue(int index) async {
    try {
      final updatedQueue = _currentSession.queue.removeAt(index);
      _updateSession(_currentSession.copyWith(queue: updatedQueue));
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to remove from queue: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> clearQueue() async {
    try {
      await stop();
      _updateSession(
        _currentSession.copyWith(
          queue: AudioQueue.empty(),
          state: PlaybackState.stopped,
        ),
      );
    } catch (e) {
      _updateSession(
        _currentSession.copyWith(
          state: PlaybackState.error,
          error: 'Failed to clear queue: $e',
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      await _sessionController.close();
    } catch (e) {
      // Dispose should not throw, just silently handle the error
      // In production, this could be logged to a proper logging service
    }
  }

  // Private helper methods

  bool _listenersSetup = false;

  void _setupListeners() {
    if (_listenersSetup) return;

    _audioPlayer.positionStream.listen(_onPositionChanged);
    _audioPlayer.durationStream.listen(_onDurationChanged);
    _audioPlayer.playerStateStream.listen(_onPlayerStateChanged);

    _listenersSetup = true;
  }

  void _updateSession(PlaybackSession newSession) {
    _currentSession = newSession;
    _sessionController.add(newSession);
  }

  void _onPositionChanged(Duration position) {
    _updateSession(_currentSession.copyWith(position: position));
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null) {
      // Note: We'll need to update the current track's duration
      // This might require updating the queue's current track
      _updateSession(
        _currentSession.copyWith(
          // duration: duration, // Will implement when PlaybackSession supports this
        ),
      );
    }
  }

  void _onPlayerStateChanged(PlayerState playerState) {
    PlaybackState newState;

    switch (playerState.processingState) {
      case ProcessingState.idle:
        newState = PlaybackState.stopped;
        break;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        newState = PlaybackState.loading;
        break;
      case ProcessingState.ready:
        newState =
            playerState.playing ? PlaybackState.playing : PlaybackState.paused;
        break;
      case ProcessingState.completed:
        newState = PlaybackState.completed;
        _handleTrackCompletion();
        break;
    }

    _updateSession(_currentSession.copyWith(state: newState));
  }

  void _handleTrackCompletion() {
    switch (_currentSession.repeatMode) {
      case RepeatMode.single:
        // Replay current track
        seek(Duration.zero);
        resume();
        break;

      case RepeatMode.queue:
        if (_currentSession.queue.hasNext) {
          skipToNext();
        } else {
          // Go back to first track in queue
          final firstSource = _currentSession.queue.first();
          if (firstSource != null) {
            play(firstSource);
          }
        }
        break;

      case RepeatMode.none:
        if (_currentSession.queue.hasNext) {
          skipToNext();
        } else {
          stop();
        }
        break;
    }
  }
}

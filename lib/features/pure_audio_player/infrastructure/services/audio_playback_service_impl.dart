import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/audio_track_id.dart';
import '../../domain/entities/playback_session.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/services/audio_playback_service.dart';
import '../repositories/audio_content_repository_impl.dart';

/// Pure audio playback service implementation using just_audio
/// NO business logic - only audio playback operations
/// Integrates with cache orchestration through AudioContentRepository
@LazySingleton(as: AudioPlaybackService)
class AudioPlaybackServiceImpl implements AudioPlaybackService {
  AudioPlaybackServiceImpl(this._audioContentRepository);

  final AudioContentRepositoryImpl _audioContentRepository;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current session state
  PlaybackSession? _currentSession;
  final StreamController<PlaybackSession> _sessionController = 
      StreamController<PlaybackSession>.broadcast();

  @override
  Stream<PlaybackSession> get sessionStream => _sessionController.stream;

  @override
  Future<Either<Failure, void>> initializePlayer() async {
    try {
      // Set up audio player listeners
      _audioPlayer.positionStream.listen(_onPositionChanged);
      _audioPlayer.durationStream.listen(_onDurationChanged);
      _audioPlayer.playerStateStream.listen(_onPlayerStateChanged);

      // Initialize with empty session
      _currentSession = PlaybackSession.initial();
      _sessionController.add(_currentSession!);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize audio player: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> loadTrack(AudioTrackId trackId) async {
    try {
      // Get track metadata and audio source
      final metadata = await _audioContentRepository.getTrackMetadata(trackId);
      final audioSourceUrl = await _audioContentRepository.getAudioSourceUrl(trackId);

      // Load audio source into player
      await _audioPlayer.setUrl(audioSourceUrl);

      // Update session with new track
      _currentSession = _currentSession?.copyWith(
        currentTrack: metadata,
        queue: [metadata], // Single track queue
        currentIndex: 0,
        isLoading: false,
      ) ?? PlaybackSession.withTrack(metadata);

      _sessionController.add(_currentSession!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to load track: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> loadPlaylist(List<AudioTrackId> trackIds) async {
    try {
      if (trackIds.isEmpty) {
        return Left(ValidationFailure('Cannot load empty playlist'));
      }

      // Get metadata for all tracks
      final metadataList = await _audioContentRepository.getTracksMetadata(trackIds);
      
      if (metadataList.isEmpty) {
        return Left(ValidationFailure('No valid tracks found in playlist'));
      }

      // Load first track for immediate playback
      final firstTrack = metadataList.first;
      final audioSourceUrl = await _audioContentRepository.getAudioSourceUrl(firstTrack.id);
      await _audioPlayer.setUrl(audioSourceUrl);

      // Update session with playlist
      _currentSession = PlaybackSession(
        currentTrack: firstTrack,
        queue: metadataList,
        currentIndex: 0,
        isPlaying: false,
        isPaused: false,
        isLoading: false,
        position: Duration.zero,
        duration: firstTrack.duration,
        volume: 1.0,
        playbackSpeed: 1.0,
        repeatMode: RepeatMode.none,
        shuffleEnabled: false,
      );

      _sessionController.add(_currentSession!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to load playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> play() async {
    try {
      await _audioPlayer.play();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to play: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    try {
      await _audioPlayer.pause();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to pause: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _audioPlayer.stop();
      _currentSession = _currentSession?.copyWith(
        isPlaying: false,
        isPaused: false,
        position: Duration.zero,
      );
      if (_currentSession != null) {
        _sessionController.add(_currentSession!);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to stop: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to seek: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToNext() async {
    try {
      final session = _currentSession;
      if (session == null || !session.hasNext) {
        return Left(ValidationFailure('No next track available'));
      }

      final nextIndex = session.currentIndex + 1;
      final nextTrack = session.queue[nextIndex];
      
      // Load next track
      final audioSourceUrl = await _audioContentRepository.getAudioSourceUrl(nextTrack.id);
      await _audioPlayer.setUrl(audioSourceUrl);

      // Update session
      _currentSession = session.copyWith(
        currentTrack: nextTrack,
        currentIndex: nextIndex,
        position: Duration.zero,
      );

      _sessionController.add(_currentSession!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to skip to next: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> skipToPrevious() async {
    try {
      final session = _currentSession;
      if (session == null || !session.hasPrevious) {
        return Left(ValidationFailure('No previous track available'));
      }

      final previousIndex = session.currentIndex - 1;
      final previousTrack = session.queue[previousIndex];
      
      // Load previous track
      final audioSourceUrl = await _audioContentRepository.getAudioSourceUrl(previousTrack.id);
      await _audioPlayer.setUrl(audioSourceUrl);

      // Update session
      _currentSession = session.copyWith(
        currentTrack: previousTrack,
        currentIndex: previousIndex,
        position: Duration.zero,
      );

      _sessionController.add(_currentSession!);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to skip to previous: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set volume: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set playback speed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode) async {
    try {
      // Update session state
      _currentSession = _currentSession?.copyWith(repeatMode: mode);
      if (_currentSession != null) {
        _sessionController.add(_currentSession!);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set repeat mode: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setShuffle(bool enabled) async {
    try {
      // Update session state
      _currentSession = _currentSession?.copyWith(shuffleEnabled: enabled);
      if (_currentSession != null) {
        _sessionController.add(_currentSession!);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set shuffle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePlaybackState() async {
    try {
      // For now, just return success
      // TODO: Implement persistent playback state storage
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restorePlaybackState() async {
    try {
      // For now, just return success
      // TODO: Implement persistent playback state restoration
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to restore playback state: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await _audioPlayer.dispose();
      await _sessionController.close();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to dispose audio player: $e'));
    }
  }

  // Audio player event handlers
  void _onPositionChanged(Duration position) {
    _currentSession = _currentSession?.copyWith(position: position);
    if (_currentSession != null) {
      _sessionController.add(_currentSession!);
    }
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null) {
      _currentSession = _currentSession?.copyWith(duration: duration);
      if (_currentSession != null) {
        _sessionController.add(_currentSession!);
      }
    }
  }

  void _onPlayerStateChanged(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final isPaused = !playerState.playing && playerState.processingState != ProcessingState.completed;

    _currentSession = _currentSession?.copyWith(
      isPlaying: isPlaying,
      isPaused: isPaused,
      isLoading: playerState.processingState == ProcessingState.loading ||
                 playerState.processingState == ProcessingState.buffering,
    );

    if (_currentSession != null) {
      _sessionController.add(_currentSession!);
    }

    // Handle track completion and repeat modes
    if (playerState.processingState == ProcessingState.completed) {
      _handleTrackCompletion();
    }
  }

  void _handleTrackCompletion() {
    final session = _currentSession;
    if (session == null) return;

    switch (session.repeatMode) {
      case RepeatMode.single:
        // Replay current track
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        break;
      
      case RepeatMode.queue:
        if (session.hasNext) {
          skipToNext();
        } else {
          // Go back to first track
          final firstTrack = session.queue.first;
          loadTrack(firstTrack.id).then((result) {
            if (result.isRight()) {
              play();
            }
          });
        }
        break;
      
      case RepeatMode.none:
        if (session.hasNext) {
          skipToNext();
        } else {
          // Stop playback
          stop();
        }
        break;
    }
  }
}

/// Validation-specific failure for pure audio architecture
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
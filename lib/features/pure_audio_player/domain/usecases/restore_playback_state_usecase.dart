import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../entities/playback_session.dart';
import '../entities/audio_source.dart';
import '../repositories/playback_persistence_repository.dart';
import '../repositories/audio_content_repository.dart';
import '../services/audio_playback_service.dart';

/// Pure audio state restoration use case
/// ONLY handles audio playback state restoration - NO business domain concerns
/// NO: UserProfile reconstruction, collaborator data, project context
class RestorePlaybackStateUseCase {
  const RestorePlaybackStateUseCase({
    required PlaybackPersistenceRepository persistenceRepository,
    required AudioContentRepository audioContentRepository,
    required AudioPlaybackService playbackService,
  })  : _persistenceRepository = persistenceRepository,
        _audioContentRepository = audioContentRepository,
        _playbackService = playbackService;

  final PlaybackPersistenceRepository _persistenceRepository;
  final AudioContentRepository _audioContentRepository;
  final AudioPlaybackService _playbackService;

  /// Restore previously saved playback session
  /// Handles: state loading, queue reconstruction, position restoration
  /// Does NOT handle: user context, collaborator data, business rules
  Future<Either<AudioFailure, PlaybackSession?>> call() async {
    try {
      // 1. Check if saved state exists
      final hasSavedState = await _persistenceRepository.hasPlaybackState();
      if (!hasSavedState) {
        return const Right(null); // No saved state to restore
      }

      // 2. Load saved playback session (pure audio state only)
      final savedSession = await _persistenceRepository.loadPlaybackState();
      if (savedSession == null) {
        return const Right(null);
      }

      // 3. Reconstruct audio queue if it exists
      if (savedSession.queue.isNotEmpty) {
        try {
          // Get current metadata for all tracks in queue
          final trackIds = savedSession.queue.tracks;
          final tracksMetadata = await _audioContentRepository.getTracksMetadata(trackIds);

          // Create audio sources for playback service
          final audioSources = <AudioSource>[];
          for (final metadata in tracksMetadata) {
            final sourceUrl = await _audioContentRepository.getAudioSourceUrl(metadata.id);
            audioSources.add(AudioSource(url: sourceUrl, metadata: metadata));
          }

          if (audioSources.isNotEmpty) {
            // 4. Load queue into playback service
            await _playbackService.loadQueue(
              audioSources, 
              startIndex: savedSession.queue.currentIndex,
            );

            // 5. Restore audio settings
            await _playbackService.setRepeatMode(savedSession.repeatMode);
            await _playbackService.setShuffleEnabled(savedSession.shuffleEnabled);
            await _playbackService.setVolume(savedSession.volume);
            await _playbackService.setPlaybackSpeed(savedSession.playbackSpeed);

            // 6. Restore position if track was playing/paused
            if (savedSession.position.inMilliseconds > 0) {
              await _playbackService.seek(savedSession.position);
            }

            // 7. Restore playback state (but don't auto-play)
            if (savedSession.isPlaying) {
              // Note: We restore to paused state to let user decide to resume
              // Auto-playing on app startup can be annoying
              await _playbackService.pause();
            }
          }
        } catch (e) {
          // If queue reconstruction fails, clear the saved state
          await _persistenceRepository.clearPlaybackState();
          return Left(StorageFailure('Failed to restore queue: ${e.toString()}'));
        }
      }

      // Return the current session state after restoration
      return Right(_playbackService.currentSession);
    } catch (e) {
      return Left(StorageFailure('Failed to restore playback state: ${e.toString()}'));
    }
  }
}
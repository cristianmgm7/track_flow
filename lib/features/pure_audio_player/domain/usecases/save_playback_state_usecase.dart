import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../repositories/playback_persistence_repository.dart';
import '../services/audio_playback_service.dart';

/// Pure audio state saving use case
/// ONLY handles audio playback state persistence - NO business domain concerns
/// NO: UserProfile data, collaborator info, project context
class SavePlaybackStateUseCase {
  const SavePlaybackStateUseCase({
    required PlaybackPersistenceRepository persistenceRepository,
    required AudioPlaybackService playbackService,
  })  : _persistenceRepository = persistenceRepository,
        _playbackService = playbackService;

  final PlaybackPersistenceRepository _persistenceRepository;
  final AudioPlaybackService _playbackService;

  /// Save current playback session state
  /// Handles: state persistence, queue saving, position tracking
  /// Does NOT handle: user context, collaborator data, business rules
  Future<Either<AudioFailure, void>> call() async {
    try {
      // 1. Get current session state (pure audio only)
      final currentSession = _playbackService.currentSession;

      // 2. Save complete session state
      await _persistenceRepository.savePlaybackState(currentSession);

      // 3. Save queue information separately for faster access
      if (currentSession.queue.isNotEmpty) {
        final trackIds = currentSession.queue.tracks.map((id) => id.value).toList();
        await _persistenceRepository.saveQueue(trackIds, currentSession.queue.currentIndex);
      }

      // 4. Save current track position for resume capability
      if (currentSession.currentTrack != null && currentSession.position.inMilliseconds > 0) {
        await _persistenceRepository.saveTrackPosition(
          currentSession.currentTrack!.id.value,
          currentSession.position,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to save playback state: ${e.toString()}'));
    }
  }
}
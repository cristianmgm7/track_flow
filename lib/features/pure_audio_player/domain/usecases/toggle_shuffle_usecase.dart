import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio shuffle toggle use case
/// ONLY handles shuffle mode toggle - NO business domain concerns
class ToggleShuffleUseCase {
  const ToggleShuffleUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Toggle shuffle mode on/off
  Future<Either<AudioFailure, bool>> call() async {
    try {
      final currentSession = _playbackService.currentSession;
      final newShuffleState = !currentSession.shuffleEnabled;
      
      await _playbackService.setShuffleEnabled(newShuffleState);
      
      return Right(newShuffleState);
    } catch (e) {
      return Left(PlaybackFailure('Failed to toggle shuffle: ${e.toString()}'));
    }
  }
}
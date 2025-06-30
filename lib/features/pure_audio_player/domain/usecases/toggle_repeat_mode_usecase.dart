import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../entities/repeat_mode.dart';
import '../services/audio_playback_service.dart';

/// Pure audio repeat mode toggle use case
/// ONLY handles repeat mode cycling - NO business domain concerns
class ToggleRepeatModeUseCase {
  const ToggleRepeatModeUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Cycle through repeat modes: none -> single -> queue -> none
  Future<Either<AudioFailure, RepeatMode>> call() async {
    try {
      final currentSession = _playbackService.currentSession;
      final currentMode = currentSession.repeatMode;
      
      // Cycle through repeat modes
      final nextMode = switch (currentMode) {
        RepeatMode.none => RepeatMode.single,
        RepeatMode.single => RepeatMode.queue,
        RepeatMode.queue => RepeatMode.none,
      };
      
      await _playbackService.setRepeatMode(nextMode);
      
      return Right(nextMode);
    } catch (e) {
      return Left(PlaybackFailure('Failed to toggle repeat mode: ${e.toString()}'));
    }
  }
}
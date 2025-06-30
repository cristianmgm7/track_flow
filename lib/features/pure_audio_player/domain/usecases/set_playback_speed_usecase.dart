import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio playback speed control use case
/// ONLY handles playback speed adjustment - NO business domain concerns
class SetPlaybackSpeedUseCase {
  const SetPlaybackSpeedUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Set audio playback speed (1.0 = normal speed)
  Future<Either<AudioFailure, void>> call(double speed) async {
    try {
      // Validate speed range (common range: 0.25x to 3.0x)
      if (speed <= 0.0 || speed > 3.0) {
        return const Left(PlaybackFailure('Playback speed must be between 0.1 and 3.0'));
      }

      await _playbackService.setPlaybackSpeed(speed);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to set playback speed: ${e.toString()}'));
    }
  }
}
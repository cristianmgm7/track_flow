import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio volume control use case
/// ONLY handles volume adjustment - NO business domain concerns
@injectable
class SetVolumeUseCase {
  const SetVolumeUseCase({required AudioPlaybackService playbackService})
    : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Set audio volume (0.0 to 1.0)
  Future<Either<AudioFailure, void>> call(double volume) async {
    try {
      // Validate volume range
      if (volume < 0.0 || volume > 1.0) {
        return const Left(
          PlaybackFailure('Volume must be between 0.0 and 1.0'),
        );
      }

      await _playbackService.setVolume(volume);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to set volume: ${e.toString()}'));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio seek use case
/// ONLY handles audio position seeking - NO business domain concerns
class SeekToPositionUseCase {
  const SeekToPositionUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Seek to specific position in current track
  Future<Either<AudioFailure, void>> call(Duration position) async {
    try {
      // Validate position
      if (position.isNegative) {
        return const Left(PlaybackFailure('Position cannot be negative'));
      }

      await _playbackService.seek(position);
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to seek to position: ${e.toString()}'));
    }
  }
}
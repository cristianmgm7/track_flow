import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio pause use case
/// ONLY handles audio pause operation - NO business domain concerns
@injectable
class PauseAudioUseCase {
  const PauseAudioUseCase({required AudioPlaybackService playbackService})
    : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Pause current audio playback
  Future<Either<AudioFailure, void>> call() async {
    try {
      await _playbackService.pause();
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to pause audio: ${e.toString()}'));
    }
  }
}

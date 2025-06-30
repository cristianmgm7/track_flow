import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio stop use case
/// ONLY handles audio stop operation - NO business domain concerns
@injectable
class StopAudioUseCase {
  const StopAudioUseCase({required AudioPlaybackService playbackService})
    : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Stop audio playback and reset position
  Future<Either<AudioFailure, void>> call() async {
    try {
      await _playbackService.stop();
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to stop audio: ${e.toString()}'));
    }
  }
}

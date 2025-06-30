import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio resume use case
/// ONLY handles audio resume operation - NO business domain concerns
class ResumeAudioUseCase {
  const ResumeAudioUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Resume paused audio playback
  Future<Either<AudioFailure, void>> call() async {
    try {
      await _playbackService.resume();
      return const Right(null);
    } catch (e) {
      return Left(PlaybackFailure('Failed to resume audio: ${e.toString()}'));
    }
  }
}
import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio navigation use case for skipping to previous track
/// ONLY handles queue navigation - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
class SkipToPreviousUseCase {
  const SkipToPreviousUseCase({
    required AudioPlaybackService playbackService,
  }) : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Skip to previous track in the queue
  /// Handles: queue navigation, repeat mode logic, playback continuation
  /// Does NOT handle: user permissions, collaborator data, business rules
  Future<Either<AudioFailure, bool>> call() async {
    try {
      // Delegate to playback service which handles:
      // - Queue navigation logic
      // - Repeat mode (none, single, queue)
      // - Shuffle mode considerations
      // - Beginning of queue behavior
      final hasPrevious = await _playbackService.skipToPrevious();

      return Right(hasPrevious);
    } catch (e) {
      return Left(QueueFailure('Failed to skip to previous track: ${e.toString()}'));
    }
  }
}
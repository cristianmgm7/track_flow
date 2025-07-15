import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../services/audio_playback_service.dart';

/// Pure audio navigation use case for skipping to next track
/// ONLY handles queue navigation - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
@injectable
class SkipToNextUseCase {
  const SkipToNextUseCase({required AudioPlaybackService playbackService})
    : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Skip to next track in the queue
  /// Handles: queue navigation, repeat mode logic, playback continuation
  /// Does NOT handle: user permissions, collaborator data, business rules
  Future<Either<AudioFailure, bool>> call() async {
    try {
      // Delegate to playback service which handles:
      // - Queue navigation logic
      // - Repeat mode (none, single, queue)
      // - Shuffle mode considerations
      // - End of queue behavior
      final hasNext = await _playbackService.skipToNext();

      return Right(hasNext);
    } catch (e) {
      return Left(
        QueueFailure('Failed to skip to next track: ${e.toString()}'),
      );
    }
  }
}

import 'package:injectable/injectable.dart';
import '../services/audio_playback_service.dart';

/// Use case for seeking to a specific position in the current audio track
/// Pure audio operation without business logic
@injectable
class SeekAudioUseCase {
  const SeekAudioUseCase({required AudioPlaybackService playbackService})
    : _playbackService = playbackService;

  final AudioPlaybackService _playbackService;

  /// Seek to the specified position in the current track
  ///
  /// [position] The target position to seek to
  ///
  /// Throws if:
  /// - No track is currently loaded
  /// - Position is negative or exceeds track duration
  /// - Audio player encounters an error
  Future<void> call(Duration position) async {
    if (position.isNegative) {
      throw ArgumentError('Position cannot be negative: $position');
    }

    await _playbackService.seek(position);
  }
}

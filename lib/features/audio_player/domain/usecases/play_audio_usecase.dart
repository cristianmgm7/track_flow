import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../entities/audio_track_id.dart';
import '../entities/audio_source.dart';
import '../repositories/audio_content_repository.dart';
import '../services/audio_playback_service.dart';

/// Pure audio playback use case
/// ONLY handles audio playback - NO business domain concerns
/// NO: UserProfile fetching, collaboration logic, or business context
@injectable
class PlayAudioUseCase {
  const PlayAudioUseCase({
    required AudioContentRepository audioContentRepository,
    required AudioPlaybackService playbackService,
  }) : _audioContentRepository = audioContentRepository,
       _playbackService = playbackService;

  final AudioContentRepository _audioContentRepository;
  final AudioPlaybackService _playbackService;

  /// Play audio track by ID
  /// Handles: metadata fetching, source resolution, playback initiation
  /// Does NOT handle: user context, collaborator data, project information
  Future<Either<AudioFailure, void>> call(AudioTrackId trackId) async {
    try {
      // 1. Get pure audio metadata (NO UserProfile)
      final metadata = await _audioContentRepository.getTrackMetadata(trackId);

      // 2. Resolve audio source URL (handles cache vs streaming internally)
      final sourceUrl = await _audioContentRepository.getAudioSourceUrl(
        trackId,
      );

      // 3. Create audio source for playback
      final audioSource = AudioSource(url: sourceUrl, metadata: metadata);

      // 4. Initiate playback (pure audio operation)
      await _playbackService.play(audioSource);

      return const Right(null);
    } catch (e) {
      // Handle audio-specific errors only
      if (e.toString().contains('not found')) {
        return Left(TrackNotFoundFailure(trackId.value));
      } else if (e.toString().contains('network')) {
        return const Left(NetworkFailure());
      } else if (e.toString().contains('source')) {
        return Left(AudioSourceFailure(trackId.value));
      } else {
        return Left(PlaybackFailure(e.toString()));
      }
    }
  }
}

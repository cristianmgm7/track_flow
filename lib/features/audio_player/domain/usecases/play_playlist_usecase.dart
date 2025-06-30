import 'package:dartz/dartz.dart';
import '../entities/audio_failure.dart';
import '../entities/playlist_id.dart';
import '../entities/audio_source.dart';
import '../repositories/audio_content_repository.dart';
import '../services/audio_playback_service.dart';

/// Pure playlist playback use case
/// ONLY handles playlist queue setup and playback - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
class PlayPlaylistUseCase {
  const PlayPlaylistUseCase({
    required AudioContentRepository audioContentRepository,
    required AudioPlaybackService playbackService,
  })  : _audioContentRepository = audioContentRepository,
        _playbackService = playbackService;

  final AudioContentRepository _audioContentRepository;
  final AudioPlaybackService _playbackService;

  /// Play playlist starting from specified track index
  /// Handles: playlist loading, queue setup, playback initiation
  /// Does NOT handle: user permissions, collaborator data, business rules
  Future<Either<AudioFailure, void>> call(
    PlaylistId playlistId, {
    int startIndex = 0,
  }) async {
    try {
      // 1. Get playlist tracks metadata (pure audio data only)
      final tracksMetadata = await _audioContentRepository.getPlaylistTracks(playlistId);

      if (tracksMetadata.isEmpty) {
        return Left(PlaylistFailure('Playlist is empty: ${playlistId.value}'));
      }

      // Validate start index
      if (startIndex < 0 || startIndex >= tracksMetadata.length) {
        return Left(QueueFailure('Invalid start index: $startIndex'));
      }

      // 2. Create audio sources for all tracks
      final audioSources = <AudioSource>[];
      
      for (final metadata in tracksMetadata) {
        try {
          // Resolve source URL for each track
          final sourceUrl = await _audioContentRepository.getAudioSourceUrl(metadata.id);
          
          audioSources.add(AudioSource(
            url: sourceUrl,
            metadata: metadata,
          ));
        } catch (e) {
          // Skip tracks that can't be loaded, continue with others
          continue;
        }
      }

      if (audioSources.isEmpty) {
        return Left(PlaylistFailure('No playable tracks in playlist: ${playlistId.value}'));
      }

      // Adjust start index if some tracks were skipped
      final adjustedStartIndex = startIndex.clamp(0, audioSources.length - 1);

      // 3. Load queue and start playback (pure audio operation)
      await _playbackService.loadQueue(audioSources, startIndex: adjustedStartIndex);

      return const Right(null);
    } catch (e) {
      // Handle audio-specific errors only
      if (e.toString().contains('not found')) {
        return Left(PlaylistFailure('Playlist not found: ${playlistId.value}'));
      } else if (e.toString().contains('network')) {
        return const Left(NetworkFailure());
      } else {
        return Left(PlaylistFailure('Failed to load playlist: ${e.toString()}'));
      }
    }
  }
}
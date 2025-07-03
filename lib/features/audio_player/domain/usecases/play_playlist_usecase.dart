import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../../../playlist/domain/entities/playlist_id.dart';
import '../../../playlist/domain/repositories/playlist_repository.dart';
import '../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../entities/audio_source.dart';
import '../entities/audio_track_metadata.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../services/audio_playback_service.dart';

/// Pure playlist playback use case
/// ONLY handles playlist queue setup and playback - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
@injectable
class PlayPlaylistUseCase {
  const PlayPlaylistUseCase({
    required PlaylistRepository playlistRepository,
    required AudioTrackRepository audioTrackRepository,
    required AudioPlaybackService playbackService,
  }) : _playlistRepository = playlistRepository,
       _audioTrackRepository = audioTrackRepository,
       _playbackService = playbackService;

  final PlaylistRepository _playlistRepository;
  final AudioTrackRepository _audioTrackRepository;
  final AudioPlaybackService _playbackService;

  /// Play playlist starting from specified track index
  /// Handles: playlist loading, queue setup, playback initiation
  /// Does NOT handle: user permissions, collaborator data, business rules
  Future<Either<AudioFailure, void>> call(
    PlaylistId playlistId, {
    int startIndex = 0,
  }) async {
    try {
      // 1. Get playlist by ID
      final playlist = await _playlistRepository.getPlaylistById(
        playlistId,
      );
      if (playlist == null) {
        return Left(PlaylistFailure('Playlist not found: ${playlistId.value}'));
      }
      if (playlist.trackIds.isEmpty) {
        return Left(PlaylistFailure('Playlist is empty: ${playlistId.value}'));
      }
      // Validate start index
      if (startIndex < 0 || startIndex >= playlist.trackIds.length) {
        return Left(QueueFailure('Invalid start index: $startIndex'));
      }
      // 2. Create audio sources for all tracks
      final audioSources = <AudioSource>[];
      for (final trackId in playlist.trackIds) {
        try {
          final trackOrFailure = await _audioTrackRepository.getTrackById(
            AudioTrackId.fromUniqueString(trackId),
          );
          trackOrFailure.fold(
            (failure) {
              // Skip tracks that can't be loaded
            },
            (track) {
              if (track.url.isNotEmpty) {
                final metadata = AudioTrackMetadata(
                  id: AudioTrackId.fromUniqueString(track.id.value),
                  title: track.name,
                  artist: '', // No artist info in AudioTrack
                  duration: track.duration,
                );
                audioSources.add(
                  AudioSource(url: track.url, metadata: metadata),
                );
              }
            },
          );
        } catch (e) {
          // Skip tracks that can't be loaded
          continue;
        }
      }
      if (audioSources.isEmpty) {
        return Left(
          PlaylistFailure(
            'No playable tracks in playlist: ${playlistId.value}',
          ),
        );
      }
      // Adjust start index if some tracks were skipped
      final adjustedStartIndex = startIndex.clamp(0, audioSources.length - 1);
      // 3. Load queue and start playback (pure audio operation)
      await _playbackService.loadQueue(
        audioSources,
        startIndex: adjustedStartIndex,
      );
      return const Right(null);
    } catch (e) {
      // Handle audio-specific errors only
      if (e.toString().contains('not found')) {
        return Left(PlaylistFailure('Playlist not found: ${playlistId.value}'));
      } else if (e.toString().contains('network')) {
        return const Left(NetworkFailure());
      } else {
        return Left(
          PlaylistFailure('Failed to load playlist: ${e.toString()}'),
        );
      }
    }
  }
}

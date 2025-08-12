import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../../../playlist/domain/repositories/playlist_repository.dart';
import '../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../entities/audio_source.dart';
import '../entities/audio_track_metadata.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../services/audio_playback_service.dart';
import '../../../audio_cache/shared/domain/repositories/audio_storage_repository.dart';
import '../../../audio_track/domain/entities/audio_track.dart';

/// Pure playlist playback use case
/// ONLY handles playlist queue setup and playback - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
@injectable
class PlayPlaylistUseCase {
  const PlayPlaylistUseCase({
    required PlaylistRepository playlistRepository,
    required AudioTrackRepository audioTrackRepository,
    required AudioPlaybackService playbackService,
    required AudioStorageRepository audioStorageRepository,
  }) : _playlistRepository = playlistRepository,
       _audioTrackRepository = audioTrackRepository,
       _playbackService = playbackService,
       _audioStorageRepository = audioStorageRepository;

  final PlaylistRepository _playlistRepository;
  final AudioTrackRepository _audioTrackRepository;
  final AudioPlaybackService _playbackService;
  final AudioStorageRepository _audioStorageRepository;

  /// Play playlist or custom track list, starting from specified index
  /// Handles: playlist loading, cache validation, queue setup, playback initiation
  /// Does NOT handle: user permissions, collaborator data, business rules
  Future<Either<AudioFailure, void>> call({
    PlaylistId? playlistId,
    List<AudioTrack>? tracks,
    int startIndex = 0,
  }) async {
    try {
      List<AudioTrack> trackList = [];
      if (playlistId != null) {
        final playlistResult = await _playlistRepository.getPlaylistById(
          playlistId,
        );

        // Handle the Either result properly
        final playlistError = playlistResult.fold(
          (failure) => failure.message,
          (playlist) {
            if (playlist == null) {
              return 'Playlist not found: ${playlistId.value}';
            }
            if (playlist.trackIds.isEmpty) {
              return 'Playlist is empty: ${playlistId.value}';
            }

            // Success case - store playlist for processing
            return null; // null means no error
          },
        );

        if (playlistError != null) {
          return Left(PlaylistFailure(playlistError));
        }

        // Extract playlist from Either
        final playlist = playlistResult.fold(
          (failure) => null,
          (playlist) => playlist,
        );

        if (playlist != null) {
          // Load tracks from playlist
          for (final trackId in playlist.trackIds) {
            final trackOrFailure = await _audioTrackRepository.getTrackById(
              AudioTrackId.fromUniqueString(trackId),
            );
            trackOrFailure.fold((failure) {}, (track) {
              trackList.add(track);
            });
          }
        }
      } else if (tracks != null) {
        trackList = tracks;
      } else {
        return Left(PlaylistFailure('No playlistId or tracks provided'));
      }
      if (trackList.isEmpty) {
        return Left(PlaylistFailure('No tracks to play'));
      }
      // 2. Create audio sources for all tracks, preferring cache if available
      final audioSources = <AudioSource>[];
      for (final track in trackList) {
        String? urlToUse;
        final cacheResult = await _audioStorageRepository.getCachedAudioPath(
          track.id,
        );
        cacheResult.fold(
          (failure) {
            // Use remote URL if cache fails
            if (track.url.isNotEmpty) urlToUse = track.url;
          },
          (cachedPath) {
            if (cachedPath.isNotEmpty) {
              urlToUse = cachedPath;
            } else if (track.url.isNotEmpty) {
              urlToUse = track.url;
            }
          },
        );
        // Validate fallback: if it's a local path, ensure it still exists;
        // if it's remote, require http(s) scheme.
        if (urlToUse != null && urlToUse!.isNotEmpty) {
          final looksLocal =
              urlToUse!.startsWith('/') || urlToUse!.startsWith('file://');
          if (looksLocal) {
            final filePath =
                urlToUse!.startsWith('file://')
                    ? urlToUse!.replaceFirst('file://', '')
                    : urlToUse!;
            if (!File(filePath).existsSync()) {
              urlToUse = null; // discard stale temp path
            }
          } else {
            final uri = Uri.tryParse(urlToUse!);
            if (uri == null ||
                (uri.scheme != 'http' && uri.scheme != 'https')) {
              urlToUse = null;
            }
          }
        }
        if (urlToUse != null && urlToUse!.isNotEmpty) {
          final metadata = AudioTrackMetadata(
            id: track.id,
            title: track.name,
            artist: track.uploadedBy.value,
            duration: track.duration,
          );
          audioSources.add(AudioSource(url: urlToUse!, metadata: metadata));
        }
      }
      if (audioSources.isEmpty) {
        return Left(
          PlaylistFailure('No playable tracks in playlist or track list'),
        );
      }
      // Adjust start index if some tracks were skipped
      final adjustedStartIndex = startIndex.clamp(0, audioSources.length - 1);
      await _playbackService.loadQueue(
        audioSources,
        startIndex: adjustedStartIndex,
      );
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('not found')) {
        return Left(PlaylistFailure('Playlist not found'));
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

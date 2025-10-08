import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/audio_failure.dart';
import '../../../playlist/domain/repositories/playlist_repository.dart';
import '../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../../../track_version/domain/repositories/track_version_repository.dart';
import '../entities/audio_source.dart';
import '../entities/audio_track_metadata.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../services/audio_playback_service.dart';
import '../../../audio_cache/domain/repositories/audio_storage_repository.dart';
import '../../../audio_track/domain/entities/audio_track.dart';

/// Pure playlist playback use case
/// ONLY handles playlist queue setup and playback - NO business domain concerns
/// NO: UserProfile fetching, collaborator logic, project context
/// Uses version-aware caching for correct active version playback
@injectable
class PlayPlaylistUseCase {
  const PlayPlaylistUseCase({
    required PlaylistRepository playlistRepository,
    required AudioTrackRepository audioTrackRepository,
    required TrackVersionRepository trackVersionRepository,
    required AudioPlaybackService playbackService,
    required AudioStorageRepository audioStorageRepository,
  }) : _playlistRepository = playlistRepository,
       _audioTrackRepository = audioTrackRepository,
       _trackVersionRepository = trackVersionRepository,
       _playbackService = playbackService,
       _audioStorageRepository = audioStorageRepository;

  final PlaylistRepository _playlistRepository;
  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;
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

      // 2. Create audio sources for all tracks using version-aware resolution
      final audioSources = <AudioSource>[];
      for (final track in trackList) {
        // Skip tracks without active version
        if (track.activeVersionId == null) {
          continue;
        }

        // Get the active version for this track
        final versionResult = await _trackVersionRepository.getById(
          track.activeVersionId!,
        );

        await versionResult.fold(
          (failure) async {
            // Skip this track if version not found
            return;
          },
          (version) async {
            String? urlToUse;

            // 3. Try version-aware cache lookup first
            final cacheResult = await _audioStorageRepository.getCachedAudioPath(
              track.id,
              versionId: version.id,
            );

            cacheResult.fold(
              (failure) {
                // Cache miss - will try version's file sources below
                urlToUse = null;
              },
              (cachedPath) {
                if (cachedPath.isNotEmpty) {
                  urlToUse = cachedPath;
                }
                // else: cache path empty, will try version's file sources below
              },
            );

            // 4. If no cached path, try version's local file first, then remote
            if (urlToUse == null || urlToUse!.isEmpty) {
              // Try fileLocalPath first if available
              if (version.fileLocalPath != null &&
                  version.fileLocalPath!.isNotEmpty) {
                final filePath = version.fileLocalPath!.startsWith('file://')
                    ? version.fileLocalPath!.replaceFirst('file://', '')
                    : version.fileLocalPath!;

                // Validate local file exists
                if (File(filePath).existsSync()) {
                  urlToUse = version.fileLocalPath;
                }
                // If local file doesn't exist, fall through to remote URL
              }

              // If no valid local file, use remote URL
              if ((urlToUse == null || urlToUse!.isEmpty) &&
                  version.fileRemoteUrl != null &&
                  version.fileRemoteUrl!.isNotEmpty) {
                urlToUse = version.fileRemoteUrl;
              }
            }

            // 5. Validate final URL
            if (urlToUse != null && urlToUse!.isNotEmpty) {
              final looksLocal =
                  urlToUse!.startsWith('/') || urlToUse!.startsWith('file://');
              if (looksLocal) {
                final filePath =
                    urlToUse!.startsWith('file://')
                        ? urlToUse!.replaceFirst('file://', '')
                        : urlToUse!;
                if (!File(filePath).existsSync()) {
                  // Fallback to remote URL if local file is stale
                  if (version.fileRemoteUrl != null &&
                      version.fileRemoteUrl!.isNotEmpty) {
                    urlToUse = version.fileRemoteUrl;
                  } else {
                    urlToUse = null;
                  }
                }
              } else {
                final uri = Uri.tryParse(urlToUse!);
                if (uri == null ||
                    (uri.scheme != 'http' && uri.scheme != 'https')) {
                  urlToUse = null;
                }
              }
            }

            // 6. Create audio source with version-specific metadata
            if (urlToUse != null && urlToUse!.isNotEmpty) {
              final metadata = AudioTrackMetadata(
                id: track.id,
                title: track.name,
                artist: track.uploadedBy.value,
                duration: version.durationMs != null
                    ? Duration(milliseconds: version.durationMs!)
                    : track.duration,
                coverUrl: track.url, // Cover art URL
              );
              audioSources.add(AudioSource(url: urlToUse!, metadata: metadata));
            }
          },
        );
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

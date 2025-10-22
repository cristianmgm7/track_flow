import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import '../entities/audio_failure.dart';
import '../entities/audio_source.dart';
import '../entities/audio_track_metadata.dart';
import '../services/audio_playback_service.dart';

/// Pure version playback use case
/// ONLY handles playing specific versions - NO business domain concerns
/// Uses existing repositories directly - NO additional abstractions
@injectable
class PlayVersionUseCase {
  const PlayVersionUseCase({
    required AudioTrackRepository audioTrackRepository,
    required AudioStorageRepository audioStorageRepository,
    required TrackVersionRepository trackVersionRepository,
    required AudioPlaybackService playbackService,
  }) : _audioTrackRepository = audioTrackRepository,
       _audioStorageRepository = audioStorageRepository,
       _trackVersionRepository = trackVersionRepository,
       _playbackService = playbackService;

  final AudioTrackRepository _audioTrackRepository;
  final AudioStorageRepository _audioStorageRepository;
  final TrackVersionRepository _trackVersionRepository;
  final AudioPlaybackService _playbackService;

  /// Play specific version by ID
  /// Handles: version fetching, track metadata fetching, source resolution, playback initiation
  /// Does NOT handle: user context, collaborator data, project information, active version management
  Future<Either<AudioFailure, void>> call(TrackVersionId versionId) async {
    try {
      // 1. Get version from repository
      final versionResult = await _trackVersionRepository.getById(versionId);

      return await versionResult.fold(
        (failure) async => Left(VersionNotFoundFailure(versionId.value)),
        (version) async {
          // 2. Get track from business repository for metadata
          final trackResult = await _audioTrackRepository.getTrackById(
            version.trackId,
          );

          return await trackResult.fold(
            (failure) async =>
                Left(TrackNotFoundFailure(version.trackId.value)),
            (audioTrack) async {
              String? sourceUrl;

              // 3. Try version-aware cache first
              final cacheResult = await _audioStorageRepository
                  .getCachedAudioPath(audioTrack.id, versionId: versionId);

              cacheResult.fold(
                (cacheFailure) {
                  // Cache miss - will try version sources below
                  sourceUrl = null;
                },
                (cachedPath) {
                  if (cachedPath.isNotEmpty) {
                    sourceUrl = cachedPath;
                  }
                },
              );

              // 4. If no cache, try version's local file first, then remote
              if (sourceUrl == null || sourceUrl!.isEmpty) {
                // Try fileLocalPath if available
                if (version.fileLocalPath != null &&
                    version.fileLocalPath!.isNotEmpty) {
                  final filePath = version.fileLocalPath!.startsWith('file://')
                      ? version.fileLocalPath!.replaceFirst('file://', '')
                      : version.fileLocalPath!;

                  // Validate local file exists
                  if (File(filePath).existsSync()) {
                    sourceUrl = version.fileLocalPath;
                  }
                }

                // If no valid local file, use remote URL
                if ((sourceUrl == null || sourceUrl!.isEmpty) &&
                    version.fileRemoteUrl != null &&
                    version.fileRemoteUrl!.isNotEmpty) {
                  sourceUrl = version.fileRemoteUrl;
                }
              }

              // Validate we have a source
              if (sourceUrl == null || sourceUrl!.isEmpty) {
                return Left(
                  AudioSourceFailure(
                    'No audio source available for version ${versionId.value}',
                  ),
                );
              }

              final finalSourceUrl = sourceUrl!;

              // 5. Convert to pure audio metadata using track info
              final metadata = AudioTrackMetadata(
                id: audioTrack.id,
                title: audioTrack.name,
                artist: audioTrack.uploadedBy.value,
                duration:
                    version.durationMs != null
                        ? Duration(milliseconds: version.durationMs!)
                        : audioTrack.duration,
                coverUrl: audioTrack.coverUrl, // Use track URL as cover art
              );

              // 6. Create audio source for playback using version file
              final audioSource = AudioSource(
                url: finalSourceUrl,
                metadata: metadata,
              );

              // 7. Initiate playback (pure audio operation)
              await _playbackService.play(audioSource);

              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      // Handle version-specific errors
      if (e.toString().contains('not found')) {
        return Left(VersionNotFoundFailure(versionId.value));
      } else if (e.toString().contains('network')) {
        return const Left(NetworkFailure());
      } else if (e.toString().contains('source')) {
        return Left(AudioSourceFailure(versionId.value));
      } else {
        return Left(PlaybackFailure(e.toString()));
      }
    }
  }
}

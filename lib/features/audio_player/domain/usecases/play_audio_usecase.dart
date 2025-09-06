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

/// Pure audio playback use case
/// ONLY handles audio playback - NO business domain concerns
/// Uses existing repositories directly - NO additional abstractions
@injectable
class PlayAudioUseCase {
  const PlayAudioUseCase({
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

  /// Play audio track by ID
  /// Handles: metadata fetching, source resolution, playback initiation
  /// Does NOT handle: user context, collaborator data, project information
  Future<Either<AudioFailure, void>> call(AudioTrackId trackId) async {
    try {
      // 1. Get track from business repository
      final trackResult = await _audioTrackRepository.getTrackById(trackId);

      return await trackResult.fold(
        (failure) async => Left(TrackNotFoundFailure(trackId.value)),
        (audioTrack) async {
          // 2. Determine audio source URL
          String sourceUrl;

          if (audioTrack.activeVersionId != null) {
            // Use active version if available
            final versionResult = await _trackVersionRepository.getById(
              audioTrack.activeVersionId!,
            );

            sourceUrl = await versionResult.fold(
              (failure) async => '', // No fallback URL available
              (version) async {
                // Use version file path if available
                return version.fileLocalPath ?? version.fileRemoteUrl ?? '';
              },
            );
          } else {
            // No active version set
            sourceUrl = '';
          }

          // 3. Try to get cached path first, fallback to source URL
          final cacheResult = await _audioStorageRepository.getCachedAudioPath(
            trackId,
          );
          final finalSourceUrl = cacheResult.fold(
            (cacheFailure) => sourceUrl, // Use source URL if not cached
            (cachedPath) => cachedPath, // Use cached file if available
          );

          // 4. Convert to pure audio metadata
          final metadata = AudioTrackMetadata(
            id: trackId,
            title: audioTrack.name,
            artist: audioTrack.uploadedBy.value,
            duration: audioTrack.duration,
            coverUrl: audioTrack.url, // Use track URL as cover art
          );

          // 5. Create audio source for playback
          final audioSource = AudioSource(
            url: finalSourceUrl,
            metadata: metadata,
          );

          // 6. Initiate playback (pure audio operation)
          await _playbackService.play(audioSource);

          return const Right(null);
        },
      );
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

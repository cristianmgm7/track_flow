import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart' as core_ids;

import '../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../../domain/entities/audio_track_id.dart';
import '../../domain/entities/audio_track_metadata.dart';
import '../../domain/entities/playlist_id.dart';
import '../../domain/repositories/audio_content_repository.dart';
import '../services/audio_source_resolver.dart';

/// Pure audio content repository implementation
/// Bridges business domain data to pure audio architecture
/// Transforms AudioTrack (business) -> AudioTrackMetadata (pure audio)
@LazySingleton(as: AudioContentRepository)
class AudioContentRepositoryImpl implements AudioContentRepository {
  const AudioContentRepositoryImpl(
    this._audioTrackRepository,
    this._audioSourceResolver,
  );

  final AudioTrackRepository _audioTrackRepository;
  final AudioSourceResolver _audioSourceResolver;

  @override
  Future<AudioTrackMetadata> getTrackMetadata(AudioTrackId trackId) async {
    // Get business domain track data
    final trackResult = await _audioTrackRepository.getTrackById(
      core_ids.AudioTrackId.fromUniqueString(trackId.value),
    );

    return trackResult.fold(
      (failure) => throw Exception('Track not found: ${trackId.value}'),
      (audioTrack) {
        // Transform to pure audio metadata (remove business context)
        return AudioTrackMetadata(
          id: trackId,
          title: audioTrack.name,
          artist: 'Unknown Artist', // AudioTrack doesn't have artist field
          duration: audioTrack.duration,
          coverUrl: null, // AudioTrack doesn't have cover URL
          // NO: UserProfile, ProjectId, collaborators, etc.
        );
      },
    );
  }

  @override
  Future<List<AudioTrackMetadata>> getPlaylistTracks(
    PlaylistId playlistId,
  ) async {
    // For now, return empty list as playlist functionality is not implemented
    // in the current AudioTrackRepository interface
    // TODO: Implement playlist support in business domain first
    return [];
  }

  @override
  Future<String> getAudioSourceUrl(AudioTrackId trackId) async {
    // Get the original audio URL from business domain
    final trackResult = await _audioTrackRepository.getTrackById(
      core_ids.AudioTrackId.fromUniqueString(trackId.value),
    );

    return trackResult.fold(
      (failure) => throw Exception('Track not found: ${trackId.value}'),
      (audioTrack) async {
        final originalUrl = audioTrack.url;

        // Use audio source resolver with track ID for consistent cache lookup
        // (cached vs streaming based on offline mode, availability, etc.)
        final sourceResult = await _audioSourceResolver.resolveAudioSource(
          originalUrl,
          trackId:
              trackId.value, // Pass track ID for consistent cache operations
        );

        return sourceResult.fold(
          (failure) =>
              throw Exception('Audio source not available: ${trackId.value}'),
          (resolvedUrl) => resolvedUrl,
        );
      },
    );
  }

  @override
  Future<bool> isTrackCached(AudioTrackId trackId) async {
    // Get track URL first
    final trackResult = await _audioTrackRepository.getTrackById(
      core_ids.AudioTrackId.fromUniqueString(trackId.value),
    );

    return trackResult.fold((failure) => false, (audioTrack) async {
      // Check if the track's URL is cached using consistent track ID
      return await _audioSourceResolver.isTrackCached(
        audioTrack.url,
        trackId: trackId.value, // Pass track ID for consistent cache operations
      );
    });
  }

  @override
  Future<List<AudioTrackMetadata>> getTracksMetadata(
    List<AudioTrackId> trackIds,
  ) async {
    final metadataList = <AudioTrackMetadata>[];

    for (final trackId in trackIds) {
      try {
        final metadata = await getTrackMetadata(trackId);
        metadataList.add(metadata);
      } catch (e) {
        // Skip tracks that can't be loaded
        continue;
      }
    }

    return metadataList;
  }

  @override
  Stream<AudioTrackMetadata> watchTrackMetadata(AudioTrackId trackId) async* {
    // For now, just yield the current metadata once
    // TODO: Implement real-time updates when business domain supports it
    try {
      final metadata = await getTrackMetadata(trackId);
      yield metadata;
    } catch (e) {
      // Stream ends if track can't be loaded
      return;
    }
  }
}

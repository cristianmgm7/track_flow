import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:math';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class PlayPlaylistUseCase {
  final PlaybackService _playbackService;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final AudioSourceResolver _audioSourceResolver;

  PlayPlaylistUseCase(
    this._playbackService,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._audioSourceResolver,
  );

  Future<Either<Failure, PlayPlaylistResult>> call({
    required Playlist playlist,
    required int startIndex,
    PlaybackQueueMode queueMode = PlaybackQueueMode.normal,
  }) async {
    try {
      final queue = playlist.trackIds;
      if (queue.isEmpty || startIndex >= queue.length) {
        return left(const ValidationFailure('Invalid playlist or start index'));
      }

      // Generate shuffled queue if needed
      final shuffledQueue = _generateShuffledQueue(queue);

      // Get current track to play
      final trackId = queue[startIndex];
      final track = await _getAudioTrackById(trackId);
      if (track.isLeft()) {
        return left(track.fold((l) => l, (r) => throw Exception()));
      }
      final audioTrack = track.getOrElse(() => throw Exception());

      // Get collaborator
      final collaboratorResult = await _getCollaboratorForTrack(audioTrack);
      if (collaboratorResult.isLeft()) {
        return left(collaboratorResult.fold((l) => l, (r) => throw Exception()));
      }
      final collaborator = collaboratorResult.getOrElse(() => throw Exception());

      // Resolve audio source and start playback
      final pathResult = await _audioSourceResolver.resolveAudioSource(audioTrack.url);
      final path = pathResult.getOrElse(() => audioTrack.url);
      await _playbackService.play(url: path);

      return right(PlayPlaylistResult(
        playlist: playlist,
        queue: queue,
        shuffledQueue: shuffledQueue,
        currentIndex: startIndex,
        track: audioTrack,
        collaborator: collaborator,
        resolvedPath: path,
      ));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Future<Either<Failure, AudioTrack>> _getAudioTrackById(String id) async {
    final result = await _audioTrackRepository.getTrackById(
      AudioTrackId.fromUniqueString(id),
    );
    return result.fold(
      (failure) => left(failure),
      (track) => right(track),
    );
  }

  Future<Either<Failure, UserProfile>> _getCollaboratorForTrack(AudioTrack track) async {
    final result = await _userProfileRepository.getUserProfilesByIds([
      track.uploadedBy.value,
    ]);
    return result.fold(
      (failure) => left(failure),
      (profiles) => profiles.isNotEmpty
          ? right(profiles.first)
          : left(const UnexpectedFailure('Collaborator not found')),
    );
  }

  List<String> _generateShuffledQueue(List<String> originalQueue) {
    if (originalQueue.isEmpty) return [];
    final shuffled = List<String>.from(originalQueue);
    shuffled.shuffle(Random());
    return shuffled;
  }
}

class PlayPlaylistResult {
  final Playlist playlist;
  final List<String> queue;
  final List<String> shuffledQueue;
  final int currentIndex;
  final AudioTrack track;
  final UserProfile collaborator;
  final String resolvedPath;

  PlayPlaylistResult({
    required this.playlist,
    required this.queue,
    required this.shuffledQueue,
    required this.currentIndex,
    required this.track,
    required this.collaborator,
    required this.resolvedPath,
  });
}
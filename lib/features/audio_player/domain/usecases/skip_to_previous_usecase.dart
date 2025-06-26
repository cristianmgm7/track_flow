import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class SkipToPreviousUseCase {
  final PlaybackService _playbackService;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final AudioSourceResolver _audioSourceResolver;

  SkipToPreviousUseCase(
    this._playbackService,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._audioSourceResolver,
  );

  Future<Either<Failure, SkipResult?>> call({
    required List<String> queue,
    required List<String> shuffledQueue,
    required int currentIndex,
    required RepeatMode repeatMode,
    required PlaybackQueueMode queueMode,
  }) async {
    try {
      final previousIndex = _getPreviousTrackIndex(
        queue: queue,
        shuffledQueue: shuffledQueue,
        currentIndex: currentIndex,
        repeatMode: repeatMode,
        queueMode: queueMode,
      );

      if (previousIndex == -1) {
        return right(null); // No previous track available
      }

      final currentQueue = queueMode == PlaybackQueueMode.shuffle 
          ? shuffledQueue 
          : queue;
      final trackId = currentQueue[previousIndex];

      // Get track and collaborator
      final trackResult = await _getAudioTrackById(trackId);
      if (trackResult.isLeft()) {
        return left(trackResult.fold((l) => l, (r) => throw Exception()));
      }
      final track = trackResult.getOrElse(() => throw Exception());

      final collaboratorResult = await _getCollaboratorForTrack(track);
      if (collaboratorResult.isLeft()) {
        return left(collaboratorResult.fold((l) => l, (r) => throw Exception()));
      }
      final collaborator = collaboratorResult.getOrElse(() => throw Exception());

      // Resolve audio source and play
      final pathResult = await _audioSourceResolver.resolveAudioSource(track.url);
      final path = pathResult.getOrElse(() => track.url);
      await _playbackService.play(url: path);

      return right(SkipResult(
        track: track,
        collaborator: collaborator,
        newIndex: previousIndex,
        resolvedPath: path,
      ));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  int _getPreviousTrackIndex({
    required List<String> queue,
    required List<String> shuffledQueue,
    required int currentIndex,
    required RepeatMode repeatMode,
    required PlaybackQueueMode queueMode,
  }) {
    final currentQueue = queueMode == PlaybackQueueMode.shuffle 
        ? shuffledQueue 
        : queue;
    final previousIndex = currentIndex - 1;

    if (previousIndex >= 0) {
      return previousIndex;
    } else if (repeatMode == RepeatMode.queue) {
      return currentQueue.length - 1; // Loop to end
    }

    return -1; // Beginning of queue
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
}

class SkipResult {
  final AudioTrack track;
  final UserProfile collaborator;
  final int newIndex;
  final String resolvedPath;

  SkipResult({
    required this.track,
    required this.collaborator,
    required this.newIndex,
    required this.resolvedPath,
  });
}
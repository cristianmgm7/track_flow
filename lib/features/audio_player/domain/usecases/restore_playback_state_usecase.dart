import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'dart:math';

@lazySingleton
class RestorePlaybackStateUseCase {
  final PlaybackStatePersistence _playbackStatePersistence;
  final PlaybackService _playbackService;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;

  RestorePlaybackStateUseCase(
    this._playbackStatePersistence,
    this._playbackService,
    this._audioTrackRepository,
    this._userProfileRepository,
  );

  Future<Either<Failure, RestoreResult?>> call() async {
    final result = await _playbackStatePersistence.restorePlaybackState();
    
    return result.fold(
      (failure) => left(failure),
      (persistedState) async {
        if (persistedState == null || persistedState.queue.isEmpty) {
          return right(null);
        }

        try {
          if (persistedState.currentTrackId != null) {
            final track = await _getAudioTrackById(persistedState.currentTrackId!);
            if (track.isLeft()) {
              return left(track.fold((l) => l, (r) => throw Exception()));
            }
            final audioTrack = track.getOrElse(() => throw Exception());

            final collaboratorResult = await _getCollaboratorForTrack(audioTrack);
            if (collaboratorResult.isLeft()) {
              return left(collaboratorResult.fold((l) => l, (r) => throw Exception()));
            }
            final collaborator = collaboratorResult.getOrElse(() => throw Exception());

            // Generate shuffled queue if needed
            final shuffledQueue = persistedState.queueMode == PlaybackQueueMode.shuffle
                ? _generateShuffledQueue(persistedState.queue)
                : <String>[];

            // Optionally seek to last position when restoring
            if (persistedState.lastPosition > Duration.zero) {
              await _playbackService.seek(persistedState.lastPosition);
            }

            return right(RestoreResult(
              track: audioTrack,
              collaborator: collaborator,
              queue: persistedState.queue,
              shuffledQueue: shuffledQueue,
              currentIndex: persistedState.currentIndex,
              repeatMode: persistedState.repeatMode,
              queueMode: persistedState.queueMode,
              lastPosition: persistedState.lastPosition,
              wasPlaying: persistedState.wasPlaying,
            ));
          }
          return right(null);
        } catch (e) {
          return left(UnexpectedFailure(e.toString()));
        }
      },
    );
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

class RestoreResult {
  final AudioTrack track;
  final UserProfile collaborator;
  final List<String> queue;
  final List<String> shuffledQueue;
  final int currentIndex;
  final RepeatMode repeatMode;
  final PlaybackQueueMode queueMode;
  final Duration lastPosition;
  final bool wasPlaying;

  RestoreResult({
    required this.track,
    required this.collaborator,
    required this.queue,
    required this.shuffledQueue,
    required this.currentIndex,
    required this.repeatMode,
    required this.queueMode,
    required this.lastPosition,
    required this.wasPlaying,
  });
}
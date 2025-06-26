import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';

@lazySingleton
class PlayAudioUseCase {
  final PlaybackService _playbackService;
  final UserProfileRepository _userProfileRepository;
  final AudioSourceResolver _audioSourceResolver;

  PlayAudioUseCase(
    this._playbackService,
    this._userProfileRepository,
    this._audioSourceResolver,
  );

  Future<Either<Failure, PlayAudioResult>> call(AudioTrack track) async {
    try {
      // Get collaborator for track
      final collaboratorResult = await _getCollaboratorForTrack(track);
      if (collaboratorResult.isLeft()) {
        return left(collaboratorResult.fold((l) => l, (r) => throw Exception()));
      }
      final collaborator = collaboratorResult.getOrElse(() => throw Exception());

      // Resolve audio source
      final pathResult = await _audioSourceResolver.resolveAudioSource(track.url);
      final path = pathResult.getOrElse(() => track.url);

      // Start playback
      await _playbackService.play(url: path);

      return right(PlayAudioResult(
        track: track,
        collaborator: collaborator,
        resolvedPath: path,
      ));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
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

class PlayAudioResult {
  final AudioTrack track;
  final UserProfile collaborator;
  final String resolvedPath;

  PlayAudioResult({
    required this.track,
    required this.collaborator,
    required this.resolvedPath,
  });
}
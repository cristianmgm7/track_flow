import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart';

class AudioCommentsBundle {
  final AudioTrack track;
  final List<AudioComment> comments;
  final List<UserProfile> collaborators;

  AudioCommentsBundle({
    required this.track,
    required this.comments,
    required this.collaborators,
  });
}

@lazySingleton
class WatchAudioCommentsBundleUseCase {
  final AudioTrackRepository _audioTrackRepository;
  final AudioCommentRepository _audioCommentRepository;
  final UserProfileCacheRepository _userProfileCacheRepository;

  WatchAudioCommentsBundleUseCase(
    this._audioTrackRepository,
    this._audioCommentRepository,
    this._userProfileCacheRepository,
  );

  Stream<Either<Failure, AudioCommentsBundle>> call({
    required ProjectId projectId,
    required AudioTrackId trackId,
  }) {
    // Stream of the specific track by ID
    final track$ = _audioTrackRepository
        .watchTrackById(trackId)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    // Stream of comments for the track
    final comments$ = _audioCommentRepository
        .watchCommentsByTrack(trackId)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    // Stream of collaborators derived from the comments' authors
    final collaborators$ = comments$
        .switchMap<Either<Failure, List<UserProfile>>>((eitherComments) {
          return eitherComments.fold((failure) => Stream.value(left(failure)), (
            comments,
          ) {
            if (comments.isEmpty) {
              return Stream.value(right(<UserProfile>[]));
            }
            final ids = comments.map((c) => c.createdBy).toSet().toList();
            return _userProfileCacheRepository
                .watchUserProfilesByIds(ids)
                .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));
          });
        })
        .shareReplay(maxSize: 1);

    return Rx.combineLatest3<
      Either<Failure, AudioTrack>,
      Either<Failure, List<AudioComment>>,
      Either<Failure, List<UserProfile>>,
      Either<Failure, AudioCommentsBundle>
    >(track$, comments$, collaborators$, (
      Either<Failure, AudioTrack> trackEither,
      Either<Failure, List<AudioComment>> commentsEither,
      Either<Failure, List<UserProfile>> collaboratorsEither,
    ) {
      return trackEither.fold(
        (failure) => left(failure),
        (track) => commentsEither.fold(
          (failure) => left(failure),
          (comments) => collaboratorsEither.fold(
            (failure) => left(failure),
            (collaborators) => right(
              AudioCommentsBundle(
                track: track,
                comments: comments,
                collaborators: collaborators,
              ),
            ),
          ),
        ),
      );
    }).onErrorReturnWith(
      (e, _) =>
          left(ServerFailure('Failed to watch audio comments bundle: $e')),
    );
  }
}

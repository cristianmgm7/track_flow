import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class ProjectDetailBundle {
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  final List<AudioComment> comments;

  ProjectDetailBundle({
    required this.tracks,
    required this.collaborators,
    required this.comments,
  });
}

@lazySingleton
class WatchProjectDetailUseCase {
  final AudioTrackLocalDataSource tracksLocal;
  final UserProfileLocalDataSource userProfilesLocal;
  final AudioCommentLocalDataSource commentsLocal;

  WatchProjectDetailUseCase(
    this.tracksLocal,
    this.userProfilesLocal,
    this.commentsLocal,
  );

  Stream<Either<Failure, ProjectDetailBundle>> call({
    required String projectId,
    required List<String> collaboratorIds,
  }) {
    final tracks$ = tracksLocal
        .watchTracksByProject(ProjectId.fromUniqueString(projectId))
        .map(
          (either) => either.fold<Either<Failure, List<AudioTrack>>>(
            (failure) => left(failure),
            (dtos) => right(dtos.map((dto) => dto.toDomain()).toList()),
          ),
        )
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));

    final users$ = userProfilesLocal
        .watchUserProfilesByIds(collaboratorIds.map((id) => UserId.fromUniqueString(id)).toList())
        .map(
          (either) => either.fold<Either<Failure, List<UserProfile>>>(
            (failure) => left(failure),
            (dtos) => right(dtos.map((dto) => dto.toDomain()).toList()),
          ),
        )
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));

    final comments$ = commentsLocal
        .watchCommentsByTrack(AudioTrackId.fromUniqueString(projectId))
        .map(
          (either) => either.fold<Either<Failure, List<AudioComment>>>(
            (failure) => left(failure),
            (dtos) => right(dtos.map((dto) => dto.toDomain()).toList()),
          ),
        )
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));

    return Rx.combineLatest3<
      Either<Failure, List<AudioTrack>>,
      Either<Failure, List<UserProfile>>,
      Either<Failure, List<AudioComment>>,
      Either<Failure, ProjectDetailBundle>
    >(tracks$, users$, comments$, (
      Either<Failure, List<AudioTrack>> tracks,
      Either<Failure, List<UserProfile>> users,
      Either<Failure, List<AudioComment>> comments,
    ) {
      return right(
        ProjectDetailBundle(
          tracks: tracks.getOrElse(() => []),
          collaborators: users.getOrElse(() => []),
          comments: comments.getOrElse(() => []),
        ),
      );
    });
  }
}

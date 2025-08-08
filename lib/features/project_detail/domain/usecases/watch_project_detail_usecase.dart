import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart';

class ProjectDetailBundle {
  final Project project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;

  ProjectDetailBundle({
    required this.project,
    required this.tracks,
    required this.collaborators,
  });
}

@lazySingleton
class WatchProjectDetailUseCase {
  final ProjectsRepository _projectsRepository;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileCacheRepository _userProfileCacheRepository;

  WatchProjectDetailUseCase(
    this._projectsRepository,
    this._audioTrackRepository,
    this._userProfileCacheRepository,
  );

  Stream<Either<Failure, ProjectDetailBundle>> call({
    required String projectId,
  }) {
    final ProjectId pid = ProjectId.fromUniqueString(projectId);

    final project$ = _projectsRepository
        .watchProjectById(pid)
        .shareReplay(maxSize: 1);

    // Tracks stream depends only on project id
    final tracks$ = _audioTrackRepository
        .watchTracksByProject(pid)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));

    // Profiles stream depends on project collaborators, so switch on project
    final profiles$ = project$.switchMap<Either<Failure, List<UserProfile>>>((
      eitherProject,
    ) {
      return eitherProject.fold((failure) => Stream.value(left(failure)), (
        project,
      ) {
        if (project == null) {
          return Stream.value(
            left<Failure, List<UserProfile>>(
              DatabaseFailure('Project not found in local cache'),
            ),
          );
        }
        final ids = project.collaborators.map((c) => c.userId).toList();
        return _userProfileCacheRepository
            .watchUserProfilesByIds(ids)
            .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));
      });
    });

    return Rx.combineLatest3<
      Either<Failure, Project?>,
      Either<Failure, List<AudioTrack>>,
      Either<Failure, List<UserProfile>>,
      Either<Failure, ProjectDetailBundle>
    >(project$, tracks$, profiles$, (
      Either<Failure, Project?> projectEither,
      Either<Failure, List<AudioTrack>> tracksEither,
      Either<Failure, List<UserProfile>> profilesEither,
    ) {
      return projectEither.fold((failure) => left(failure), (project) {
        if (project == null) {
          return left(DatabaseFailure('Project not found in local cache'));
        }

        final tracks = tracksEither.getOrElse(() => []);
        final profiles = profilesEither.getOrElse(() => []);
        return right(
          ProjectDetailBundle(
            project: project,
            tracks: tracks,
            collaborators: profiles,
          ),
        );
      });
    }).onErrorReturnWith(
      (e, _) => left(ServerFailure('Failed to watch project detail: $e')),
    );
  }
}

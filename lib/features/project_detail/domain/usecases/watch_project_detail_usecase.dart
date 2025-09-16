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
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/project_detail/domain/entities/active_version_summary.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

class ProjectDetailBundle {
  final Project project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  final Map<String, ActiveVersionSummary> activeVersionsByTrackId;

  ProjectDetailBundle({
    required this.project,
    required this.tracks,
    required this.collaborators,
    required this.activeVersionsByTrackId,
  });
}

@lazySingleton
class WatchProjectDetailUseCase {
  final ProjectsRepository _projectsRepository;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileCacheRepository _userProfileCacheRepository;
  final TrackVersionRepository _trackVersionRepository;

  WatchProjectDetailUseCase(
    this._projectsRepository,
    this._audioTrackRepository,
    this._userProfileCacheRepository,
    this._trackVersionRepository,
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
        // Build active versions summary map by listening to each track's versions
        // Note: we avoid N subscriptions here by reusing the repository's shared streams
        final summaries = <String, ActiveVersionSummary>{};
        for (final t in tracks) {
          final activeId = t.activeVersionId;
          if (activeId == null) {
            summaries[t.id.value] = ActiveVersionSummary(
              trackId: t.id.value,
              versionId: '',
              status: TrackVersionStatus.processing,
              fileRemoteUrl: null,
              durationMs: null,
            );
            continue;
          }

          final activeEither = _trackVersionRepository.getById(activeId);
          activeEither.then((res) {
            res.fold(
              (_) {
                summaries[t.id.value] = ActiveVersionSummary(
                  trackId: t.id.value,
                  versionId: activeId.value,
                  status: TrackVersionStatus.failed,
                  fileRemoteUrl: null,
                  durationMs: null,
                );
              },
              (v) {
                summaries[t.id.value] = ActiveVersionSummary(
                  trackId: t.id.value,
                  versionId: v.id.value,
                  status: v.status,
                  fileRemoteUrl: v.fileRemoteUrl,
                  durationMs: v.durationMs,
                );
              },
            );
          });
          // Note: this is a synchronous combine; we best-effort fill summaries.
          // Next emissions from tracks$ will refresh this data as versions persist.
          if (!summaries.containsKey(t.id.value)) {
            summaries[t.id.value] = ActiveVersionSummary(
              trackId: t.id.value,
              versionId: activeId.value,
              status: TrackVersionStatus.processing,
              fileRemoteUrl: null,
              durationMs: null,
            );
          }
        }

        return right(
          ProjectDetailBundle(
            project: project,
            tracks: tracks,
            collaborators: profiles,
            activeVersionsByTrackId: summaries,
          ),
        );
      });
    }).onErrorReturnWith(
      (e, _) => left(ServerFailure('Failed to watch project detail: $e')),
    );
  }
}

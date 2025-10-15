import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/dashboard/domain/entities/dashboard_bundle.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

@lazySingleton
class WatchDashboardBundleUseCase {
  final ProjectsRepository _projectsRepository;
  final AudioTrackRepository _audioTrackRepository;
  final AudioCommentRepository _audioCommentRepository;
  final SessionStorage _sessionStorage;

  // Dashboard preview limits
  static const int maxProjects = 6;
  static const int maxTracks = 6;
  static const int maxComments = 8;

  WatchDashboardBundleUseCase(
    this._projectsRepository,
    this._audioTrackRepository,
    this._audioCommentRepository,
    this._sessionStorage,
  );

  Stream<Either<Failure, DashboardBundle>> call() async* {
    // Get current user ID
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      yield left(AuthenticationFailure('No user found'));
      return;
    }

    final uid = UserId.fromUniqueString(userId);

    // Stream 1: Projects (already filtered by repository)
    final projects$ = _projectsRepository
        .watchLocalProjects(uid)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    // Stream 2: Tracks (filtered by accessible projects)
    final tracks$ = _audioTrackRepository
        .watchAllAccessibleTracks(uid)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    // Stream 3: Comments (filtered by accessible projects, already limited)
    final comments$ = _audioCommentRepository
        .watchRecentComments(userId: uid, limit: maxComments)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    // Combine all three streams
    await for (final bundle in Rx.combineLatest3<
        Either<Failure, List<Project>>,
        Either<Failure, List<AudioTrack>>,
        Either<Failure, List<AudioComment>>,
        Either<Failure, DashboardBundle>>(
      projects$,
      tracks$,
      comments$,
      (
        Either<Failure, List<Project>> projectsEither,
        Either<Failure, List<AudioTrack>> tracksEither,
        Either<Failure, List<AudioComment>> commentsEither,
      ) {
        // Graceful partial failure: if any stream fails, use empty list for that section
        final projects = projectsEither.getOrElse(() => <Project>[]);
        final tracks = tracksEither.getOrElse(() => <AudioTrack>[]);
        final comments = commentsEither.getOrElse(() => <AudioComment>[]);

        // Slice to preview limits and sort
        final projectPreview = _sliceProjects(projects);
        final trackPreview = _sliceTracks(tracks);
        final commentPreview = _sliceComments(comments);

        return right(
          DashboardBundle(
            projectPreview: projectPreview,
            trackPreview: trackPreview,
            recentComments: commentPreview,
          ),
        );
      },
    ).onErrorReturnWith(
      (e, _) => left(ServerFailure('Failed to watch dashboard: $e')),
    )) {
      yield bundle;
    }
  }

  /// Slice projects to max 6, sorted by last activity descending (default sort)
  List<Project> _sliceProjects(List<Project> projects) {
    final sorted = [...projects];
    sorted.sort((a, b) {
      final aActivity = a.updatedAt ?? a.createdAt;
      final bActivity = b.updatedAt ?? b.createdAt;
      return bActivity.compareTo(aActivity); // descending
    });
    return sorted.take(maxProjects).toList();
  }

  /// Slice tracks to max 6, sorted by last updated/created descending
  List<AudioTrack> _sliceTracks(List<AudioTrack> tracks) {
    final sorted = [...tracks];
    sorted.sort((a, b) {
      // Tracks don't have updatedAt, so use createdAt
      return b.createdAt.compareTo(a.createdAt); // descending
    });
    return sorted.take(maxTracks).toList();
  }

  /// Slice comments to max 8, already sorted by repository (createdAt desc)
  List<AudioComment> _sliceComments(List<AudioComment> comments) {
    // Comments are already sorted by repository and limited,
    // but slice again for safety
    return comments.take(maxComments).toList();
  }
}



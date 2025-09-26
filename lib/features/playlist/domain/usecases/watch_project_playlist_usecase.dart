import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist_tracks_bundle.dart';
import 'package:trackflow/features/playlist/domain/entities/track_summary.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

@lazySingleton
class WatchProjectPlaylistUseCase {
  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;

  WatchProjectPlaylistUseCase(
    this._audioTrackRepository,
    this._trackVersionRepository,
  );

  Stream<Either<Failure, PlaylistTracksBundle>> call(ProjectId projectId) {
    final tracks$ = _audioTrackRepository
        .watchTracksByProject(projectId)
        .shareReplay(maxSize: 1);

    // For each set of tracks, build a consistent snapshot of summaries.
    return tracks$.switchMap((eitherTracks) {
      return eitherTracks.fold((failure) => Stream.value(left(failure)), (
        tracks,
      ) {
        if (tracks.isEmpty) {
          return Stream.value(
            right(const PlaylistTracksBundle(tracks: [], summaries: [])),
          );
        }

        // For each track, watch its versions and derive an "active" version summary.
        // We rely on the repository to keep this efficient.
        final perTrack$ = tracks.map((t) {
          return _trackVersionRepository
              .watchVersionsByTrack(t.id)
              .map(
                (eitherVersions) => eitherVersions.fold<
                  Either<Failure, TrackSummary>
                >((f) => left(f), (versions) {
                  // Determine active version: prefer track.activeVersionId, then first ready, else most recent
                  TrackVersion? active;
                  if (t.activeVersionId != null) {
                    final matching = versions.where(
                      (v) => v.id == t.activeVersionId,
                    );
                    active = matching.isNotEmpty ? matching.first : null;
                  }
                  if (active == null) {
                    final ready = versions.where(
                      (v) => v.status == TrackVersionStatus.ready,
                    );
                    active =
                        ready.isNotEmpty
                            ? ready.first
                            : (versions.isNotEmpty ? versions.first : null);
                  }

                  if (active == null) {
                    return right(TrackSummary(trackId: t.id));
                  }

                  return right(
                    TrackSummary(
                      trackId: t.id,
                      activeVersionId: active.id,
                      status: active.status,
                      fileRemoteUrl: active.fileRemoteUrl,
                      durationMs: active.durationMs,
                    ),
                  );
                }),
              )
              .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())));
        });

        // Combine all per-track streams into one snapshot list, maintain order of tracks
        return Rx.combineLatestList<Either<Failure, TrackSummary>>(perTrack$)
            .map<Either<Failure, PlaylistTracksBundle>>((list) {
              Failure? firstFailure;
              for (final e in list) {
                e.fold((f) => firstFailure ??= f, (_) {});
              }
              if (firstFailure != null) {
                return left(firstFailure!);
              }
              final ordered = List<TrackSummary>.generate(
                tracks.length,
                (i) => list[i].getOrElse(
                  () => TrackSummary(trackId: tracks[i].id),
                ),
              );
              return right(
                PlaylistTracksBundle(tracks: tracks, summaries: ordered),
              );
            })
            .onErrorReturnWith(
              (e, _) =>
                  left(ServerFailure('Failed to build playlist summaries: $e')),
            );
      });
    });
  }
}

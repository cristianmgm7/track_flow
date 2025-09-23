import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart';
import 'package:trackflow/features/playlist/domain/entities/track_summary.dart';
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart';
import 'package:trackflow/features/playlist/presentation/cubit/playlist_state.dart';
import 'package:trackflow/features/playlist/presentation/models/track_row_view_model.dart';

@injectable
class PlaylistCubit extends Cubit<PlaylistState> {
  final WatchTracksByProjectIdUseCase _watchTracks;
  final WatchProjectPlaylistUseCase _watchSummaries;

  StreamSubscription<Either<Failure, List<AudioTrack>>>? _tracksSub;
  StreamSubscription<Either<Failure, List<TrackSummary>>>? _summarySub;

  PlaylistCubit(this._watchTracks, this._watchSummaries)
    : super(PlaylistState.initial());

  Future<void> watch(ProjectId projectId) async {
    // Cancel existing
    await _tracksSub?.cancel();
    await _summarySub?.cancel();

    emit(PlaylistState.initial());

    // Watch tracks
    _tracksSub = _watchTracks(
      WatchTracksByProjectIdParams(projectId: projectId),
    ).listen((either) {
      either.fold(
        (f) => emit(
          state.copyWith(isLoading: false, error: f.message, tracks: []),
        ),
        (tracks) {
          // Keep tracks for player
          emit(state.copyWith(isLoading: false, error: null, tracks: tracks));
        },
      );
    });

    // Watch summaries (active versions, cache URL, duration)
    _summarySub = _watchSummaries(projectId).listen((either) {
      either.fold(
        (f) => emit(state.copyWith(isLoading: false, error: f.message)),
        (summaries) {
          final vmByTrackId = <String, TrackRowViewModel>{};
          for (final track in state.tracks) {
            final s = summaries.firstWhere(
              (ts) => ts.trackId == track.id,
              orElse: () => TrackSummary(trackId: track.id),
            );

            final displayedDuration =
                (track.duration.inMilliseconds == 0 && s.durationMs != null)
                    ? Duration(milliseconds: s.durationMs!)
                    : track.duration;

            vmByTrackId[track.id.value] = TrackRowViewModel(
              track: track,
              displayedDuration: displayedDuration,
              cacheableRemoteUrl: s.fileRemoteUrl,
              activeVersionId: s.activeVersionId?.value,
              status: s.status,
            );
          }

          final items =
              state.tracks
                  .map(
                    (t) =>
                        vmByTrackId[t.id.value] ??
                        TrackRowViewModel(
                          track: t,
                          displayedDuration: t.duration,
                        ),
                  )
                  .toList();

          emit(state.copyWith(isLoading: false, error: null, items: items));
        },
      );
    });
  }

  @override
  Future<void> close() async {
    await _tracksSub?.cancel();
    await _summarySub?.cancel();
    return super.close();
  }
}

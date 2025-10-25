import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist_tracks_bundle.dart';
import 'package:trackflow/features/playlist/domain/entities/track_summary.dart';
import 'package:trackflow/features/playlist/domain/usecases/watch_project_playlist_usecase.dart';
import 'package:trackflow/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:trackflow/features/playlist/presentation/bloc/playlist_state.dart';
import 'package:trackflow/features/playlist/presentation/models/track_row_view_model.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';

@injectable
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final WatchProjectPlaylistUseCase _watchPlaylist;

  PlaylistBloc(this._watchPlaylist) : super(PlaylistState.initial()) {
    on<WatchPlaylist>(_onWatchPlaylist);
  }

  Future<void> _onWatchPlaylist(
    WatchPlaylist event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistState.initial());

    await emit.onEach<Either<Failure, PlaylistTracksBundle>>(
      _watchPlaylist(event.projectId),
      onData: (either) {
        either.fold(
          (f) => emit(
            state.copyWith(
              isLoading: false,
              error: f.message,
              tracks: [],
              items: [],
            ),
          ),
          (bundle) {
            final tracks = bundle.tracks;
            final summaries = bundle.summaries;

            final vmByTrackId = <String, TrackRowViewModel>{};
            for (final track in tracks) {
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
                tracks
                    .map(
                      (t) =>
                          vmByTrackId[t.id.value] ??
                          TrackRowViewModel(
                            track: t,
                            displayedDuration: t.duration,
                          ),
                    )
                    .toList();
            emit(
              state.copyWith(
                isLoading: false,
                error: null,
                tracks: tracks.map(AudioTrackUiModel.fromDomain).toList(),
                items: items,
              ),
            );
          },
        );
      },
    );
  }
}

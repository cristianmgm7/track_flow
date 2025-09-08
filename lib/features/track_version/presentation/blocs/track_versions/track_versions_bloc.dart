import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_event.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_state.dart';

@injectable
class TrackVersionsBloc extends Bloc<TrackVersionsEvent, TrackVersionsState> {
  final WatchTrackVersionsUseCase _watchVersions;
  final SetActiveTrackVersionUseCase _setActive;
  final AddTrackVersionUseCase _addVersion;

  TrackVersionsBloc(this._watchVersions, this._setActive, this._addVersion)
    : super(const TrackVersionsInitial()) {
    on<WatchTrackVersionsRequested>(_onWatchRequested);
    on<SetActiveTrackVersionRequested>(_onSetActiveRequested);
    on<AddTrackVersionRequested>(_onAddVersionRequested);
  }

  Future<void> _onWatchRequested(
    WatchTrackVersionsRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    emit(const TrackVersionsLoading());
    await emit.onEach(
      _watchVersions(event.trackId),
      onData: (either) {
        either.fold((failure) => emit(TrackVersionsError(failure.message)), (
          versions,
        ) {
          final active = versions.isEmpty ? null : versions.first.id;
          emit(
            TrackVersionsLoaded(versions: versions, activeVersionId: active),
          );
        });
      },
      onError: (e, stackTrace) {
        emit(TrackVersionsError(e.toString()));
      },
    );
  }

  Future<void> _onSetActiveRequested(
    SetActiveTrackVersionRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    final result = await _setActive(
      SetActiveTrackVersionParams(
        trackId: event.trackId,
        versionId: event.versionId,
      ),
    );
    result.fold((failure) => emit(TrackVersionsError(failure.message)), (_) {});
  }

  Future<void> _onAddVersionRequested(
    AddTrackVersionRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    final result = await _addVersion(
      AddTrackVersionParams(
        trackId: event.trackId,
        file: event.file,
        label: event.label,
        duration: event.duration,
      ),
    );
    result.fold((failure) => emit(TrackVersionsError(failure.message)), (_) {});
  }
}

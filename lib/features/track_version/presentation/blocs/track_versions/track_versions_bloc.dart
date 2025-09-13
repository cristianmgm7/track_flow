import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
// import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/watch_track_versions_bundle_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/set_active_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/add_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/rename_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_event.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_state.dart';

@injectable
class TrackVersionsBloc extends Bloc<TrackVersionsEvent, TrackVersionsState> {
  final WatchTrackVersionsBundleUseCase _watchBundle;
  final SetActiveTrackVersionUseCase _setActive;
  final AddTrackVersionUseCase _addVersion;
  final RenameTrackVersionUseCase _renameVersion;
  final DeleteTrackVersionUseCase _deleteVersion;

  TrackVersionsBloc(
    this._watchBundle,
    this._setActive,
    this._addVersion,
    this._renameVersion,
    this._deleteVersion,
  ) : super(const TrackVersionsInitial()) {
    on<WatchTrackVersionsRequested>(_onWatchRequested);
    on<SetActiveTrackVersionRequested>(_onSetActiveRequested);
    on<AddTrackVersionRequested>(_onAddVersionRequested);
    on<RenameTrackVersionRequested>(_onRenameVersionRequested);
    on<DeleteTrackVersionRequested>(_onDeleteVersionRequested);
    on<UpdateActiveVersionRequested>(_onUpdateActiveVersionRequested);
  }

  Future<void> _onWatchRequested(
    WatchTrackVersionsRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    emit(const TrackVersionsLoading());
    var isFirstEmission = true;
    await emit.onEach(
      _watchBundle.call(event.trackId),
      onData: (either) {
        either.fold((failure) => emit(TrackVersionsError(failure.message)), (
          bundle,
        ) {
          final versions = bundle.versions;
          // First emission: allow route override. Afterwards: always reflect DB (track.activeVersionId).
          final activeVersionId =
              isFirstEmission
                  ? (event.activeVersionId ??
                      bundle.track.activeVersionId ??
                      (versions.isEmpty ? null : versions.first.id))
                  : (bundle.track.activeVersionId ??
                      (versions.isEmpty ? null : versions.first.id));
          emit(
            TrackVersionsLoaded(
              versions: versions,
              activeVersionId: activeVersionId,
            ),
          );
          if (isFirstEmission) {
            isFirstEmission = false;
          }
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
    final result = await _setActive.call(
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

  Future<void> _onRenameVersionRequested(
    RenameTrackVersionRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    final result = await _renameVersion(
      RenameTrackVersionParams(
        versionId: event.versionId,
        newLabel: event.newLabel,
      ),
    );
    result.fold((failure) => emit(TrackVersionsError(failure.message)), (_) {});
  }

  Future<void> _onDeleteVersionRequested(
    DeleteTrackVersionRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    final result = await _deleteVersion(
      DeleteTrackVersionParams(versionId: event.versionId),
    );
    result.fold((failure) => emit(TrackVersionsError(failure.message)), (_) {});
  }

  Future<void> _onUpdateActiveVersionRequested(
    UpdateActiveVersionRequested event,
    Emitter<TrackVersionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is TrackVersionsLoaded) {
      emit(
        TrackVersionsLoaded(
          versions: currentState.versions,
          activeVersionId: event.activeVersionId,
        ),
      );
    }
  }
}

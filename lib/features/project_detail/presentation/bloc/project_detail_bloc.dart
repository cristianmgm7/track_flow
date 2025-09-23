import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_sort.dart'
    as sort_helper;

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final WatchProjectDetailUseCase watchProjectDetail;

  StreamSubscription<Either<Failure, ProjectDetailBundle>>? _detailSubscription;

  ProjectDetailBloc({required this.watchProjectDetail})
    : super(ProjectDetailState.initial()) {
    on<WatchProjectDetail>(_onWatchProjectDetail);
    on<ClearProjectDetail>(_onClearProjectDetail);
    on<ChangeTrackSort>(_onChangeTrackSort);
  }

  Future<void> _onWatchProjectDetail(
    WatchProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    // Cancel any existing subscription before creating a new one
    _detailSubscription?.cancel();

    emit(
      ProjectDetailState.initial().copyWith(
        isLoadingProject: true,
        isLoadingTracks: true,
        isLoadingCollaborators: true,
      ),
    );

    final currentProjectId = event.projectId.value;

    await emit.onEach<Either<Failure, ProjectDetailBundle>>(
      watchProjectDetail.call(projectId: currentProjectId),
      onData: (either) {
        either.fold(
          (failure) {
            emit(
              state.copyWith(
                isLoadingProject: false,
                isLoadingTracks: false,
                isLoadingCollaborators: false,
                projectError: failure.message,
                tracksError: failure.message,
                collaboratorsError: failure.message,
              ),
            );
          },
          (bundle) {
            final sortedTracks = [...bundle.tracks]..sort(
              (a, b) => sort_helper.compareTracksBySort(a, b, state.sort),
            );
            emit(
              state.copyWith(
                project: bundle.project,
                tracks: sortedTracks,
                collaborators: bundle.collaborators,
                isLoadingProject: false,
                isLoadingTracks: false,
                isLoadingCollaborators: false,
                projectError: null,
                tracksError: null,
                collaboratorsError: null,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onClearProjectDetail(
    ClearProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    // Emit initial state first to break any takeWhile conditions
    emit(ProjectDetailState.initial());
    _detailSubscription?.cancel();
    _detailSubscription = null;
  }

  void _onChangeTrackSort(
    ChangeTrackSort event,
    Emitter<ProjectDetailState> emit,
  ) {
    final resorted = [...state.tracks]
      ..sort((a, b) => sort_helper.compareTracksBySort(a, b, event.sort));
    emit(state.copyWith(tracks: resorted, sort: event.sort));
  }

  @override
  Future<void> close() {
    _detailSubscription?.cancel();
    return super.close();
  }
}

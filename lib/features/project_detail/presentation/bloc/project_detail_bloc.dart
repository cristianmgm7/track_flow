import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final WatchProjectDetailUseCase watchProjectDetail;

  StreamSubscription<ProjectDetailBundle>? _detailSubscription;

  ProjectDetailBloc({required this.watchProjectDetail})
    : super(ProjectDetailState.initial()) {
    on<WatchProjectDetail>(_onWatchProjectDetail);
  }

  Future<void> _onWatchProjectDetail(
    WatchProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingTracks: true,
        isLoadingCollaborators: true,
        tracksError: null,
        collaboratorsError: null,
      ),
    );

    // Cancel previous subscription if any
    await _detailSubscription?.cancel();

    // Suscríbete al stream reactivo
    _detailSubscription = watchProjectDetail(
      projectId: event.projectId.value,
      collaboratorIds: event.collaboratorIds.map((e) => e.value).toList(),
    ).listen(
      (bundle) {
        emit(
          state.copyWith(
            tracks: bundle.tracks,
            collaborators: bundle.collaborators,
            // Si tienes comentarios en el state, agrégalos aquí
            isLoadingTracks: false,
            isLoadingCollaborators: false,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            isLoadingTracks: false,
            isLoadingCollaborators: false,
            tracksError: error.toString(),
            collaboratorsError: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _detailSubscription?.cancel();
    return super.close();
  }
}

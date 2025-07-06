import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart';
import 'project_detail_event.dart';
import 'project_detail_state.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final WatchProjectDetailUseCase watchProjectDetail;

  StreamSubscription? _detailSubscription;

  ProjectDetailBloc({required this.watchProjectDetail})
    : super(ProjectDetailBundleState.initial()) {
    on<WatchProjectDetail>(_onWatchProjectDetail);
  }

  Future<void> _onWatchProjectDetail(
    WatchProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(
      ProjectDetailBundleState.initial().copyWith(
        project: event.project,
        isLoadingTracks: true,
        isLoadingCollaborators: true,
      ),
    );

    await _detailSubscription?.cancel();
    _detailSubscription = watchProjectDetail
        .call(
          projectId: event.project.id.value,
          collaboratorIds:
              event.project.collaborators.map((e) => e.userId.value).toList(),
        )
        .listen((either) {
          either.fold(
            (failure) {
              emit(
                ProjectDetailBundleState.initial().copyWith(
                  project: event.project,
                  isLoadingTracks: false,
                  isLoadingCollaborators: false,
                  tracksError: failure.toString(),
                  collaboratorsError: failure.toString(),
                ),
              );
            },
            (bundle) {
              emit(
                ProjectDetailBundleState.initial().copyWith(
                  project: event.project,
                  tracks: bundle.tracks,
                  collaborators: bundle.collaborators,
                  isLoadingTracks: false,
                  isLoadingCollaborators: false,
                ),
              );
            },
          );
        });
  }

  @override
  Future<void> close() {
    _detailSubscription?.cancel();
    return super.close();
  }
}

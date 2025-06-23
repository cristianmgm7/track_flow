import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final WatchProjectDetailUseCase watchProjectDetail;

  StreamSubscription<Either<Failure, ProjectDetailBundle>>? _detailSubscription;

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

    await emit.onEach<Either<Failure, ProjectDetailBundle>>(
      watchProjectDetail.call(
        projectId: event.project.id.value,
        collaboratorIds:
            event.project.collaborators.map((e) => e.userId.value).toList(),
      ),
      onData: (either) {
        either.fold(
          (failure) {
            emit(
              state.copyWith(
                isLoadingTracks: false,
                isLoadingCollaborators: false,
                tracksError: failure.message,
                collaboratorsError: failure.message,
              ),
            );
          },
          (bundle) {
            emit(
              state.copyWith(
                project: event.project,
                tracks: bundle.tracks,
                collaborators: bundle.collaborators,
                isLoadingTracks: false,
                isLoadingCollaborators: false,
              ),
            );
          },
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

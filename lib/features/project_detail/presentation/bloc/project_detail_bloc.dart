import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/domain/usecases/watch_project_detail_usecase.dart';
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
    on<ClearProjectDetail>(_onClearProjectDetail);
  }

  Future<void> _onWatchProjectDetail(
    WatchProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(
      ProjectDetailState.initial().copyWith(
        project: event.project,
        isLoadingTracks: true,
        isLoadingCollaborators: true,
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

  Future<void> _onClearProjectDetail(
    ClearProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    _detailSubscription?.cancel();
    emit(ProjectDetailState.initial());
  }

  @override
  Future<void> close() {
    _detailSubscription?.cancel();
    return super.close();
  }
}

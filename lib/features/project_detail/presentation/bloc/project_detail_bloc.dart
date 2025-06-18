import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_audio_tracks_usecase.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/models/manage_colaborators_params.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/project_detail/domain/usecases/get_project_by_id_usecase.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final GetProjectByIdUseCase getProjectById;
  final WatchTracksByProjectIdUseCase watchTracksByProjectId;
  final LoadUserProfileCollaboratorsUseCase loadUserProfileCollaborators;

  StreamSubscription<Either<Failure, List<AudioTrack>>>? tracksSubscription;

  ProjectDetailBloc({
    required this.getProjectById,
    required this.watchTracksByProjectId,
    required this.loadUserProfileCollaborators,
  }) : super(ProjectDetailState.initial()) {
    on<LoadProjectDetail>(onLoadProjectDetail);
    on<TracksUpdated>(onTracksUpdated);
  }

  Future<void> onLoadProjectDetail(
    LoadProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    // Start loading all three sections
    emit(
      state.copyWith(
        isLoadingProject: true,
        isLoadingTracks: true,
        isLoadingCollaborators: true,
        projectError: null,
        tracksError: null,
        collaboratorsError: null,
      ),
    );

    // Load Project
    final projectResult = await getProjectById(
      ProjectId.fromUniqueString(event.projectId),
    );
    projectResult.fold(
      (failure) => emit(
        state.copyWith(isLoadingProject: false, projectError: failure.message),
      ),
      (project) =>
          emit(state.copyWith(project: project, isLoadingProject: false)),
    );

    // Load Collaborators
    final collaboratorsResult = await loadUserProfileCollaborators.call(
      ProjectWithCollaborators(
        project: projectResult.fold(
          (failure) => throw failure,
          (project) => project,
        ),
      ),
    );
    collaboratorsResult.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingCollaborators: false,
          collaboratorsError: failure.message,
        ),
      ),
      (collaborators) => emit(
        state.copyWith(
          collaborators: collaborators,
          isLoadingCollaborators: false,
        ),
      ),
    );

    // Subscribe to Tracks Stream
    await tracksSubscription?.cancel();
    tracksSubscription = watchTracksByProjectId
        .call(
          WatchTracksByProjectIdParams(
            projectId: ProjectId.fromUniqueString(event.projectId),
          ),
        )
        .listen(
          (tracks) => add(
            TracksUpdated(
              tracks.fold((failure) => throw failure, (tracks) => tracks),
            ),
          ),
          onError: (error) {
            emit(
              state.copyWith(
                isLoadingTracks: false,
                tracksError: error.toString(),
              ),
            );
          },
        );
  }

  void onTracksUpdated(TracksUpdated event, Emitter<ProjectDetailState> emit) {
    emit(
      state.copyWith(
        tracks: event.tracks,
        isLoadingTracks: false,
        tracksError: null,
      ),
    );
  }

  @override
  Future<void> close() {
    tracksSubscription?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/watch_project_detail_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

@injectable
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;
  final WatchAllProjectsUseCase watchAllProjects;
  final GetProjectByIdUseCase getProjectById;
  final WatchProjectDetailUseCase watchProjectDetail;

  StreamSubscription<Either<Failure, List<Project>>>? _projectsSubscription;
  StreamSubscription<Either<Failure, ProjectDetailBundle>>? _detailSubscription;

  //constructor
  ProjectsBloc({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
    required this.watchAllProjects,
    required this.getProjectById,
    required this.watchProjectDetail,
  }) : super(ProjectsInitial()) {
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<StartWatchingProjects>(_onStartWatchingProjects);
    on<GetProjectByIdRequested>(_onGetProjectByIdRequested);
    on<WatchProjectDetail>(_onWatchProjectDetail);
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await createProject.call(event.params);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectCreatedSuccess(project)),
    );
  }

  Future<void> _onUpdateProjectRequested(
    UpdateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await updateProject(event.project);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project updated successfully')),
    );
  }

  Future<void> _onDeleteProjectRequested(
    DeleteProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await deleteProject.call(event.project);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project deleted successfully')),
    );
  }

  //Watching Projects stream
  Future<void> _onStartWatchingProjects(
    StartWatchingProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    await emit.onEach<Either<Failure, List<Project>>>(
      watchAllProjects(),
      onData: (eitherProjects) {
        eitherProjects.fold(
          (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
          (projects) => emit(ProjectsLoaded(projects)),
        );
      },
      onError:
          (error, stackTrace) => emit(
            ProjectsError(
              _mapFailureToMessage(ServerFailure(error.toString())),
            ),
          ),
    );
  }

  Future<void> _onGetProjectByIdRequested(
    GetProjectByIdRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await getProjectById.call(ProjectId.fromUniqueString(event.projectId));
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectDetailsLoaded(project)),
    );
  }

  Future<void> _onWatchProjectDetail(
    WatchProjectDetail event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectDetailState.initial().copyWith(
      project: event.project,
      isLoadingTracks: true,
      isLoadingCollaborators: true,
    ));

    await emit.onEach<Either<Failure, ProjectDetailBundle>>(
      watchProjectDetail.call(
        projectId: event.project.id.value,
        collaboratorIds: event.project.collaborators.map((e) => e.userId.value).toList(),
      ),
      onData: (either) {
        either.fold(
          (failure) {
            emit(ProjectDetailState.initial().copyWith(
              project: event.project,
              isLoadingTracks: false,
              isLoadingCollaborators: false,
              tracksError: _mapFailureToMessage(failure),
              collaboratorsError: _mapFailureToMessage(failure),
            ));
          },
          (bundle) {
            emit(ProjectDetailState.initial().copyWith(
              project: event.project,
              tracks: bundle.tracks,
              collaborators: bundle.collaborators,
              isLoadingTracks: false,
              isLoadingCollaborators: false,
            ));
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    _detailSubscription?.cancel();
    return super.close();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is PermissionFailure) {
      return "You don't have permission to perform this action.";
    } else if (failure is DatabaseFailure) {
      return "A database error occurred. Please try again.";
    } else if (failure is AuthenticationFailure) {
      return "Authentication error. Please log in again.";
    } else if (failure is NetworkFailure) {
      return "No internet connection. Please check your network.";
    } else if (failure is ServerFailure) {
      return "A server error occurred. Please try again later.";
    } else if (failure is UnexpectedFailure) {
      return "An unexpected error occurred. Please try again later.";
    }
    return "An unknown error occurred.";
  }
}

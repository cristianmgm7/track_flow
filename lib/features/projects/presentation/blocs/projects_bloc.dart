import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_use_case.dart';
import 'projects_event.dart';
import 'projects_state.dart';

@factoryMethod
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;
  final GetProjectByIdUseCase getProjectById;
  final WatchAllProjectsUseCase watchAllProjects;

  StreamSubscription<Either<Failure, List<Project>>>? _projectsSubscription;

  //constructor
  ProjectsBloc({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
    required this.getProjectById,
    required this.watchAllProjects,
  }) : super(ProjectsInitial()) {
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);

    on<GetProjectByIdRequested>(_onGetProjectByIdRequested);

    on<StartWatchingProjects>(_onStartWatchingProjects);
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await createProject(event.params);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project created successfully')),
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
    final result = await deleteProject(event.projectId);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project deleted successfully')),
    );
  }

  Future<void> _onGetProjectByIdRequested(
    GetProjectByIdRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await getProjectById(event.projectId);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectDetailsLoaded(project)),
    );
  }

  //Watching Projects stream
  void _onStartWatchingProjects(
    StartWatchingProjects event,
    Emitter<ProjectsState> emit,
  ) {
    _projectsSubscription?.cancel();
    _projectsSubscription = watchAllProjects().listen(
      (projects) => add(ProjectsUpdated(projects)),
    );
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

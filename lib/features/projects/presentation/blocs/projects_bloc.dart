import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'projects_event.dart';
import 'projects_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectUseCases useCases;

  ProjectsBloc(this.useCases) : super(ProjectsInitial()) {
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<GetProjectByIdRequested>(_onGetProjectByIdRequested);
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await useCases.createProject(event.params);
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
    final result = await useCases.updateProject(event.project);
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
    final result = await useCases.deleteProject(event.projectId);
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
    final result = await useCases.getProjectById(
      UniqueId.fromUniqueString(event.projectId),
    );
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectDetailsLoaded(project)),
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

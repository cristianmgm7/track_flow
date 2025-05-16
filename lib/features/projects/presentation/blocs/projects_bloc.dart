import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'package:trackflow/features/projects/presentation/helpers/project_presenter.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectUseCases useCases;
  String? currentUserId;

  ProjectsBloc(this.useCases, {this.currentUserId}) : super(ProjectsInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<ProgressProjectStatus>(_onProgressProjectStatus);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final result = useCases.getUserProjects(event.userId);

    await result.fold(
      (failure) async => emit(ProjectsError(_mapFailureToMessage(failure))),
      (projectsStream) async {
        try {
          await emit.forEach<List<Project>>(
            projectsStream,
            onData: (projects) => ProjectsLoaded(projects),
            onError:
                (error, _) => ProjectsError(
                  'Failed to load projects: ${error.toString()}',
                ),
          );
        } catch (e) {
          emit(ProjectsError('An unexpected error occurred: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final result = await useCases.createProject(event.project);

    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) =>
          emit(const ProjectOperationSuccess('Project created successfully')),
    );
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final result = await useCases.updateProject(event.project);

    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) =>
          emit(const ProjectOperationSuccess('Project updated successfully')),
    );
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final userId = currentUserId;
    if (userId == null) {
      emit(ProjectsError('User not authenticated'));
      return;
    }

    final result = await useCases.deleteProject(
      projectId: event.projectId,
      userId: userId,
    );

    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project deleted successfully')),
    );
  }

  Future<void> _onLoadProjectDetails(
    LoadProjectDetails event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final result = await useCases.getProjectById(event.projectId);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectDetailsLoaded(project)),
    );
  }

  Future<void> _onProgressProjectStatus(
    ProgressProjectStatus event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final progressResult = event.project.progressStatus();

    await progressResult.fold(
      (failure) async => emit(ProjectsError(failure.message)),
      (updatedProject) async {
        final result = await useCases.updateProject(updatedProject);
        result.fold(
          (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
          (project) => emit(
            ProjectOperationSuccess(
              'Project status updated to ${ProjectPresenter.getDisplayStatus(updatedProject)}',
            ),
          ),
        );
      },
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
      // Optionally log failure.message here
      return "An unexpected error occurred. Please try again later.";
    }
    return "An unknown error occurred.";
  }
}

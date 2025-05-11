import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectRepository _projectRepository;

  ProjectsBloc(this._projectRepository) : super(ProjectsInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<LoadProjectDetails>(_onLoadProjectDetails);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final result = _projectRepository.getUserProjects(event.userId);

    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
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

    final result = await _projectRepository.createProject(event.project);

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

    final result = await _projectRepository.updateProject(event.project);

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

    final result = await _projectRepository.deleteProject(event.projectId);

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

    final result = await _projectRepository.getProjectById(event.projectId);

    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectDetailsLoaded(project)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure:
        return 'Please check your internet connection.';
      case ValidationFailure:
        return failure.message;
      case AuthenticationFailure:
        return 'Authentication error. Please login again.';
      case DatabaseFailure:
        return 'Database error occurred. Please try again.';
      default:
        return 'Unexpected error occurred. Please try again later.';
    }
  }
}

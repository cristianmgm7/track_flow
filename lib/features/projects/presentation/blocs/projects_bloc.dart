import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/models/project_model.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_user_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;
  final GetUserProjectsUseCase _getUserProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;

  ProjectsBloc(
    this._createProjectUseCase,
    this._updateProjectUseCase,
    this._deleteProjectUseCase,
    this._getUserProjectsUseCase,
    this._getProjectByIdUseCase,
  ) : super(ProjectsInitial()) {
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

    final result = _getUserProjectsUseCase(event.userId);

    await result.fold(
      (failure) async => emit(ProjectsError(_mapFailureToMessage(failure))),
      (projectsStream) async {
        try {
          await emit.forEach<List<Project>>(
            projectsStream,
            onData:
                (projects) => ProjectsLoaded(
                  projects,
                  models: projects.map((p) => ProjectModel(p)).toList(),
                ),
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

    final result = await _createProjectUseCase(event.project);

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

    final result = await _updateProjectUseCase(event.project);

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

    // TODO: Replace with actual userId from auth context or state
    final userId = '';
    final result = await _deleteProjectUseCase(
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

    final result = await _getProjectByIdUseCase(event.projectId);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) =>
          emit(ProjectDetailsLoaded(project, model: ProjectModel(project))),
    );
  }

  Future<void> _onProgressProjectStatus(
    ProgressProjectStatus event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    final model = ProjectModel(event.project);
    final progressResult = model.progressStatus();

    await progressResult.fold(
      (failure) async => emit(ProjectsError(failure.message)),
      (updatedProject) async {
        final result = await _updateProjectUseCase(updatedProject);
        result.fold(
          (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
          (project) => emit(
            ProjectOperationSuccess(
              'Project status updated to ${model.getDisplayStatus()}',
            ),
          ),
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) => failure.message;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/domain/models/project.dart';
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
    try {
      emit(ProjectsLoading());
      await emit.forEach<List<Project>>(
        _projectRepository.getUserProjects(event.userId),
        onData: (projects) => ProjectsLoaded(projects),
        onError: (_, __) => const ProjectsError('Failed to load projects'),
      );
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(ProjectsLoading());
      await _projectRepository.createProject(event.project);
      emit(const ProjectOperationSuccess('Project created successfully'));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(ProjectsLoading());
      await _projectRepository.updateProject(event.project);
      emit(const ProjectOperationSuccess('Project updated successfully'));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(ProjectsLoading());
      await _projectRepository.deleteProject(event.projectId);
      emit(const ProjectOperationSuccess('Project deleted successfully'));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  Future<void> _onLoadProjectDetails(
    LoadProjectDetails event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      emit(ProjectsLoading());
      final project = await _projectRepository.getProject(event.projectId);
      if (project != null) {
        emit(ProjectDetailsLoaded(project));
      } else {
        emit(const ProjectsError('Project not found'));
      }
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }
}

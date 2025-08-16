import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/models/project_sort.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();
  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectOperationSuccess extends ProjectsState {
  final String message;

  const ProjectOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectCreatedSuccess extends ProjectsState {
  final Project project;

  const ProjectCreatedSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class ProjectsError extends ProjectsState {
  final String message;

  const ProjectsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectDetailsLoaded extends ProjectsState {
  final Project project;
  const ProjectDetailsLoaded(this.project);
  @override
  List<Object?> get props => [project];
}

class ProjectsLoaded extends ProjectsState {
  final List<Project> projects;
  final bool isSyncing;
  final double? syncProgress;
  final ProjectSort sort;

  const ProjectsLoaded({
    required this.projects,
    this.isSyncing = false,
    this.syncProgress,
    this.sort = ProjectSort.lastActivityDesc,
  });

  ProjectsLoaded copyWith({
    List<Project>? projects,
    bool? isSyncing,
    double? syncProgress,
    ProjectSort? sort,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [projects, isSyncing, syncProgress ?? 0.0, sort];
}

import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/models/project_model.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsLoaded extends ProjectsState {
  final List<Project> projects;
  final List<ProjectModel> models;

  const ProjectsLoaded(this.projects, {required this.models});

  @override
  List<Object?> get props => [projects, models];
}

class ProjectDetailsLoaded extends ProjectsState {
  final Project project;
  final ProjectModel model;

  const ProjectDetailsLoaded(this.project, {required this.model});

  @override
  List<Object?> get props => [project, model];
}

class ProjectOperationSuccess extends ProjectsState {
  final String message;

  const ProjectOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectsError extends ProjectsState {
  final String message;

  const ProjectsError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectsEvent {
  final String userId;

  const LoadProjects(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateProject extends ProjectsEvent {
  final Project project;

  const CreateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class UpdateProject extends ProjectsEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class DeleteProject extends ProjectsEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class LoadProjectDetails extends ProjectsEvent {
  final String projectId;

  const LoadProjectDetails(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

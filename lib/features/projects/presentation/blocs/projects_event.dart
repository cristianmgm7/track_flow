import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class CreateProject extends ProjectsEvent {
  final CreateProjectParams params;

  const CreateProject(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdateProject extends ProjectsEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class DeleteProject extends ProjectsEvent {
  final UniqueId projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class LoadProjects extends ProjectsEvent {
  final String userId;

  const LoadProjects(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadProjectDetails extends ProjectsEvent {
  final String projectId;

  const LoadProjectDetails(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ProgressProjectStatus extends ProjectsEvent {
  final Project project;

  const ProgressProjectStatus(this.project);

  @override
  List<Object?> get props => [project];
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}

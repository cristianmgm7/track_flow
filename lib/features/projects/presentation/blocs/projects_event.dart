import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];

  // Validate common project fields
  void validateProject(Project project) {
    if (project.title.isEmpty) {
      throw ValidationException('Project title cannot be empty');
    }
    if (project.description.isEmpty) {
      throw ValidationException('Project description cannot be empty');
    }
    if (!Project.validStatuses.contains(project.status)) {
      throw ValidationException('Invalid project status: ${project.status}');
    }
  }
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

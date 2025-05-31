import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

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
  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

/// Add Participant
class ParticipantAdded extends ProjectsState {
  final String participantId;

  const ParticipantAdded(this.participantId);

  @override
  List<Object?> get props => [participantId];
}

class JoinProjectSuccess extends ProjectsState {
  final Project project;

  const JoinProjectSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class JoinProjectFailure extends ProjectsState {
  final String error;

  const JoinProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}

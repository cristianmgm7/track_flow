import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class CreateProjectRequested extends ProjectsEvent {
  final CreateProjectParams params;
  const CreateProjectRequested(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdateProjectRequested extends ProjectsEvent {
  final Project project;
  const UpdateProjectRequested(this.project);
  @override
  List<Object?> get props => [project];
}

class DeleteProjectRequested extends ProjectsEvent {
  final Project project;
  const DeleteProjectRequested(this.project);

  @override
  List<Object?> get props => [project];
}

class GetProjectByIdRequested extends ProjectsEvent {
  final String projectId;
  const GetProjectByIdRequested(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}

//Watching Projects stream
class StartWatchingProjects extends ProjectsEvent {}

class ProjectsUpdated extends ProjectsEvent {
  final Either<Failure, List<Project>> projects;
  const ProjectsUpdated(this.projects);
  @override
  List<Object?> get props => [projects];
}

class TracksUpdated extends ProjectsEvent {
  final List<AudioTrack> tracks;

  const TracksUpdated(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

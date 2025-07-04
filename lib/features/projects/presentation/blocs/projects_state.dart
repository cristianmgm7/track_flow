import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

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

// Project Detail States
class ProjectDetailState extends ProjectsState {
  final Project? project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;

  final bool isLoadingProject;
  final bool isLoadingTracks;
  final bool isLoadingCollaborators;

  final String? projectError;
  final String? tracksError;
  final String? collaboratorsError;

  const ProjectDetailState({
    required this.project,
    required this.tracks,
    required this.collaborators,
    required this.isLoadingProject,
    required this.isLoadingTracks,
    required this.isLoadingCollaborators,
    required this.projectError,
    required this.tracksError,
    required this.collaboratorsError,
  });

  factory ProjectDetailState.initial() => const ProjectDetailState(
    project: null,
    tracks: [],
    collaborators: [],
    isLoadingProject: false,
    isLoadingTracks: false,
    isLoadingCollaborators: false,
    projectError: null,
    tracksError: null,
    collaboratorsError: null,
  );

  ProjectDetailState copyWith({
    Project? project,
    List<AudioTrack>? tracks,
    List<UserProfile>? collaborators,
    bool? isLoadingProject,
    bool? isLoadingTracks,
    bool? isLoadingCollaborators,
    String? projectError,
    String? tracksError,
    String? collaboratorsError,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      tracks: tracks ?? this.tracks,
      collaborators: collaborators ?? this.collaborators,
      isLoadingProject: isLoadingProject ?? this.isLoadingProject,
      isLoadingTracks: isLoadingTracks ?? this.isLoadingTracks,
      isLoadingCollaborators:
          isLoadingCollaborators ?? this.isLoadingCollaborators,
      projectError: projectError,
      tracksError: tracksError,
      collaboratorsError: collaboratorsError,
    );
  }

  @override
  List<Object?> get props => [
    project,
    tracks,
    collaborators,
    isLoadingProject,
    isLoadingTracks,
    isLoadingCollaborators,
    projectError,
    tracksError,
    collaboratorsError,
  ];
}

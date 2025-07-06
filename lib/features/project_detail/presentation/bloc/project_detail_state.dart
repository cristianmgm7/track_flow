import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}

class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  final Project project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  const ProjectDetailLoaded({
    required this.project,
    required this.tracks,
    required this.collaborators,
  });
  @override
  List<Object?> get props => [project, tracks, collaborators];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectDetailBundleState extends ProjectDetailState {
  final Project? project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  final bool isLoadingProject;
  final bool isLoadingTracks;
  final bool isLoadingCollaborators;
  final String? projectError;
  final String? tracksError;
  final String? collaboratorsError;

  const ProjectDetailBundleState({
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

  factory ProjectDetailBundleState.initial() => const ProjectDetailBundleState(
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

  ProjectDetailBundleState copyWith({
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
    return ProjectDetailBundleState(
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

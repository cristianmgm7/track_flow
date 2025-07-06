import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ProjectDetailState extends Equatable {
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

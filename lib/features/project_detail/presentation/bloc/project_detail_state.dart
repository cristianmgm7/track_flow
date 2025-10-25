import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';
import 'package:trackflow/features/user_profile/presentation/models/user_profile_ui_model.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_sort.dart';

class ProjectDetailState extends Equatable {
  final ProjectUiModel? project;
  final List<AudioTrackUiModel> tracks;
  final List<UserProfileUiModel> collaborators;
  final AudioTrackSort sort;
  // Removed activeVersionsByTrackId from project detail; handled by playlist

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
    this.sort = AudioTrackSort.newest,
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
    sort: AudioTrackSort.newest,
    isLoadingProject: false,
    isLoadingTracks: false,
    isLoadingCollaborators: false,
    projectError: null,
    tracksError: null,
    collaboratorsError: null,
  );

  ProjectDetailState copyWith({
    ProjectUiModel? project,
    List<AudioTrackUiModel>? tracks,
    List<UserProfileUiModel>? collaborators,
    AudioTrackSort? sort,
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
      sort: sort ?? this.sort,
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
    // REMOVED manual expansion - UI models handle equality properly
    project,
    tracks,
    collaborators,
    sort,
    isLoadingProject,
    isLoadingTracks,
    isLoadingCollaborators,
    projectError,
    tracksError,
    collaboratorsError,
  ];
}

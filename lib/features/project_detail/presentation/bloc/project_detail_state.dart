import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_sort.dart';
import 'package:trackflow/features/project_detail/domain/entities/active_version_summary.dart';

class ProjectDetailState extends Equatable {
  final Project? project;
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  final AudioTrackSort sort;
  final Map<String, ActiveVersionSummary> activeVersionsByTrackId;

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
    this.activeVersionsByTrackId = const {},
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
    activeVersionsByTrackId: {},
    sort: AudioTrackSort.newest,
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
    Map<String, ActiveVersionSummary>? activeVersionsByTrackId,
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
      activeVersionsByTrackId:
          activeVersionsByTrackId ?? this.activeVersionsByTrackId,
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
    project,
    tracks,
    collaborators,
    activeVersionsByTrackId,
    sort,
    isLoadingProject,
    isLoadingTracks,
    isLoadingCollaborators,
    projectError,
    tracksError,
    collaboratorsError,
  ];
}

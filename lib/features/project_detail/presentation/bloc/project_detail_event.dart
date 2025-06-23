import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

class WatchProjectDetail extends ProjectDetailEvent {
  final ProjectId projectId;
  final List<UserId> collaboratorIds;

  const WatchProjectDetail({
    required this.projectId,
    required this.collaboratorIds,
  });

  @override
  List<Object?> get props => [projectId, collaboratorIds];
}

class TracksUpdated extends ProjectDetailEvent {
  final List<AudioTrack> tracks;

  const TracksUpdated(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

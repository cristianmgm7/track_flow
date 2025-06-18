import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectDetail extends ProjectDetailEvent {
  final String projectId;

  const LoadProjectDetail(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class TracksUpdated extends ProjectDetailEvent {
  final List<AudioTrack> tracks;

  const TracksUpdated(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

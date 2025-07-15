import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

class WatchProjectDetail extends ProjectDetailEvent {
  final Project project;

  const WatchProjectDetail({required this.project});

  @override
  List<Object?> get props => [project];
}

class TracksUpdated extends ProjectDetailEvent {
  final List<AudioTrack> tracks;

  const TracksUpdated(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

class ClearProjectDetail extends ProjectDetailEvent {
  const ClearProjectDetail();
}

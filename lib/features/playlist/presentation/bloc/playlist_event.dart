import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class WatchPlaylist extends PlaylistEvent {
  final ProjectId projectId;
  const WatchPlaylist(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

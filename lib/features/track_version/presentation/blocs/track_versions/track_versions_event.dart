import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class TrackVersionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WatchTrackVersionsRequested extends TrackVersionsEvent {
  final AudioTrackId trackId;
  WatchTrackVersionsRequested(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class AddTrackVersionRequested extends TrackVersionsEvent {
  final AudioTrackId trackId;
  final String? label;
  AddTrackVersionRequested(this.trackId, {this.label});

  @override
  List<Object?> get props => [trackId, label];
}

class SetActiveTrackVersionRequested extends TrackVersionsEvent {
  final AudioTrackId trackId;
  final TrackVersionId versionId;
  SetActiveTrackVersionRequested(this.trackId, this.versionId);

  @override
  List<Object?> get props => [trackId, versionId];
}

import 'package:equatable/equatable.dart';
import 'dart:io';
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
  final File file;
  final String? label;
  final Duration? duration;

  AddTrackVersionRequested({
    required this.trackId,
    required this.file,
    this.label,
    this.duration,
  });

  @override
  List<Object?> get props => [trackId, file, label, duration];
}

class SetActiveTrackVersionRequested extends TrackVersionsEvent {
  final AudioTrackId trackId;
  final TrackVersionId versionId;
  SetActiveTrackVersionRequested(this.trackId, this.versionId);

  @override
  List<Object?> get props => [trackId, versionId];
}

class RenameTrackVersionRequested extends TrackVersionsEvent {
  final TrackVersionId versionId;
  final String? newLabel;

  RenameTrackVersionRequested({
    required this.versionId,
    required this.newLabel,
  });

  @override
  List<Object?> get props => [versionId, newLabel];
}

class DeleteTrackVersionRequested extends TrackVersionsEvent {
  final TrackVersionId versionId;

  DeleteTrackVersionRequested(this.versionId);

  @override
  List<Object?> get props => [versionId];
}

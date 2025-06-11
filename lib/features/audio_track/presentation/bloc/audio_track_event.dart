import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class AudioTrackEvent extends Equatable {
  const AudioTrackEvent();

  @override
  List<Object> get props => [];
}

class WatchAudioTracksByProjectEvent extends AudioTrackEvent {
  final ProjectId projectId;

  const WatchAudioTracksByProjectEvent({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class UploadAudioTrackEvent extends AudioTrackEvent {
  final File file;
  final String name;
  final Duration duration;
  final ProjectId projectId;

  const UploadAudioTrackEvent({
    required this.file,
    required this.name,
    required this.duration,
    required this.projectId,
  });

  @override
  List<Object> get props => [file, name, duration, projectId];
}

class DeleteAudioTrackEvent extends AudioTrackEvent {
  final AudioTrackId trackId;
  final ProjectId projectId;

  const DeleteAudioTrackEvent({required this.trackId, required this.projectId});

  @override
  List<Object> get props => [trackId, projectId];
}

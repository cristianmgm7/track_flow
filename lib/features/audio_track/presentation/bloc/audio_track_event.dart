import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

abstract class AudioTrackEvent extends Equatable {
  const AudioTrackEvent();

  @override
  List<Object> get props => [];
}

class WatchAudioTracksByProjectEvent extends AudioTrackEvent {
  final String projectId;

  const WatchAudioTracksByProjectEvent({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class UploadAudioTrackEvent extends AudioTrackEvent {
  final File file;
  final String name;
  final Duration duration;
  final List<String> projectIds;

  const UploadAudioTrackEvent({
    required this.file,
    required this.name,
    required this.duration,
    required this.projectIds,
  });

  @override
  List<Object> get props => [file, name, duration, projectIds];
}

class DeleteAudioTrackEvent extends AudioTrackEvent {
  final AudioTrackId trackId;

  const DeleteAudioTrackEvent({required this.trackId});

  @override
  List<Object> get props => [trackId];
}

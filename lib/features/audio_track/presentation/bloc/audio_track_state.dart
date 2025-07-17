import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class AudioTrackState extends Equatable {
  const AudioTrackState();

  @override
  List<Object> get props => [];
}

class AudioTrackInitial extends AudioTrackState {}

class AudioTrackLoading extends AudioTrackState {}

class AudioTrackUploadLoading extends AudioTrackState {}

class AudioTrackEditLoading extends AudioTrackState {}

class AudioTrackDeleteLoading extends AudioTrackState {}

class AudioTrackLoaded extends AudioTrackState {
  final List<AudioTrack> tracks;

  const AudioTrackLoaded({required this.tracks});

  @override
  List<Object> get props => [tracks];
}

class AudioTrackError extends AudioTrackState {
  final String message;

  const AudioTrackError({required this.message});

  @override
  List<Object> get props => [message];
}

class AudioTrackUploadSuccess extends AudioTrackState {}

class AudioTrackDeleteSuccess extends AudioTrackState {}

class AudioTrackEditSuccess extends AudioTrackState {}

class AudioTrackEditError extends AudioTrackState {
  final String message;
  const AudioTrackEditError({required this.message});
  @override
  List<Object> get props => [message];
}

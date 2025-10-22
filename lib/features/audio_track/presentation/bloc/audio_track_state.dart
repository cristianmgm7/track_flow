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
  final bool isSyncing;
  final double? syncProgress;

  const AudioTrackLoaded({
    required this.tracks,
    this.isSyncing = false,
    this.syncProgress,
  });

  AudioTrackLoaded copyWith({
    List<AudioTrack>? tracks,
    bool? isSyncing,
    double? syncProgress,
  }) {
    return AudioTrackLoaded(
      tracks: tracks ?? this.tracks,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }

  @override
  List<Object> get props => [tracks, isSyncing, syncProgress ?? 0.0];
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

class AudioTrackCoverArtUploaded extends AudioTrackState {
  final String downloadUrl;

  const AudioTrackCoverArtUploaded(this.downloadUrl);

  @override
  List<Object> get props => [downloadUrl];
}

class AudioTrackEditError extends AudioTrackState {
  final String message;
  const AudioTrackEditError({required this.message});
  @override
  List<Object> get props => [message];
}

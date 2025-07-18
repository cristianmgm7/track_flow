part of 'audio_waveform_bloc.dart';

abstract class AudioWaveformEvent extends Equatable {
  const AudioWaveformEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger loading the waveform for a specific track.
class LoadWaveform extends AudioWaveformEvent {
  final AudioTrackId trackId;
  final int? noOfSamples;
  const LoadWaveform(this.trackId, {this.noOfSamples});

  @override
  List<Object> get props => [trackId, noOfSamples ?? 0];
}

/// Internal event to update the waveform based on the main player's session.
class _PlayerSessionUpdated extends AudioWaveformEvent {
  final PlaybackSession session;
  const _PlayerSessionUpdated(this.session);

  @override
  List<Object> get props => [session];
}

/// Internal event when the track path is successfully fetched from cache.
class _TrackPathLoaded extends AudioWaveformEvent {
  final String path;
  final int? noOfSamples;
  const _TrackPathLoaded(this.path, {this.noOfSamples});

  @override
  List<Object> get props => [path, noOfSamples ?? 0];
}

/// Internal event when track caching fails.
class _TrackCacheFailed extends AudioWaveformEvent {
  final String error;
  const _TrackCacheFailed(this.error);

  @override
  List<Object> get props => [error];
}

/// Event when the user seeks on the waveform.
class WaveformSeeked extends AudioWaveformEvent {
  final Duration position;
  const WaveformSeeked(this.position);

  @override
  List<Object> get props => [position];
}

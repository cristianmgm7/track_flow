part of 'waveform_bloc.dart';

abstract class WaveformEvent extends Equatable {
  const WaveformEvent();

  @override
  List<Object?> get props => [];
}

class LoadWaveform extends WaveformEvent {
  final AudioTrackId trackId;

  const LoadWaveform(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class WaveformSeekRequested extends WaveformEvent {
  final Duration position;

  const WaveformSeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

class _WaveformDataReceived extends WaveformEvent {
  final AudioWaveform? waveform;
  final String? error;

  const _WaveformDataReceived(this.waveform, [this.error]);

  @override
  List<Object?> get props => [waveform, error];
}

class _PlaybackPositionUpdated extends WaveformEvent {
  final Duration position;

  const _PlaybackPositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}
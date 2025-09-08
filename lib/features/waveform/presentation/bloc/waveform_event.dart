part of 'waveform_bloc.dart';

abstract class WaveformEvent extends Equatable {
  const WaveformEvent();

  @override
  List<Object?> get props => [];
}

class LoadWaveform extends WaveformEvent {
  final TrackVersionId
  versionId; // Required: waveforms are now purely version-based
  final String? audioFilePath; // Optional: to allow generation
  final String? audioSourceHash; // Optional: remote/local key
  final int? targetSampleCount;
  final bool forceRefresh;

  const LoadWaveform(
    this.versionId, {
    this.audioFilePath,
    this.audioSourceHash,
    this.targetSampleCount,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    versionId,
    audioFilePath,
    audioSourceHash,
    targetSampleCount,
    forceRefresh,
  ];
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

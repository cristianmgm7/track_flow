part of 'waveform_bloc.dart';

abstract class WaveformEvent extends Equatable {
  const WaveformEvent();

  @override
  List<Object?> get props => [];
}

class LoadWaveform extends WaveformEvent {
  final TrackVersionId
  versionId; // Required: waveforms are now purely version-based
  final String? audioFilePath; // unused now
  final String? audioSourceHash; // unused now
  final int? targetSampleCount; // unused now
  final bool forceRefresh; // unused now

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

class WaveformScrubStarted extends WaveformEvent {
  const WaveformScrubStarted();
}

class WaveformScrubUpdated extends WaveformEvent {
  final Duration previewPosition;
  const WaveformScrubUpdated(this.previewPosition);

  @override
  List<Object?> get props => [previewPosition];
}

class WaveformScrubCancelled extends WaveformEvent {
  const WaveformScrubCancelled();
}

class WaveformScrubCommitted extends WaveformEvent {
  final Duration position;
  const WaveformScrubCommitted(this.position);

  @override
  List<Object?> get props => [position];
}

class _WaveformDataReceived extends WaveformEvent {
  final AudioWaveform? waveform;

  const _WaveformDataReceived(this.waveform);

  @override
  List<Object?> get props => [waveform];
}

class _PlaybackPositionUpdated extends WaveformEvent {
  final Duration position;

  const _PlaybackPositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

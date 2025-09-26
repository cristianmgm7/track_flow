part of 'waveform_bloc.dart';

enum WaveformStatus { initial, loading, ready, error }

class WaveformState extends Equatable {
  final WaveformStatus status;
  final TrackVersionId? versionId;
  final AudioWaveform? waveform;
  final String? errorMessage;
  final Duration currentPosition;
  final bool isScrubbing;
  final Duration? previewPosition;
  final Duration? dragStartPlaybackPosition;
  final bool? wasPlayingBeforeScrub;

  const WaveformState({
    this.status = WaveformStatus.initial,
    this.versionId,
    this.waveform,
    this.errorMessage,
    this.currentPosition = Duration.zero,
    this.isScrubbing = false,
    this.previewPosition,
    this.dragStartPlaybackPosition,
    this.wasPlayingBeforeScrub,
  });

  WaveformState copyWith({
    WaveformStatus? status,
    TrackVersionId? versionId,
    AudioWaveform? waveform,
    String? errorMessage,
    Duration? currentPosition,
    bool? isScrubbing,
    Duration? previewPosition,
    Duration? dragStartPlaybackPosition,
    bool? wasPlayingBeforeScrub,
  }) {
    return WaveformState(
      status: status ?? this.status,
      versionId: versionId ?? this.versionId,
      waveform: waveform ?? this.waveform,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPosition: currentPosition ?? this.currentPosition,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      previewPosition: previewPosition ?? this.previewPosition,
      dragStartPlaybackPosition:
          dragStartPlaybackPosition ?? this.dragStartPlaybackPosition,
      wasPlayingBeforeScrub:
          wasPlayingBeforeScrub ?? this.wasPlayingBeforeScrub,
    );
  }

  @override
  List<Object?> get props => [
    status,
    versionId,
    waveform,
    errorMessage,
    currentPosition,
    isScrubbing,
    previewPosition,
    dragStartPlaybackPosition,
    wasPlayingBeforeScrub,
  ];
}

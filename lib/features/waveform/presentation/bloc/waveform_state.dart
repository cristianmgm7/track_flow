part of 'waveform_bloc.dart';

enum WaveformStatus { initial, loading, ready, error }

class WaveformState extends Equatable {
  final WaveformStatus status;
  final TrackVersionId? versionId;
  final AudioWaveform? waveform;
  final String? errorMessage;
  final Duration currentPosition;

  const WaveformState({
    this.status = WaveformStatus.initial,
    this.versionId,
    this.waveform,
    this.errorMessage,
    this.currentPosition = Duration.zero,
  });

  WaveformState copyWith({
    WaveformStatus? status,
    TrackVersionId? versionId,
    AudioWaveform? waveform,
    String? errorMessage,
    Duration? currentPosition,
  }) {
    return WaveformState(
      status: status ?? this.status,
      versionId: versionId ?? this.versionId,
      waveform: waveform ?? this.waveform,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [
    status,
    versionId,
    waveform,
    errorMessage,
    currentPosition,
  ];
}

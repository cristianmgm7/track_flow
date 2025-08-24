part of 'waveform_bloc.dart';

enum WaveformStatus { initial, loading, ready, error }

class WaveformState extends Equatable {
  final WaveformStatus status;
  final AudioTrackId? trackId;
  final AudioWaveform? waveform;
  final String? errorMessage;
  final Duration currentPosition;

  const WaveformState({
    this.status = WaveformStatus.initial,
    this.trackId,
    this.waveform,
    this.errorMessage,
    this.currentPosition = Duration.zero,
  });

  WaveformState copyWith({
    WaveformStatus? status,
    AudioTrackId? trackId,
    AudioWaveform? waveform,
    String? errorMessage,
    Duration? currentPosition,
  }) {
    return WaveformState(
      status: status ?? this.status,
      trackId: trackId ?? this.trackId,
      waveform: waveform ?? this.waveform,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [
        status,
        trackId,
        waveform,
        errorMessage,
        currentPosition,
      ];
}
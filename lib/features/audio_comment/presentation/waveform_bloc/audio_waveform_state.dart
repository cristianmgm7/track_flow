part of 'audio_waveform_bloc.dart';

enum WaveformStatus { initial, loading, ready, error }

class AudioWaveformState extends Equatable {
  const AudioWaveformState({
    this.status = WaveformStatus.initial,
    this.playerController,
    this.errorMessage,
  });

  final WaveformStatus status;
  final PlayerController? playerController;
  final String? errorMessage;

  AudioWaveformState copyWith({
    WaveformStatus? status,
    PlayerController? playerController,
    String? errorMessage,
    bool forceNullController = false,
  }) {
    return AudioWaveformState(
      status: status ?? this.status,
      playerController: forceNullController ? null : playerController ?? this.playerController,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, playerController, errorMessage];
}

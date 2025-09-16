import 'package:equatable/equatable.dart';

class WaveformData extends Equatable {
  final List<double> amplitudes;
  final int sampleRate;
  final Duration duration;
  final int targetSampleCount;

  const WaveformData({
    required this.amplitudes,
    required this.sampleRate,
    required this.duration,
    required this.targetSampleCount,
  });

  @override
  List<Object?> get props => [amplitudes, sampleRate, duration, targetSampleCount];

  bool get isValid => amplitudes.isNotEmpty && duration.inMilliseconds > 0 && sampleRate > 0;

  List<double> get normalizedAmplitudes {
    if (amplitudes.isEmpty) return [];
    
    final maxAmplitude = amplitudes.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
    if (maxAmplitude == 0) return amplitudes;
    
    return amplitudes.map((amplitude) => amplitude / maxAmplitude).toList();
  }

  WaveformData copyWith({
    List<double>? amplitudes,
    int? sampleRate,
    Duration? duration,
    int? targetSampleCount,
  }) {
    return WaveformData(
      amplitudes: amplitudes ?? this.amplitudes,
      sampleRate: sampleRate ?? this.sampleRate,
      duration: duration ?? this.duration,
      targetSampleCount: targetSampleCount ?? this.targetSampleCount,
    );
  }
}
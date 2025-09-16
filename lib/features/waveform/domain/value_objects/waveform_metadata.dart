import 'dart:math' as math;
import 'package:equatable/equatable.dart';

class WaveformMetadata extends Equatable {
  final double maxAmplitude;
  final double rmsLevel;
  final int compressionLevel;
  final String generationMethod;

  const WaveformMetadata({
    required this.maxAmplitude,
    required this.rmsLevel,
    required this.compressionLevel,
    required this.generationMethod,
  });

  factory WaveformMetadata.create({
    required List<double> amplitudes,
    int compressionLevel = 1,
    String generationMethod = 'fft_analysis',
  }) {
    final maxAmplitude = amplitudes.isEmpty 
        ? 0.0 
        : amplitudes.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
    
    final rmsLevel = amplitudes.isEmpty
        ? 0.0
        : _calculateRMS(amplitudes);

    return WaveformMetadata(
      maxAmplitude: maxAmplitude,
      rmsLevel: rmsLevel,
      compressionLevel: compressionLevel,
      generationMethod: generationMethod,
    );
  }

  static double _calculateRMS(List<double> amplitudes) {
    if (amplitudes.isEmpty) return 0.0;
    
    final sumOfSquares = amplitudes
        .map((amp) => amp * amp)
        .reduce((a, b) => a + b);
    
    return math.sqrt(sumOfSquares / amplitudes.length);
  }

  @override
  List<Object?> get props => [maxAmplitude, rmsLevel, compressionLevel, generationMethod];

  WaveformMetadata copyWith({
    double? maxAmplitude,
    double? rmsLevel,
    int? compressionLevel,
    String? generationMethod,
  }) {
    return WaveformMetadata(
      maxAmplitude: maxAmplitude ?? this.maxAmplitude,
      rmsLevel: rmsLevel ?? this.rmsLevel,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      generationMethod: generationMethod ?? this.generationMethod,
    );
  }
}
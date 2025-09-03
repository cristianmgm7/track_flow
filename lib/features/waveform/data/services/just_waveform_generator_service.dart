import 'dart:io';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/services/waveform_generator_service.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

@Injectable(as: WaveformGeneratorService)
class JustWaveformGeneratorService implements WaveformGeneratorService {
  static const int defaultTargetSampleCount = 80;

  final Directory _cacheDir;

  JustWaveformGeneratorService({required Directory cacheDir})
    : _cacheDir = cacheDir;

  @override
  Future<Either<Failure, AudioWaveform>> generateWaveform(
    AudioTrackId trackId,
    String audioFilePath, {
    int? targetSampleCount,
  }) async {
    try {
      final inputFile = File(audioFilePath);
      if (!await inputFile.exists()) {
        return Left(ServerFailure('Audio file not found: $audioFilePath'));
      }

      final waveformsDir = Directory(p.join(_cacheDir.path, 'waveforms'));
      if (!await waveformsDir.exists()) {
        await waveformsDir.create(recursive: true);
      }

      final waveOutFile = File(
        p.join(waveformsDir.path, '${trackId.value}.wave'),
      );

      // Use a reasonable default resolution; we will resample to target if needed
      const WaveformZoom zoom = WaveformZoom.pixelsPerSecond(100);

      final progressStream = JustWaveform.extract(
        audioInFile: inputFile,
        waveOutFile: waveOutFile,
        zoom: zoom,
      );

      Waveform? waveform;
      await for (final progress in progressStream) {
        if (progress.waveform != null && progress.progress >= 1.0) {
          waveform = progress.waveform;
        }
      }

      if (waveform == null) {
        await _deleteIfExists(waveOutFile);
        return Left(ServerFailure('Failed to extract waveform'));
      }

      final rawAmplitudes = _convertWaveformToAmplitudes(waveform);

      final desiredCount = targetSampleCount ?? defaultTargetSampleCount;
      final amplitudes = _resampleAmplitudes(rawAmplitudes, desiredCount);

      final data = WaveformData(
        amplitudes: amplitudes,
        sampleRate: 44100,
        duration: waveform.duration,
        targetSampleCount: amplitudes.length,
      );

      final metadata = WaveformMetadata.create(
        amplitudes: amplitudes,
        generationMethod: 'just_waveform',
      );

      final result = AudioWaveform.create(
        trackId: trackId,
        data: data,
        metadata: metadata,
      );

      await _deleteIfExists(waveOutFile);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to generate waveform: $e'));
    }
  }

  List<double> _convertWaveformToAmplitudes(Waveform waveform) {
    final length = waveform.length;
    final amplitudes = List<double>.generate(length, (i) {
      // Use the absolute peak (envelope) so values are always non-negative
      final minVal = waveform.getPixelMin(i);
      final maxVal = waveform.getPixelMax(i);
      return math.max(minVal.abs(), maxVal.abs()).toDouble();
    }, growable: false);
    return amplitudes;
  }

  List<double> _resampleAmplitudes(List<double> source, int targetCount) {
    if (targetCount <= 0 || source.isEmpty) return source;
    if (source.length == targetCount) return List<double>.from(source);

    final result = <double>[];
    final scale = source.length / targetCount;
    for (int i = 0; i < targetCount; i++) {
      final start = (i * scale).floor();
      final double endRaw = ((i + 1) * scale);
      final int endExclusive = endRaw.ceil().clamp(start + 1, source.length);
      double maxAmplitude = 0.0;
      for (int j = start; j < endExclusive; j++) {
        final v = source[j].abs();
        if (v > maxAmplitude) maxAmplitude = v;
      }
      result.add(maxAmplitude);
    }
    return result;
  }

  Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

abstract class WaveformRemoteDataSource {
  Future<AudioWaveform?> fetchByKey({
    TrackVersionId? versionId,
    required String audioSourceHash,
    required int algorithmVersion,
    required int targetSampleCount,
  });

  Future<void> uploadByKey({
    required AudioWaveform waveform,
    required String audioSourceHash,
    required int algorithmVersion,
  });

  /// Fetch best-available waveform at canonical path
  /// waveforms/{trackId}/{versionId}/best.json
  Future<AudioWaveform?> fetchBestForVersion({
    required String trackId,
    required TrackVersionId versionId,
  });

  /// Upload best-available waveform to canonical path
  Future<void> uploadBestForVersion({
    required String trackId,
    required AudioWaveform waveform,
  });
}

@LazySingleton(as: WaveformRemoteDataSource)
class FirebaseStorageWaveformRemoteDataSource
    implements WaveformRemoteDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageWaveformRemoteDataSource(this._storage);

  String _pathFor(
    TrackVersionId versionId,
    String audioSourceHash,
    int algorithmVersion,
    int targetSampleCount,
  ) {
    // Legacy key-based cache path kept for variants and backward compatibility
    return 'waveforms/${versionId.value}/${audioSourceHash}_${targetSampleCount}_alg$algorithmVersion.json';
  }

  String _bestPathFor(String trackId, TrackVersionId versionId) {
    return 'waveforms/$trackId/${versionId.value}/best.json';
  }

  @override
  Future<AudioWaveform?> fetchByKey({
    TrackVersionId? versionId,
    required String audioSourceHash,
    required int algorithmVersion,
    required int targetSampleCount,
  }) async {
    if (versionId == null) return null;

    final ref = _storage.ref().child(
      _pathFor(versionId, audioSourceHash, algorithmVersion, targetSampleCount),
    );
    try {
      final data = await ref.getData(5 * 1024 * 1024);
      if (data == null) return null;
      final map = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return _decode(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> uploadByKey({
    required AudioWaveform waveform,
    required String audioSourceHash,
    required int algorithmVersion,
  }) async {
    final path = _pathFor(
      waveform.versionId,
      audioSourceHash,
      algorithmVersion,
      waveform.data.targetSampleCount,
    );
    await _upload(path, waveform);
  }

  @override
  Future<AudioWaveform?> fetchBestForVersion({
    required String trackId,
    required TrackVersionId versionId,
  }) async {
    try {
      final ref = _storage.ref().child(_bestPathFor(trackId, versionId));
      final data = await ref.getData(5 * 1024 * 1024);
      if (data == null) return null;
      final map = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return _decode(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> uploadBestForVersion({
    required String trackId,
    required AudioWaveform waveform,
  }) async {
    final path = _bestPathFor(trackId, waveform.versionId);
    await _upload(path, waveform);
  }

  Future<void> _upload(String path, AudioWaveform waveform) async {
    final ref = _storage.ref().child(path);
    final jsonBytes = utf8.encode(jsonEncode(_encode(waveform)));
    await ref.putData(
      Uint8List.fromList(jsonBytes),
      SettableMetadata(contentType: 'application/json'),
    );
  }

  Map<String, dynamic> _encode(AudioWaveform w) => {
    'id': w.id.value,
    'versionId': w.versionId.value,
    'amplitudes': w.data.amplitudes,
    'sampleRate': w.data.sampleRate,
    'durationMs': w.data.duration.inMilliseconds,
    'targetSampleCount': w.data.targetSampleCount,
    'maxAmplitude': w.metadata.maxAmplitude,
    'rmsLevel': w.metadata.rmsLevel,
    'compressionLevel': w.metadata.compressionLevel,
    'generationMethod': w.metadata.generationMethod,
    'generatedAt': w.generatedAt.toIso8601String(),
  };

  AudioWaveform _decode(Map<String, dynamic> m) {
    return AudioWaveform(
      id: AudioWaveformId.fromUniqueString(m['id'] as String),
      versionId: TrackVersionId.fromUniqueString(m['versionId'] as String),
      data: WaveformData(
        amplitudes:
            (m['amplitudes'] as List)
                .cast<num>()
                .map((e) => e.toDouble())
                .toList(),
        sampleRate: m['sampleRate'] as int,
        duration: Duration(milliseconds: m['durationMs'] as int),
        targetSampleCount: m['targetSampleCount'] as int,
      ),
      metadata: WaveformMetadata(
        maxAmplitude: (m['maxAmplitude'] as num).toDouble(),
        rmsLevel: (m['rmsLevel'] as num).toDouble(),
        compressionLevel: m['compressionLevel'] as int,
        generationMethod: m['generationMethod'] as String,
      ),
      generatedAt: DateTime.parse(m['generatedAt'] as String),
    );
  }
}

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/data/models/sync_metadata_document.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

part 'audio_waveform_document.g.dart';

@collection
class AudioWaveformDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  // Waveforms are now scoped purely by version
  @Index()
  late String versionId;

  // Cache key parts for correctness across devices
  @Index()
  String? audioSourceHash;
  @Index()
  int? algorithmVersion;

  late String amplitudesJson;
  late int sampleRate;
  late int durationMs;
  late int targetSampleCount;

  late double maxAmplitude;
  late double rmsLevel;
  late int compressionLevel;
  late String generationMethod;

  late DateTime generatedAt;

  SyncMetadataDocument? syncMetadata;

  AudioWaveformDocument();

  factory AudioWaveformDocument.fromEntity(AudioWaveform waveform) {
    return AudioWaveformDocument()
      ..id = waveform.id.value
      ..versionId = waveform.versionId.value
      ..audioSourceHash = null
      ..algorithmVersion = null
      ..amplitudesJson = jsonEncode(waveform.data.amplitudes)
      ..sampleRate = waveform.data.sampleRate
      ..durationMs = waveform.data.duration.inMilliseconds
      ..targetSampleCount = waveform.data.targetSampleCount
      ..maxAmplitude = waveform.metadata.maxAmplitude
      ..rmsLevel = waveform.metadata.rmsLevel
      ..compressionLevel = waveform.metadata.compressionLevel
      ..generationMethod = waveform.metadata.generationMethod
      ..generatedAt = waveform.generatedAt
      ..syncMetadata = SyncMetadataDocument.initial();
  }

  factory AudioWaveformDocument.fromEntityWithKey(
    AudioWaveform waveform, {
    required String audioSourceHash,
    required int algorithmVersion,
  }) {
    final doc = AudioWaveformDocument.fromEntity(waveform);
    doc.audioSourceHash = audioSourceHash;
    doc.algorithmVersion = algorithmVersion;
    return doc;
  }

  AudioWaveform toEntity() {
    final amplitudes = (jsonDecode(amplitudesJson) as List).cast<double>();

    return AudioWaveform(
      id: AudioWaveformId.fromUniqueString(id),
      versionId: TrackVersionId.fromUniqueString(versionId),
      data: WaveformData(
        amplitudes: amplitudes,
        sampleRate: sampleRate,
        duration: Duration(milliseconds: durationMs),
        targetSampleCount: targetSampleCount,
      ),
      metadata: WaveformMetadata(
        maxAmplitude: maxAmplitude,
        rmsLevel: rmsLevel,
        compressionLevel: compressionLevel,
        generationMethod: generationMethod,
      ),
      generatedAt: generatedAt,
    );
  }
}

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit;
    hash *= 0x100000001b3;
  }
  return hash;
}

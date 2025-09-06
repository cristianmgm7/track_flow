import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

class AudioWaveform extends Entity<AudioWaveformId> {
  final AudioTrackId trackId;
  final TrackVersionId? versionId;
  final WaveformData data;
  final WaveformMetadata metadata;
  final DateTime generatedAt;

  const AudioWaveform({
    required AudioWaveformId id,
    required this.trackId,
    this.versionId,
    required this.data,
    required this.metadata,
    required this.generatedAt,
  }) : super(id);

  factory AudioWaveform.create({
    required AudioTrackId trackId,
    TrackVersionId? versionId,
    required WaveformData data,
    required WaveformMetadata metadata,
  }) {
    return AudioWaveform(
      id: AudioWaveformId(),
      trackId: trackId,
      versionId: versionId,
      data: data,
      metadata: metadata,
      generatedAt: DateTime.now(),
    );
  }

  AudioWaveform copyWith({
    AudioWaveformId? id,
    AudioTrackId? trackId,
    TrackVersionId? versionId,
    WaveformData? data,
    WaveformMetadata? metadata,
    DateTime? generatedAt,
  }) {
    return AudioWaveform(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      versionId: versionId ?? this.versionId,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  bool belongsToTrack(AudioTrackId trackId) {
    return this.trackId == trackId;
  }

  bool belongsToVersion(TrackVersionId versionId) {
    return this.versionId == versionId;
  }
}

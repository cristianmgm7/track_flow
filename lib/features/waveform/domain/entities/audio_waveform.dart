import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_data.dart';
import 'package:trackflow/features/waveform/domain/value_objects/waveform_metadata.dart';

class AudioWaveform extends Entity<AudioWaveformId> {
  final AudioTrackId trackId;
  final WaveformData data;
  final WaveformMetadata metadata;
  final DateTime generatedAt;

  const AudioWaveform({
    required AudioWaveformId id,
    required this.trackId,
    required this.data,
    required this.metadata,
    required this.generatedAt,
  }) : super(id);

  factory AudioWaveform.create({
    required AudioTrackId trackId,
    required WaveformData data,
    required WaveformMetadata metadata,
  }) {
    return AudioWaveform(
      id: AudioWaveformId(),
      trackId: trackId,
      data: data,
      metadata: metadata,
      generatedAt: DateTime.now(),
    );
  }

  AudioWaveform copyWith({
    AudioWaveformId? id,
    AudioTrackId? trackId,
    WaveformData? data,
    WaveformMetadata? metadata,
    DateTime? generatedAt,
  }) {
    return AudioWaveform(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  bool belongsToTrack(AudioTrackId trackId) {
    return this.trackId == trackId;
  }
}


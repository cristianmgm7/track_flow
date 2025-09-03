import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/data/models/audio_waveform_document.dart';

abstract class WaveformLocalDataSource {
  Future<AudioWaveform?> getWaveformByTrackId(AudioTrackId trackId);
  Future<AudioWaveform?> getByKey({
    required AudioTrackId trackId,
    required String audioSourceHash,
    required int algorithmVersion,
    required int targetSampleCount,
  });
  Future<void> saveWaveform(AudioWaveform waveform);
  Future<void> saveWaveformWithKey(
    AudioWaveform waveform, {
    required String audioSourceHash,
    required int algorithmVersion,
  });
  Future<void> deleteWaveformsForTrack(AudioTrackId trackId);
  Stream<AudioWaveform> watchWaveformChanges(AudioTrackId trackId);
}

@Injectable(as: WaveformLocalDataSource)
class WaveformLocalDataSourceImpl implements WaveformLocalDataSource {
  final Isar _isar;

  WaveformLocalDataSourceImpl({required Isar isar}) : _isar = isar;

  @override
  Future<AudioWaveform?> getWaveformByTrackId(AudioTrackId trackId) async {
    final document = await _isar.audioWaveformDocuments
        .filter()
        .trackIdEqualTo(trackId.value)
        .findFirst();
    
    return document?.toEntity();
  }

  @override
  Future<AudioWaveform?> getByKey({
    required AudioTrackId trackId,
    required String audioSourceHash,
    required int algorithmVersion,
    required int targetSampleCount,
  }) async {
    final document = await _isar.audioWaveformDocuments
        .filter()
        .trackIdEqualTo(trackId.value)
        .and()
        .audioSourceHashEqualTo(audioSourceHash)
        .and()
        .algorithmVersionEqualTo(algorithmVersion)
        .and()
        .targetSampleCountEqualTo(targetSampleCount)
        .findFirst();
    return document?.toEntity();
  }

  @override
  Future<void> saveWaveform(AudioWaveform waveform) async {
    final document = AudioWaveformDocument.fromEntity(waveform);
    
    await _isar.writeTxn(() async {
      await _isar.audioWaveformDocuments.put(document);
    });
  }

  @override
  Future<void> saveWaveformWithKey(
    AudioWaveform waveform, {
    required String audioSourceHash,
    required int algorithmVersion,
  }) async {
    final document = AudioWaveformDocument.fromEntityWithKey(
      waveform,
      audioSourceHash: audioSourceHash,
      algorithmVersion: algorithmVersion,
    );
    await _isar.writeTxn(() async {
      await _isar.audioWaveformDocuments.put(document);
    });
  }

  @override
  Future<void> deleteWaveformsForTrack(AudioTrackId trackId) async {
    await _isar.writeTxn(() async {
      await _isar.audioWaveformDocuments
          .filter()
          .trackIdEqualTo(trackId.value)
          .deleteAll();
    });
  }

  @override
  Stream<AudioWaveform> watchWaveformChanges(AudioTrackId trackId) {
    return _isar.audioWaveformDocuments
        .filter()
        .trackIdEqualTo(trackId.value)
        .watch(fireImmediately: true)
        .where((documents) => documents.isNotEmpty)
        .map((documents) => documents.first.toEntity());
  }
}
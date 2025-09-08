import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/data/models/audio_waveform_document.dart';

abstract class WaveformLocalDataSource {
  Future<AudioWaveform?> getWaveformByVersionId(TrackVersionId versionId);
  Future<AudioWaveform?> getByKey({
    TrackVersionId? versionId,
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
  Future<void> deleteWaveformsForVersion(TrackVersionId versionId);
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId);
  Future<void> clearAll();
}

@Injectable(as: WaveformLocalDataSource)
class WaveformLocalDataSourceImpl implements WaveformLocalDataSource {
  final Isar _isar;

  WaveformLocalDataSourceImpl({required Isar isar}) : _isar = isar;

  @override
  Future<AudioWaveform?> getWaveformByVersionId(
    TrackVersionId versionId,
  ) async {
    // Filter only by versionId since waveforms are now purely version-based
    final document =
        await _isar.audioWaveformDocuments
            .filter()
            .versionIdEqualTo(versionId.value)
            .findFirst();
    return document?.toEntity();
  }

  @override
  Future<AudioWaveform?> getByKey({
    TrackVersionId? versionId,
    required String audioSourceHash,
    required int algorithmVersion,
    required int targetSampleCount,
  }) async {
    final document =
        await _isar.audioWaveformDocuments
            .filter()
            .versionIdEqualTo(versionId?.value ?? '')
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
  Future<void> deleteWaveformsForVersion(TrackVersionId versionId) async {
    await _isar.writeTxn(() async {
      // Delete all waveforms for this specific version
      await _isar.audioWaveformDocuments
          .filter()
          .versionIdEqualTo(versionId.value)
          .deleteAll();
    });
  }

  @override
  Stream<AudioWaveform> watchWaveformChanges(TrackVersionId versionId) {
    // Watch only waveforms for this specific version
    return _isar.audioWaveformDocuments
        .filter()
        .versionIdEqualTo(versionId.value)
        .watch(fireImmediately: true)
        .where((documents) => documents.isNotEmpty)
        .map((documents) => documents.first.toEntity());
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.audioWaveformDocuments.clear();
    });
  }
}

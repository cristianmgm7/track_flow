import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackLocalDataSource {
  Future<void> cacheTrack(AudioTrackDTO track);
  Future<AudioTrackDTO?> getTrackById(String id);
  Future<void> deleteTrack(String id);
  Future<void> deleteAllTracks();
  Stream<List<AudioTrackDTO>> watchTracksByProject(String projectId);
}

@LazySingleton(as: AudioTrackLocalDataSource)
class IsarAudioTrackLocalDataSource implements AudioTrackLocalDataSource {
  final Isar _isar;

  IsarAudioTrackLocalDataSource(this._isar);

  @override
  Future<void> cacheTrack(AudioTrackDTO track) async {
    final trackDoc = AudioTrackDocument.fromDTO(track);
    await _isar.writeTxn(() async {
      await _isar.audioTrackDocuments.put(trackDoc);
    });
  }

  @override
  Future<AudioTrackDTO?> getTrackById(String id) async {
    final trackDoc = await _isar.audioTrackDocuments.get(fastHash(id));
    return trackDoc?.toDTO();
  }

  @override
  Future<void> deleteTrack(String id) async {
    await _isar.writeTxn(() async {
      await _isar.audioTrackDocuments.delete(fastHash(id));
    });
  }

  @override
  Future<void> deleteAllTracks() async {
    await _isar.writeTxn(() async {
      await _isar.audioTrackDocuments.clear();
    });
  }

  @override
  Stream<List<AudioTrackDTO>> watchTracksByProject(String projectId) {
    return _isar.audioTrackDocuments
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }
}

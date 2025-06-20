import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackLocalDataSource {
  Future<void> cacheTrack(AudioTrackDTO track);
  Future<AudioTrackDTO?> getTrackById(String id);
  Future<void> deleteTrack(String id);
  Stream<List<AudioTrackDTO>> watchTracksByProject(String projectId);
}

@LazySingleton(as: AudioTrackLocalDataSource)
class AudioTrackLocalDataSourceImpl implements AudioTrackLocalDataSource {
  final Box<Map> _cache;
  AudioTrackLocalDataSourceImpl(this._cache);

  @override
  Future<void> cacheTrack(AudioTrackDTO track) async {
    await _cache.put(track.id.value, track.toJson());
  }

  @override
  Future<AudioTrackDTO?> getTrackById(String id) async {
    final map = _cache.get(id);
    if (map != null) {
      return AudioTrackDTO.fromJson(map.cast<String, dynamic>());
    }
    return null;
  }

  @override
  Future<void> deleteTrack(String id) async {
    await _cache.delete(id);
  }

  @override
  Stream<List<AudioTrackDTO>> watchTracksByProject(String projectId) {
    return _cache.watch().map((_) {
      return _cache.values
          .map((map) => AudioTrackDTO.fromJson(map.cast<String, dynamic>()))
          .where((track) => track.projectId.value == projectId)
          .toList();
    });
  }
}

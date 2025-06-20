import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentLocalDataSource {
  Future<void> cacheComment(AudioCommentDTO comment);
  Future<void> deleteCachedComment(String commentId);
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId);
  Stream<List<AudioCommentDTO>> watchCommentsByTrack(String trackId);
}

@LazySingleton(as: AudioCommentLocalDataSource)
class HiveAudioCommentLocalDataSource implements AudioCommentLocalDataSource {
  final Box<AudioCommentDTO> _commentBox;

  HiveAudioCommentLocalDataSource(this._commentBox);

  @override
  Future<void> cacheComment(AudioCommentDTO comment) async {
    await _commentBox.put(comment.id, comment);
  }

  @override
  Future<void> deleteCachedComment(String commentId) async {
    await _commentBox.delete(commentId);
  }

  @override
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId) async {
    return _commentBox.values
        .where((comment) => comment.trackId == trackId)
        .toList();
  }

  @override
  Stream<List<AudioCommentDTO>> watchCommentsByTrack(String trackId) {
    return _commentBox.watch().map((_) {
      return _commentBox.values
          .where((comment) => comment.trackId == trackId)
          .toList();
    });
  }
}

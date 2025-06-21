import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentLocalDataSource {
  Future<void> cacheComment(AudioCommentDTO comment);
  Future<void> deleteCachedComment(String commentId);
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId);
  Stream<List<AudioCommentDTO>> watchCommentsByTrack(String trackId);
}

@LazySingleton(as: AudioCommentLocalDataSource)
class IsarAudioCommentLocalDataSource implements AudioCommentLocalDataSource {
  final Isar _isar;

  IsarAudioCommentLocalDataSource(this._isar);

  @override
  Future<void> cacheComment(AudioCommentDTO comment) async {
    final commentDoc = AudioCommentDocument.fromDTO(comment);
    await _isar.writeTxn(() async {
      await _isar.audioCommentDocuments.put(commentDoc);
    });
  }

  @override
  Future<void> deleteCachedComment(String commentId) async {
    await _isar.writeTxn(() async {
      await _isar.audioCommentDocuments.delete(fastHash(commentId));
    });
  }

  @override
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId) async {
    final commentDocs =
        await _isar.audioCommentDocuments
            .filter()
            .trackIdEqualTo(trackId)
            .findAll();
    return commentDocs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<AudioCommentDTO>> watchCommentsByTrack(String trackId) {
    return _isar.audioCommentDocuments
        .where()
        .filter()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }
}

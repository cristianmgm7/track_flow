import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentLocalDataSource {
  Future<void> cacheComment(AudioCommentDTO comment);
  Future<void> deleteCachedComment(String commentId);
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId);
  Future<AudioCommentDTO?> getCommentById(String id);
  Future<void> deleteComment(String id);
  Future<void> deleteAllComments();
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
  Future<AudioCommentDTO?> getCommentById(String id) async {
    final commentDoc =
        await _isar.audioCommentDocuments.filter().idEqualTo(id).findFirst();
    return commentDoc?.toDTO();
  }

  @override
  Future<void> deleteComment(String id) async {
    await _isar.writeTxn(() async {
      await _isar.audioCommentDocuments.delete(fastHash(id));
    });
  }

  @override
  Future<void> deleteAllComments() async {
    await _isar.writeTxn(() async {
      await _isar.audioCommentDocuments.clear();
    });
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

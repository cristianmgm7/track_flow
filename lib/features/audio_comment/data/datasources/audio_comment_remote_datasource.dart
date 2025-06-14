import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/exceptions.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentRemoteDataSource {
  Future<AudioComment> getCommentById(AudioCommentId commentId);
  Future<void> addComment(AudioComment comment);
  Stream<List<AudioComment>> watchCommentsByTrack(String trackId);
  Future<void> deleteComment(AudioCommentId commentId);
}

@LazySingleton(as: AudioCommentRemoteDataSource)
class FirebaseAudioCommentRemoteDataSource
    implements AudioCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAudioCommentRemoteDataSource(this._firestore);

  @override
  Future<AudioComment> getCommentById(AudioCommentId commentId) async {
    final snapshot =
        await _firestore
            .collection(AudioCommentDTO.collection)
            .doc(commentId.value)
            .get();
    return AudioCommentDTO.fromJson(snapshot.data()!).toDomain();
  }

  @override
  Future<void> addComment(AudioComment comment) async {
    try {
      final dto = AudioCommentDTO.fromDomain(comment);
      final data = dto.toJson();
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(dto.id)
          .set(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<AudioComment>> watchCommentsByTrack(String trackId) {
    try {
      return _firestore
          .collection(AudioCommentDTO.collection)
          .where('trackId', isEqualTo: trackId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return AudioCommentDTO.fromJson(data).toDomain();
                }).toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteComment(AudioCommentId commentId) async {
    try {
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(commentId.value)
          .delete();
    } catch (e) {
      throw ServerException();
    }
  }
}

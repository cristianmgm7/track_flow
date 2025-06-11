import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/exceptions.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentRemoteDataSource {
  Future<void> addComment(AudioComment comment);
  Stream<List<AudioComment>> watchCommentsByTrack(String trackId);
  Future<void> deleteComment(String commentId);
}

@LazySingleton(as: AudioCommentRemoteDataSource)
class FirebaseAudioCommentRemoteDataSource
    implements AudioCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAudioCommentRemoteDataSource(this._firestore);

  @override
  Future<void> addComment(AudioComment comment) async {
    try {
      await _firestore.collection('audio_comments').doc(comment.id.value).set({
        'trackId': comment.trackId.value,
        'userId': comment.userId.value,
        'content': comment.content,
        'timestamp': comment.timestamp.inMilliseconds,
        'createdAt': comment.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Stream<List<AudioComment>> watchCommentsByTrack(String trackId) {
    try {
      return _firestore
          .collection('audio_comments')
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
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('audio_comments').doc(commentId).delete();
    } catch (e) {
      throw ServerException();
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentRemoteDataSource {
  Future<Either<Failure, Unit>> addComment(AudioCommentDTO comment);
  Future<Either<Failure, Unit>> deleteComment(String commentId);
  Future<List<AudioCommentDTO>> getCommentsByVersionId(String versionId);
}

@LazySingleton(as: AudioCommentRemoteDataSource)
class FirebaseAudioCommentRemoteDataSource
    implements AudioCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAudioCommentRemoteDataSource(this._firestore);

  @override
  Future<Either<Failure, Unit>> addComment(AudioCommentDTO comment) async {
    try {
      final data = comment.toJson();
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(comment.id)
          .set(data);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to add comment'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(commentId)
          .delete();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comment'));
    }
  }

  @override
  Future<List<AudioCommentDTO>> getCommentsByVersionId(String versionId) async {
    try {
      final snapshot =
          await _firestore
              .collection(AudioCommentDTO.collection)
              .where('trackId', isEqualTo: versionId)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AudioCommentDTO.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

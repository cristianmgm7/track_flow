import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class AudioCommentRemoteDataSource {
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  );
  Future<Either<Failure, Unit>> addComment(AudioComment comment);
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  );
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);
}

@LazySingleton(as: AudioCommentRemoteDataSource)
class FirebaseAudioCommentRemoteDataSource
    implements AudioCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAudioCommentRemoteDataSource(this._firestore);

  @override
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(AudioCommentDTO.collection)
              .doc(commentId.value)
              .get();
      return Right(AudioCommentDTO.fromJson(snapshot.data()!).toDomain());
    } catch (e) {
      return Left(ServerFailure('Failed to get comment by id'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    try {
      final dto = AudioCommentDTO.fromDomain(comment);
      final data = dto.toJson();
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(dto.id)
          .set(data);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to add comment'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioComment>>> watchCommentsByTrack(
    AudioTrackId trackId,
  ) {
    try {
      return _firestore
          .collection(AudioCommentDTO.collection)
          .where('trackId', isEqualTo: trackId.value)
          .snapshots()
          .map(
            (snapshot) => Right(
              snapshot.docs.map((doc) {
                final data = doc.data();
                return AudioCommentDTO.fromJson(data).toDomain();
              }).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to watch comments by track')),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
    try {
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(commentId.value)
          .delete();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comment'));
    }
  }
}

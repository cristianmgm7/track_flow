import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

abstract class AudioCommentRemoteDataSource {
  Future<Either<Failure, Unit>> addComment(AudioComment comment);
  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);
  Future<List<AudioCommentDTO>> getCommentsByProjectIds(
    List<String> projectIds,
  );
}

@LazySingleton(as: AudioCommentRemoteDataSource)
class FirebaseAudioCommentRemoteDataSource
    implements AudioCommentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAudioCommentRemoteDataSource(this._firestore);

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

  @override
  Future<List<AudioCommentDTO>> getCommentsByProjectIds(
    List<String> projectIds,
  ) async {
    if (projectIds.isEmpty) {
      return [];
    }
    try {
      final List<Future<QuerySnapshot>> futures = [];
      for (String projectId in projectIds) {
        futures.add(
          _firestore
              .collection(ProjectDTO.collection)
              .doc(projectId)
              .collection(AudioCommentDTO.collection)
              .get(),
        );
      }

      final List<QuerySnapshot> snapshots = await Future.wait(futures);
      final List<AudioCommentDTO> allComments = [];

      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          allComments.add(AudioCommentDTO.fromJson(data));
        }
      }
      return allComments;
    } catch (e) {
      return [];
    }
  }
}

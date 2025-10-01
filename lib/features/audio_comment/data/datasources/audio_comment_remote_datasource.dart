import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentRemoteDataSource {
  Future<Either<Failure, Unit>> addComment(AudioCommentDTO comment);
  Future<Either<Failure, Unit>> deleteComment(String commentId);
  Future<List<AudioCommentDTO>> getCommentsByVersionId(String versionId);
  Future<Either<Failure, Unit>> deleteByVersionId(String versionId);
  Future<Either<Failure, List<AudioCommentDTO>>> getCommentsModifiedSince(
    DateTime since,
    List<String> versionIds,
  );
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
      data['lastModified'] = FieldValue.serverTimestamp();
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
      // Soft delete
      await _firestore
          .collection(AudioCommentDTO.collection)
          .doc(commentId)
          .update({
            'isDeleted': true,
            'lastModified': FieldValue.serverTimestamp(),
          });
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
              .where('isDeleted', isEqualTo: false)
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

  @override
  Future<Either<Failure, Unit>> deleteByVersionId(String versionId) async {
    try {
      final batch = _firestore.batch();
      final query =
          await _firestore
              .collection(AudioCommentDTO.collection)
              .where('trackId', isEqualTo: versionId)
              .get();
      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'lastModified': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete comments by versionId'));
    }
  }

  @override
  Future<Either<Failure, List<AudioCommentDTO>>> getCommentsModifiedSince(
    DateTime since,
    List<String> versionIds,
  ) async {
    try {
      if (versionIds.isEmpty) return const Right([]);
      final List<AudioCommentDTO> all = [];
      final safeSince = since.subtract(const Duration(minutes: 2));

      for (var i = 0; i < versionIds.length; i += 10) {
        final sublist = versionIds.sublist(
          i,
          i + 10 > versionIds.length ? versionIds.length : i + 10,
        );
        final snapshot =
            await _firestore
                .collection(AudioCommentDTO.collection)
                .where('trackId', whereIn: sublist)
                .where('lastModified', isGreaterThan: safeSince)
                .orderBy('lastModified')
                .get();

        final items =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AudioCommentDTO.fromJson(data);
            }).toList();
        all.addAll(items);
      }

      return Right(all);
    } catch (e) {
      return Left(ServerFailure('Failed to get modified comments'));
    }
  }
}

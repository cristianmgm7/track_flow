import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

abstract class AudioCommentLocalDataSource {
  /// Caches or updates a comment locally in Isar.
  /// Used in: SyncAudioCommentsUseCase, AudioCommentRepositoryImpl (for local persistence after remote sync or creation)
  Future<Either<Failure, Unit>> cacheComment(AudioCommentDTO comment);

  /// Deletes a cached comment by its ID from Isar.
  /// Used in: AudioCommentRepositoryImpl (for local deletion after remote deletion)
  Future<Either<Failure, Unit>> deleteCachedComment(String commentId);

  /// Returns a list of cached comments for a given track (one-time fetch).
  /// Used in: AudioCommentRepositoryImpl (for business logic or non-reactive UI)
  Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(
    String trackId,
  );

  /// Returns a single cached comment by its ID.
  /// Used in: AudioCommentRepositoryImpl, ProjectCommentService (for detail/edit flows)
  Future<Either<Failure, AudioCommentDTO?>> getCommentById(String commentId);

  /// Deletes a comment by its ID from Isar.
  /// Used in: AudioCommentRepositoryImpl (for local deletion, alternative to deleteCachedComment)
  Future<Either<Failure, Unit>> deleteComment(String commentId);

  /// Deletes all cached comments from Isar.
  /// Used in: SyncAudioCommentsUseCase (before syncing fresh data from remote)
  Future<Either<Failure, Unit>> deleteAllComments();

  /// Watches and streams all comments for a given track (reactive, for UI updates).
  /// Used in: UI (Bloc/Cubit/ViewModel) for offline-first, real-time comment updates
  Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(
    String trackId,
  );

  /// Clears all cached comments from Isar.
  /// Used in: SyncAudioCommentsUseCase (before syncing fresh data from remote)
  Future<Either<Failure, Unit>> clearCache();
}

@LazySingleton(as: AudioCommentLocalDataSource)
class IsarAudioCommentLocalDataSource implements AudioCommentLocalDataSource {
  final Isar _isar;

  IsarAudioCommentLocalDataSource(this._isar);

  @override
  Future<Either<Failure, Unit>> cacheComment(AudioCommentDTO comment) async {
    try {
      final commentDoc = AudioCommentDocument.fromDTO(comment);
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.put(commentDoc);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache comment: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCachedComment(
    String commentId,
  ) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.delete(fastHash(commentId));
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete cached comment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByTrack(
    String trackId,
  ) async {
    try {
      final commentDocs =
          await _isar.audioCommentDocuments
              .filter()
              .trackIdEqualTo(trackId)
              .findAll();
      return Right(commentDocs.map((doc) => doc.toDTO()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached comments by track: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioCommentDTO?>> getCommentById(
    String commentId,
  ) async {
    try {
      final commentDoc =
          await _isar.audioCommentDocuments.filter().idEqualTo(commentId).findFirst();
      return Right(commentDoc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get comment by id: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.delete(fastHash(commentId));
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllComments() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.clear();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete all comments: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(
    String trackId,
  ) {
    return _isar.audioCommentDocuments
        .where()
        .filter()
        .trackIdEqualTo(trackId)
        .watch(fireImmediately: true)
        .map(
          (docs) => right<Failure, List<AudioCommentDTO>>(
            docs.map((doc) => doc.toDTO()).toList(),
          ),
        )
        .handleError((e) => left(ServerFailure(e.toString())));
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.clear();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }
}

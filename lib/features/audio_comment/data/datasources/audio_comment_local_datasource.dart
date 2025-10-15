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

  /// Returns a list of cached comments for a given track version (one-time fetch).
  /// Used in: AudioCommentRepositoryImpl (for business logic or non-reactive UI)
  Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByVersion(
    String versionId,
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

  /// Watches and streams all comments for a given track version (reactive, for UI updates).
  /// Used in: UI (Bloc/Cubit/ViewModel) for offline-first, real-time comment updates
  Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByVersion(
    String versionId,
  );

  /// Watch recent comments from accessible projects, ordered by createdAt desc
  Stream<List<AudioCommentDTO>> watchRecentComments({
    required String userId,
    required int limit,
  });

  /// Clears all cached comments from Isar.
  /// Used in: SyncAudioCommentsUseCase (before syncing fresh data from remote)
  Future<Either<Failure, Unit>> clearCache();

  /// Atomically replaces all comments for a given track version with the provided list.
  ///
  /// Performs delete + batch insert inside a single transaction to ensure
  /// watchers emit at most one consolidated update, avoiding transient empty
  /// states in the UI.
  Future<Either<Failure, Unit>> replaceCommentsForVersion(
    String versionId,
    List<AudioCommentDTO> comments,
  );

  /// Delete all comments for a given version from Isar.
  Future<Either<Failure, Unit>> deleteByVersion(String versionId);
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
  Future<Either<Failure, Unit>> deleteCachedComment(String commentId) async {
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
  Future<Either<Failure, List<AudioCommentDTO>>> getCachedCommentsByVersion(
    String versionId,
  ) async {
    try {
      final commentDocs =
          await _isar.audioCommentDocuments
              .filter()
              .trackIdEqualTo(versionId)
              .findAll();
      return Right(commentDocs.map((doc) => doc.toDTO()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached comments by track: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioCommentDTO?>> getCommentById(String id) async {
    try {
      final commentDoc =
          await _isar.audioCommentDocuments.filter().idEqualTo(id).findFirst();
      return Right(commentDoc?.toDTO());
    } catch (e) {
      return Left(CacheFailure('Failed to get comment by id: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments.delete(fastHash(id));
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
  Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByVersion(
    String versionId,
  ) {
    return _isar.audioCommentDocuments
        .where()
        .filter()
        .trackIdEqualTo(versionId)
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

  @override
  Future<Either<Failure, Unit>> replaceCommentsForVersion(
    String versionId,
    List<AudioCommentDTO> comments,
  ) async {
    try {
      await _isar.writeTxn(() async {
        // Delete existing comments for the track
        await _isar.audioCommentDocuments
            .filter()
            .trackIdEqualTo(versionId)
            .deleteAll();

        if (comments.isEmpty) return;

        // Insert the new set in batch
        final docs = comments.map(AudioCommentDocument.fromDTO).toList();
        await _isar.audioCommentDocuments.putAll(docs);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to replace comments for track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByVersion(String versionId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.audioCommentDocuments
            .filter()
            .trackIdEqualTo(versionId)
            .deleteAll();
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete comments by version: $e'));
    }
  }

  @override
  Stream<List<AudioCommentDTO>> watchRecentComments({
    required String userId,
    required int limit,
  }) {
    return _isar.audioCommentDocuments
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .asyncMap((comments) async {
          // Filter comments to only those from accessible projects
          final accessibleComments = <AudioCommentDocument>[];

          for (final comment in comments) {
            // Get the project for this comment
            final project = await _isar.projectDocuments
                .filter()
                .idEqualTo(comment.projectId)
                .isDeletedEqualTo(false)
                .findFirst();

            if (project != null) {
              // Check if user has access (is owner or collaborator)
              final hasAccess = project.ownerId == userId ||
                  project.collaboratorIds.contains(userId);

              if (hasAccess) {
                accessibleComments.add(comment);

                // Early exit when we have enough comments
                if (accessibleComments.length >= limit) {
                  break;
                }
              }
            }
          }

          return accessibleComments.map((doc) => doc.toDTO()).toList();
        });
  }
}

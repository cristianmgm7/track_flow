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
  Future<void> cacheComment(AudioCommentDTO comment);

  /// Deletes a cached comment by its ID from Isar.
  /// Used in: AudioCommentRepositoryImpl (for local deletion after remote deletion)
  Future<void> deleteCachedComment(String commentId);

  /// Returns a list of cached comments for a given track (one-time fetch).
  /// Used in: AudioCommentRepositoryImpl (for business logic or non-reactive UI)
  Future<List<AudioCommentDTO>> getCachedCommentsByTrack(String trackId);

  /// Returns a single cached comment by its ID.
  /// Used in: AudioCommentRepositoryImpl, ProjectCommentService (for detail/edit flows)
  Future<AudioCommentDTO?> getCommentById(String id);

  /// Deletes a comment by its ID from Isar.
  /// Used in: AudioCommentRepositoryImpl (for local deletion, alternative to deleteCachedComment)
  Future<void> deleteComment(String id);

  /// Deletes all cached comments from Isar.
  /// Used in: SyncAudioCommentsUseCase (before syncing fresh data from remote)
  Future<void> deleteAllComments();

  /// Watches and streams all comments for a given track (reactive, for UI updates).
  /// Used in: UI (Bloc/Cubit/ViewModel) for offline-first, real-time comment updates
  Stream<Either<Failure, List<AudioCommentDTO>>> watchCommentsByTrack(
    String trackId,
  );

  /// Clears all cached comments from Isar.
  /// Used in: SyncAudioCommentsUseCase (before syncing fresh data from remote)
  Future<void> clearCache();
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
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.audioCommentDocuments.clear();
    });
  }
}

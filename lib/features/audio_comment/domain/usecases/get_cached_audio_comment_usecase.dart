import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_comment/data/services/audio_comment_storage_coordinator.dart';

/// Use case to get or download audio comment for playback
///
/// This handles the caching logic:
/// 1. Check if audio is already cached locally
/// 2. If not, download from Firebase Storage and cache it
/// 3. Return local file path for playback
@injectable
class GetCachedAudioCommentUseCase {
  final AudioCommentStorageCoordinator _storageCoordinator;

  GetCachedAudioCommentUseCase(this._storageCoordinator);

  /// Get local path for audio comment (download if necessary)
  ///
  /// [projectId] - Project containing the comment
  /// [commentId] - Audio comment ID
  /// [storageUrl] - Firebase Storage URL (needed if not cached)
  ///
  /// Returns local file path on success
  Future<Either<Failure, String>> call({
    required ProjectId projectId,
    required AudioCommentId commentId,
    required String storageUrl,
  }) async {
    // Use projectId as trackId for cache structure
    final trackId = AudioTrackId.fromUniqueString(projectId.value);
    final versionId = TrackVersionId.fromUniqueString(commentId.value);

    // Check if already cached
    final cacheCheck = await _storageCoordinator.isCommentAudioCached(
      trackId: trackId,
      versionId: versionId,
    );

    final alreadyCached = cacheCheck.fold(
      (_) => false,
      (exists) => exists,
    );

    if (alreadyCached) {
      // Return cached path
      return await _storageCoordinator.getCachedCommentAudioPath(
        trackId: trackId,
        versionId: versionId,
      ).then(
        (either) => either.fold(
          (failure) => Left(StorageFailure(failure.message)),
          (path) => Right(path),
        ),
      );
    }

    // Download and cache
    return await _storageCoordinator.downloadAndCacheCommentAudio(
      storageUrl: storageUrl,
      projectId: projectId,
      commentId: commentId,
    );
  }
}

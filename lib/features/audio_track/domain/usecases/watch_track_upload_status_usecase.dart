import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';

/// Status for the upload/sync lifecycle of a single audio track
enum TrackUploadStatus { none, pending, failed }

@lazySingleton
class WatchTrackUploadStatusUseCase {
  final PendingOperationsManager _pendingOperationsManager;

  WatchTrackUploadStatusUseCase(this._pendingOperationsManager);

  /// Watches the pending operations queue and emits status for the given track
  Stream<TrackUploadStatus> call(AudioTrackId trackId) {
    return _pendingOperationsManager.watchPendingOperations().map((operations) {
      // Find any pending op for this audio track
      final related = operations.where(
        (op) => op.entityType == 'audio_track' && op.entityId == trackId.value,
      );
      if (related.isEmpty) {
        return TrackUploadStatus.none;
      }
      // If any related op has error message and can't retry, mark failed
      final hasFailed = related.any(
        (op) =>
            (op.errorMessage != null && op.errorMessage!.isNotEmpty) &&
            !op.canRetry(),
      );
      if (hasFailed) {
        return TrackUploadStatus.failed;
      }
      return TrackUploadStatus.pending;
    }).distinct();
  }
}

import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart';

/// 🔄 Sync Track Versions (Downstream)
///
/// Clean use case that orchestrates the track versions incremental sync service.
/// - Reads the current user id from `SessionStorage`
/// - Runs the smart, timestamp-based sync for track versions
@lazySingleton
class SyncTrackVersionsUseCase {
  final TrackVersionIncrementalSyncService _versionSyncService;
  final SessionStorage _sessionStorage;

  SyncTrackVersionsUseCase(this._versionSyncService, this._sessionStorage);

  /// Execute track versions synchronization using the incremental service
  Future<void> call() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      // Preserve local cache when no user is present
      return;
    }

    try {
      await _versionSyncService.performSmartSync(userId);
    } catch (e) {
      AppLogger.warning(
        'SyncTrackVersionsUseCase: failed to sync versions: $e',
        tag: 'SYNC_VERSIONS',
      );
    }
  }
}

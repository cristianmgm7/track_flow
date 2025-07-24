import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/data/session_storage.dart';
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🎵 SIMPLE AUDIO TRACKS SYNC USE CASE
///
/// Clean use case that uses the simplified AudioTrackIncrementalSyncService
/// for pragmatic offline-first synchronization.
///
/// ✅ BENEFITS:
/// - Repositories stay clean (only CRUD)
/// - Service handles sync complexity
/// - Use case just orchestrates
/// - No circular dependencies
/// - Simple and functional
@lazySingleton
class SyncAudioTracksUsingSimpleServiceUseCase {
  final AudioTrackIncrementalSyncService _trackSyncService;
  final SessionStorage _sessionStorage;

  SyncAudioTracksUsingSimpleServiceUseCase(
    this._trackSyncService,
    this._sessionStorage,
  );

  /// 🔄 Execute audio tracks synchronization using simplified service
  Future<void> call() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      AppLogger.warning(
        'No user ID available - skipping audio tracks sync',
        tag: 'SyncAudioTracksUsingSimpleServiceUseCase',
      );
      return;
    }

    AppLogger.sync(
      'AUDIO_TRACKS',
      'Starting sync using simplified service',
      syncKey: userId,
    );
    final startTime = DateTime.now();

    try {
      // Use the simplified service - it handles everything
      final result = await _trackSyncService.performSmartSync(userId);

      result.fold(
        (failure) {
          AppLogger.error(
            'Audio tracks sync failed: ${failure.message}',
            tag: 'SyncAudioTracksUsingSimpleServiceUseCase',
            error: failure,
          );
        },
        (updateCount) {
          final duration = DateTime.now().difference(startTime);
          AppLogger.sync(
            'AUDIO_TRACKS',
            'Sync completed - updated $updateCount tracks',
            syncKey: userId,
            duration: duration.inMilliseconds,
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Audio tracks sync failed with exception: $e',
        tag: 'SyncAudioTracksUsingSimpleServiceUseCase',
        error: e,
      );
    }
  }

  /// 📊 Get sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      return {
        'error': 'No user ID available',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    return await _trackSyncService.getSyncStatistics(userId);
  }
}

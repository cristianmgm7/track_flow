import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🚀 SIMPLE PROJECTS SYNC USE CASE
///
/// Clean use case that uses the simplified ProjectIncrementalSyncService
/// for pragmatic offline-first synchronization.
///
/// ✅ BENEFITS:
/// - Repositories stay clean (only CRUD)
/// - Service handles sync complexity
/// - Use case just orchestrates
/// - No circular dependencies
/// - Simple and functional
@lazySingleton
class SyncProjectsUsingSimpleServiceUseCase {
  final ProjectIncrementalSyncService _projectSyncService;
  final SessionStorage _sessionStorage;

  SyncProjectsUsingSimpleServiceUseCase(
    this._projectSyncService,
    this._sessionStorage,
  );

  /// 🔄 Execute projects synchronization using simplified service
  Future<void> call() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      AppLogger.warning(
        'No user ID available - skipping projects sync',
        tag: 'SyncProjectsUsingSimpleServiceUseCase',
      );
      return;
    }

    AppLogger.sync(
      'PROJECTS',
      'Starting sync using simplified service',
      syncKey: userId,
    );
    final startTime = DateTime.now();

    try {
      // Use the simplified service - it handles everything
      final result = await _projectSyncService.performSmartSync(userId);

      result.fold(
        (failure) {
          AppLogger.error(
            'Projects sync failed: ${failure.message}',
            tag: 'SyncProjectsUsingSimpleServiceUseCase',
            error: failure,
          );
        },
        (updateCount) {
          final duration = DateTime.now().difference(startTime);
          AppLogger.sync(
            'PROJECTS',
            'Sync completed - updated $updateCount projects',
            syncKey: userId,
            duration: duration.inMilliseconds,
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Projects sync failed with exception: $e',
        tag: 'SyncProjectsUsingSimpleServiceUseCase',
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

    return await _projectSyncService.getSyncStatistics(userId);
  }
}

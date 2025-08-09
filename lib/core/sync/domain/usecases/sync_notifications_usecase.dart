import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🔔 NOTIFICATIONS SYNC USE CASE
///
/// Smart notification synchronization with preservation logic.
/// Uses the repository interface for clean architecture compliance.
///
/// ✅ BENEFITS:
/// - Uses repository contract (clean architecture)
/// - Preserves local data on failures
/// - Smart timing (15 min intervals like projects)
/// - Offline-first approach
@lazySingleton
class SyncNotificationsUseCase {
  final NotificationRepository _notificationRepository;
  final SessionStorage _sessionStorage;

  SyncNotificationsUseCase(this._notificationRepository, this._sessionStorage);

  /// 🔄 Execute notifications synchronization
  Future<void> call() async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      AppLogger.warning(
        'No user ID available - skipping notifications sync',
        tag: 'SyncNotificationsUseCase',
      );
      return;
    }

    AppLogger.sync(
      'NOTIFICATIONS',
      'Starting notifications sync',
      syncKey: userId,
    );
    final startTime = DateTime.now();

    try {
      // Check if sync is needed (15 min intervals like projects)
      final shouldSync = await _shouldSyncNotifications();
      if (!shouldSync) {
        AppLogger.sync(
          'NOTIFICATIONS',
          'Skipping sync - data is fresh',
          syncKey: userId,
        );
        return;
      }

      // Sync notifications from remote to local cache
      final userEntity = UserId.fromUniqueString(userId);
      
      // Call the new sync method to fetch notifications from remote
      final syncResult = await _notificationRepository.syncNotificationsFromRemote(userEntity);
      
      syncResult.fold(
        (failure) {
          AppLogger.warning(
            'Remote notification sync failed: ${failure.message}',
            tag: 'SyncNotificationsUseCase',
          );
          // Don't throw - sync failures shouldn't break the operation
          // Local data is still available
        },
        (_) {
          AppLogger.sync(
            'NOTIFICATIONS',
            'Remote notifications synced successfully to local cache',
            syncKey: userId,
          );
        },
      );

      // Mark as synced
      await _markNotificationsAsSynced();

      final duration = DateTime.now().difference(startTime);
      AppLogger.sync(
        'NOTIFICATIONS',
        'Notifications sync completed',
        syncKey: userId,
        duration: duration.inMilliseconds,
      );
    } catch (e) {
      AppLogger.error(
        'Notifications sync failed: $e',
        tag: 'SyncNotificationsUseCase',
        error: e,
      );
    }
  }

  /// 📅 Check if notifications sync is needed (15 min intervals)
  Future<bool> _shouldSyncNotifications() async {
    try {
      // Get last sync timestamp from session storage
      final lastSyncKey = 'notifications_last_sync';
      final lastSyncStr = await _sessionStorage.getString(lastSyncKey);

      if (lastSyncStr == null) {
        return true; // First time sync
      }

      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      final difference = now.difference(lastSync);

      // Sync every 15 minutes
      return difference.inMinutes >= 15;
    } catch (e) {
      AppLogger.warning('Error checking sync timing: $e');
      return true; // Sync on error to be safe
    }
  }

  /// 📝 Mark notifications as synced (update timestamp)
  Future<void> _markNotificationsAsSynced() async {
    try {
      final lastSyncKey = 'notifications_last_sync';
      await _sessionStorage.setString(
        lastSyncKey,
        DateTime.now().toIso8601String(),
      );

      AppLogger.sync('NOTIFICATIONS', 'Marked notifications as synced');
    } catch (e) {
      AppLogger.warning('Failed to mark notifications as synced: $e');
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

    try {
      final lastSyncKey = 'notifications_last_sync';
      final lastSyncStr = await _sessionStorage.getString(lastSyncKey);
      final lastSync = lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;

      final userEntity = UserId.fromUniqueString(userId);

      // Get counts using repository methods
      final totalCountResult = await _notificationRepository
          .getTotalNotificationsCount(userEntity);
      final unreadCountResult = await _notificationRepository
          .getUnreadNotificationsCount(userEntity);

      final totalCount = totalCountResult.fold((l) => 0, (r) => r);
      final unreadCount = unreadCountResult.fold((l) => 0, (r) => r);

      return {
        'entity': 'notifications',
        'strategy': 'repository_based_sync',
        'interval': '15 minutes',
        'last_sync': lastSync?.toIso8601String(),
        'total_count': totalCount,
        'unread_count': unreadCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

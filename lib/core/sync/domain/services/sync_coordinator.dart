import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart';
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart';
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart';
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart';
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart';
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart';
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart';
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart';

/// Interface for sync orchestration operations
abstract class SyncOrchestrator {
  /// Pull remote data for a specific user
  Future<void> pull(String userId, {String syncKey = 'general'});

  /// Sync specific entity type by name
  Future<void> syncEntityByType(String userId, String entityType);

  /// Get sync statistics for monitoring
  Future<Map<String, dynamic>> getSyncStatistics(String userId);

  /// Clear all sync keys from SharedPreferences
  Future<void> clearAllSyncKeys();
}

/// 🎯 CENTRAL SYNC COORDINATOR
///
/// Coordina todos los syncs usando IncrementalSyncService implementations.
/// Simple, eficiente y limpia - como Firebase pero con más control.
@LazySingleton(as: SyncOrchestrator)
class SyncCoordinator implements SyncOrchestrator {
  final SharedPreferences _prefs;

  // Keys for SharedPreferences and service registry
  static const String _projectsLastSyncKey = 'projects_last_sync';
  static const String _tracksLastSyncKey = 'tracks_last_sync';
  static const String _commentsLastSyncKey = 'comments_last_sync';
  static const String _userProfileLastSyncKey = 'user_profile_last_sync';
  static const String _collaboratorsLastSyncKey = 'collaborators_last_sync';
  static const String _notificationsLastSyncKey = 'notifications_last_sync';
  static const String _trackVersionsLastSyncKey = 'track_versions_last_sync';
  static const String _waveformsLastSyncKey = 'waveforms_last_sync';

  // Service registry keys
  static const String _projectsServiceKey = 'projects';
  static const String _tracksServiceKey = 'audio_tracks';
  static const String _commentsServiceKey = 'audio_comments';
  static const String _userProfileServiceKey = 'user_profile';
  static const String _collaboratorsServiceKey = 'collaborators';
  static const String _notificationsServiceKey = 'notifications';
  static const String _trackVersionsServiceKey = 'track_versions';
  static const String _waveformsServiceKey = 'waveforms';

  SyncCoordinator(this._prefs);

  /// 🚀 Pull remote data with specific sync key
  @override
  Future<void> pull(String userId, {String syncKey = 'general'}) async {
    AppLogger.sync(
      'COORDINATOR',
      'Starting pull sync for user: $userId, key: $syncKey',
    );

    switch (syncKey) {
      case 'appstartup':
        await _performStartupSync(userId);
        break;
      default:
        await _performFullSync(userId);
        break;
    }

    AppLogger.sync(
      'COORDINATOR',
      'Pull sync completed for user: $userId, key: $syncKey',
    );
  }

  /// 🚀 Startup sync - Only critical data for app initialization
  Future<void> _performStartupSync(String userId) async {
    AppLogger.sync('COORDINATOR', 'Starting startup sync for user: $userId');

    // Only sync the most critical data for startup
    await _syncEntityByKey(
      _userProfileServiceKey,
      _userProfileLastSyncKey,
      'user_profile',
      userId,
      isFullSync: true, // Incremental for faster startup
    );

    await _syncEntityByKey(
      _projectsServiceKey,
      _projectsLastSyncKey,
      'projects',
      userId,
      isFullSync: false, // Incremental for faster startup
    );

    await _syncEntityByKey(
      _collaboratorsServiceKey,
      _collaboratorsLastSyncKey,
      'collaborators',
      userId,
      isFullSync: false, // Incremental for faster startup
    );

    AppLogger.sync('COORDINATOR', 'Startup sync completed for user: $userId');
  }

  /// 🚀 Full sync - Sync all entities
  Future<void> _performFullSync(String userId) async {
    AppLogger.sync('COORDINATOR', 'Starting full sync for user: $userId');

    // Sync all entities
    await _syncEntityByKey(
      _projectsServiceKey,
      _projectsLastSyncKey,
      'projects',
      userId,
    );
    await _syncEntityByKey(
      _tracksServiceKey,
      _tracksLastSyncKey,
      'audio_tracks',
      userId,
    );
    await _syncEntityByKey(
      _commentsServiceKey,
      _commentsLastSyncKey,
      'audio_comments',
      userId,
    );
    await _syncEntityByKey(
      _userProfileServiceKey,
      _userProfileLastSyncKey,
      'user_profile',
      userId,
    );
    await _syncEntityByKey(
      _collaboratorsServiceKey,
      _collaboratorsLastSyncKey,
      'collaborators',
      userId,
    );
    await _syncEntityByKey(
      _notificationsServiceKey,
      _notificationsLastSyncKey,
      'notifications',
      userId,
    );
    await _syncEntityByKey(
      _trackVersionsServiceKey,
      _trackVersionsLastSyncKey,
      'track_versions',
      userId,
    );
    await _syncEntityByKey(
      _waveformsServiceKey,
      _waveformsLastSyncKey,
      'waveforms',
      userId,
    );

    AppLogger.sync('COORDINATOR', 'Full sync completed for user: $userId');
  }

  /// 🎯 Sync specific entity by type name (for BackgroundSyncCoordinator)
  @override
  Future<void> syncEntityByType(String userId, String entityType) async {
    final serviceKey = _getServiceKeyForEntity(entityType);
    if (serviceKey != null) {
      final syncKey = _getSyncKeyForEntity(entityType);
      await _syncEntityByKey(serviceKey, syncKey, entityType, userId);
    } else {
      AppLogger.warning('Unknown entity type: $entityType', tag: 'COORDINATOR');
    }
  }

  /// Get sync statistics for monitoring
  @override
  Future<Map<String, dynamic>> getSyncStatistics(String userId) async {
    // Implementation would go here to collect sync stats from all services
    return {
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'services': [
        _projectsServiceKey,
        _tracksServiceKey,
        _commentsServiceKey,
        _userProfileServiceKey,
        _collaboratorsServiceKey,
        _notificationsServiceKey,
        _trackVersionsServiceKey,
        _waveformsServiceKey,
      ],
    };
  }

  /// 🔧 Get service by key from service locator
  IncrementalSyncService<dynamic>? _getServiceByKey(String serviceKey) {
    try {
      switch (serviceKey) {
        case _projectsServiceKey:
          return sl<ProjectIncrementalSyncService>();
        case _tracksServiceKey:
          return sl<AudioTrackIncrementalSyncService>();
        case _commentsServiceKey:
          return sl<AudioCommentIncrementalSyncService>();
        case _userProfileServiceKey:
          return sl<UserProfileIncrementalSyncService>();
        case _collaboratorsServiceKey:
          return sl<UserProfileCollaboratorIncrementalSyncService>();
        case _notificationsServiceKey:
          return sl<NotificationIncrementalSyncService>();
        case _trackVersionsServiceKey:
          return sl<TrackVersionIncrementalSyncService>();
        case _waveformsServiceKey:
          return sl<WaveformIncrementalSyncService>();
        default:
          return null;
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to get service for key: $serviceKey',
        tag: 'COORDINATOR',
      );
      return null;
    }
  }

  /// 🔧 Helper method to sync entity by service key
  Future<void> _syncEntityByKey(
    String serviceKey,
    String prefsKey,
    String entityType,
    String userId, {
    bool isFullSync = false,
  }) async {
    final service = _getServiceByKey(serviceKey);
    if (service == null) {
      AppLogger.warning(
        'No service found for key: $serviceKey',
        tag: 'COORDINATOR',
      );
      return;
    }

    try {
      // If no sync key exists, force full sync
      final hasSyncKey = _prefs.containsKey(prefsKey);
      final shouldDoFullSync = isFullSync || !hasSyncKey;

      final result =
          shouldDoFullSync
              ? await service.performFullSync(userId)
              : await service.performIncrementalSync(
                _getLastSyncTime(prefsKey),
                userId,
              );

      result.fold(
        (failure) {
          AppLogger.error(
            'Sync failed for $entityType: ${failure.message}',
            tag: 'SyncCoordinator',
          );
        },
        (syncResult) async {
          AppLogger.sync(
            'COORDINATOR',
            'Sync completed for $entityType: ${syncResult.totalChanges} changes',
            syncKey: userId,
          );

          // Update last sync time
          await _prefs.setInt(
            prefsKey,
            syncResult.serverTimestamp.millisecondsSinceEpoch,
          );
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception during $entityType sync: $e',
        tag: 'SyncCoordinator',
        error: e,
      );
    }
  }

  /// 🔧 Get service key for entity type
  String? _getServiceKeyForEntity(String entityType) {
    switch (entityType) {
      case 'projects':
        return _projectsServiceKey;
      case 'audio_tracks':
        return _tracksServiceKey;
      case 'audio_comments':
        return _commentsServiceKey;
      case 'user_profile':
        return _userProfileServiceKey;
      case 'collaborators':
        return _collaboratorsServiceKey;
      case 'notifications':
        return _notificationsServiceKey;
      case 'track_versions':
        return _trackVersionsServiceKey;
      case 'waveforms':
        return _waveformsServiceKey;
      default:
        return null;
    }
  }

  /// 🔧 Get sync key for entity type
  String _getSyncKeyForEntity(String entityType) {
    switch (entityType) {
      case 'projects':
        return _projectsLastSyncKey;
      case 'audio_tracks':
        return _tracksLastSyncKey;
      case 'audio_comments':
        return _commentsLastSyncKey;
      case 'user_profile':
        return _userProfileLastSyncKey;
      case 'collaborators':
        return _collaboratorsLastSyncKey;
      case 'notifications':
        return _notificationsLastSyncKey;
      case 'track_versions':
        return _trackVersionsLastSyncKey;
      case 'waveforms':
        return _waveformsLastSyncKey;
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }
  }

  /// 📅 Get last sync time from SharedPreferences
  DateTime _getLastSyncTime(String key) {
    final timestamp = _prefs.getInt(key);
    if (timestamp == null) {
      // First sync ever - go back 30 days
      return DateTime.now().subtract(const Duration(days: 30));
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 🧹 Clear all sync keys from SharedPreferences
  ///
  /// This removes all stored sync timestamps, forcing full sync on next pull
  Future<void> clearAllSyncKeys() async {
    AppLogger.info(
      'Clearing all sync keys from SharedPreferences',
      tag: 'COORDINATOR',
    );

    // Remove all sync key entries
    await _prefs.remove(_projectsLastSyncKey);
    await _prefs.remove(_tracksLastSyncKey);
    await _prefs.remove(_commentsLastSyncKey);
    await _prefs.remove(_userProfileLastSyncKey);
    await _prefs.remove(_collaboratorsLastSyncKey);
    await _prefs.remove(_notificationsLastSyncKey);
    await _prefs.remove(_trackVersionsLastSyncKey);
    await _prefs.remove(_waveformsLastSyncKey);

    AppLogger.info('All sync keys cleared successfully', tag: 'COORDINATOR');
  }
}

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/projects/data/services/project_incremental_sync_service.dart';
import 'package:trackflow/features/audio_track/data/services/audio_track_incremental_sync_service.dart';
import 'package:trackflow/features/audio_comment/data/services/audio_comment_incremental_sync_service.dart';
import 'package:trackflow/features/user_profile/data/services/user_profile_incremental_sync_service.dart';
import 'package:trackflow/features/user_profile/data/services/user_profile_collaborator_incremental_sync_service.dart';
import 'package:trackflow/features/notifications/data/services/notification_incremental_sync_service.dart';
import 'package:trackflow/features/track_version/data/services/track_version_incremental_sync_service.dart';
import 'package:trackflow/features/waveform/data/services/waveform_incremental_sync_service.dart';

/// 🎯 CENTRAL SYNC COORDINATOR
///
/// Coordina todos los syncs usando IncrementalSyncService implementations.
/// Simple, eficiente y limpia - como Firebase pero con más control.
@lazySingleton
class SyncCoordinator {
  final SharedPreferences _prefs;
  final ProjectIncrementalSyncService _projectsService;
  final AudioTrackIncrementalSyncService _tracksService;
  final AudioCommentIncrementalSyncService _commentsService;
  final UserProfileIncrementalSyncService _userProfileService;
  final UserProfileCollaboratorIncrementalSyncService _collaboratorsService;
  final NotificationIncrementalSyncService _notificationsService;
  final TrackVersionIncrementalSyncService _trackVersionsService;
  final WaveformIncrementalSyncService _waveformsService;

  // Keys for SharedPreferences
  static const String _projectsLastSyncKey = 'projects_last_sync';
  static const String _tracksLastSyncKey = 'tracks_last_sync';
  static const String _commentsLastSyncKey = 'comments_last_sync';
  static const String _userProfileLastSyncKey = 'user_profile_last_sync';
  static const String _collaboratorsLastSyncKey = 'collaborators_last_sync';
  static const String _notificationsLastSyncKey = 'notifications_last_sync';
  static const String _trackVersionsLastSyncKey = 'track_versions_last_sync';
  static const String _waveformsLastSyncKey = 'waveforms_last_sync';

  SyncCoordinator(
    this._prefs,
    this._projectsService,
    this._tracksService,
    this._commentsService,
    this._userProfileService,
    this._collaboratorsService,
    this._notificationsService,
    this._trackVersionsService,
    this._waveformsService,
  );

  /// 🚀 Full sync on app startup (first time)
  Future<void> performFullSync(String userId) async {
    AppLogger.sync('COORDINATOR', 'Starting full sync for user: $userId');

    // Sync in dependency order: profile/projects → collaborators/tracks → versions → comments/waveforms
    await _syncEntity(
      _userProfileService,
      _userProfileLastSyncKey,
      'user_profile',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _projectsService,
      _projectsLastSyncKey,
      'projects',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _collaboratorsService,
      _collaboratorsLastSyncKey,
      'collaborators',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _tracksService,
      _tracksLastSyncKey,
      'tracks',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _trackVersionsService,
      _trackVersionsLastSyncKey,
      'track_versions',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _commentsService,
      _commentsLastSyncKey,
      'comments',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _waveformsService,
      _waveformsLastSyncKey,
      'waveforms',
      userId,
      isFullSync: true,
    );
    await _syncEntity(
      _notificationsService,
      _notificationsLastSyncKey,
      'notifications',
      userId,
      isFullSync: true,
    );

    AppLogger.sync('COORDINATOR', 'Full sync completed for user: $userId');
  }

  /// 🔄 Incremental sync (normal operation)
  Future<void> performIncrementalSync(String userId) async {
    AppLogger.sync(
      'COORDINATOR',
      'Starting incremental sync for user: $userId',
    );

    // Sync in dependency order: profile/projects → collaborators/tracks → versions → comments/waveforms
    await _syncEntity(
      _userProfileService,
      _userProfileLastSyncKey,
      'user_profile',
      userId,
    );
    await _syncEntity(
      _projectsService,
      _projectsLastSyncKey,
      'projects',
      userId,
    );
    await _syncEntity(
      _collaboratorsService,
      _collaboratorsLastSyncKey,
      'collaborators',
      userId,
    );
    await _syncEntity(_tracksService, _tracksLastSyncKey, 'tracks', userId);
    await _syncEntity(
      _trackVersionsService,
      _trackVersionsLastSyncKey,
      'track_versions',
      userId,
    );
    await _syncEntity(
      _commentsService,
      _commentsLastSyncKey,
      'comments',
      userId,
    );
    await _syncEntity(
      _waveformsService,
      _waveformsLastSyncKey,
      'waveforms',
      userId,
    );
    await _syncEntity(
      _notificationsService,
      _notificationsLastSyncKey,
      'notifications',
      userId,
    );

    AppLogger.sync(
      'COORDINATOR',
      'Incremental sync completed for user: $userId',
    );
  }

  /// 🎯 Sync specific entity (for targeted updates)
  Future<void> syncEntity(
    IncrementalSyncService service,
    String entityType,
    String userId, {
    bool forceFullSync = false,
  }) async {
    final key = _getKeyForEntity(entityType);
    await _syncEntity(
      service,
      key,
      entityType,
      userId,
      isFullSync: forceFullSync,
    );
  }

  /// 🔧 Core sync logic
  Future<void> _syncEntity(
    IncrementalSyncService service,
    String prefsKey,
    String entityType,
    String userId, {
    bool isFullSync = false,
  }) async {
    try {
      final result =
          isFullSync
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
        (syncResult) {
          // Update last sync time
          _setLastSyncTime(prefsKey, syncResult.serverTimestamp);

          final syncType = syncResult.wasFullSync ? 'full' : 'incremental';
          AppLogger.sync(
            'COORDINATOR',
            '$entityType $syncType sync: ${syncResult.totalChanges} changes',
            syncKey: userId,
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

  /// 📅 Get last sync time from SharedPreferences
  DateTime _getLastSyncTime(String key) {
    final timestamp = _prefs.getInt(key);
    if (timestamp == null) {
      // First sync ever - go back 30 days
      return DateTime.now().subtract(const Duration(days: 30));
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 💾 Save last sync time to SharedPreferences
  void _setLastSyncTime(String key, DateTime time) {
    _prefs.setInt(key, time.millisecondsSinceEpoch);
  }

  /// 🗝️ Get SharedPreferences key for entity type
  String _getKeyForEntity(String entityType) {
    switch (entityType) {
      case 'projects':
        return _projectsLastSyncKey;
      case 'tracks':
      case 'audio_tracks':
        return _tracksLastSyncKey;
      case 'comments':
      case 'audio_comments':
        return _commentsLastSyncKey;
      case 'user_profile':
      case 'profile':
        return _userProfileLastSyncKey;
      case 'collaborators':
      case 'user_profile_collaborators':
        return _collaboratorsLastSyncKey;
      case 'notifications':
        return _notificationsLastSyncKey;
      case 'track_versions':
      case 'versions':
        return _trackVersionsLastSyncKey;
      case 'waveforms':
        return _waveformsLastSyncKey;
      default:
        return '${entityType}_last_sync';
    }
  }

  /// 📊 Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    return {
      'projects_last_sync':
          _getLastSyncTime(_projectsLastSyncKey).toIso8601String(),
      'tracks_last_sync':
          _getLastSyncTime(_tracksLastSyncKey).toIso8601String(),
      'comments_last_sync':
          _getLastSyncTime(_commentsLastSyncKey).toIso8601String(),
      'user_profile_last_sync':
          _getLastSyncTime(_userProfileLastSyncKey).toIso8601String(),
      'collaborators_last_sync':
          _getLastSyncTime(_collaboratorsLastSyncKey).toIso8601String(),
      'notifications_last_sync':
          _getLastSyncTime(_notificationsLastSyncKey).toIso8601String(),
      'track_versions_last_sync':
          _getLastSyncTime(_trackVersionsLastSyncKey).toIso8601String(),
      'waveforms_last_sync':
          _getLastSyncTime(_waveformsLastSyncKey).toIso8601String(),
      'strategy': 'central_coordinator_with_incremental_services',
    };
  }

  /// Get current sync state for UI display
  Future<Either<Failure, SyncState>> getCurrentSyncState() async {
    try {
      // For now, return a simple complete state
      // TODO: Implement proper sync state tracking
      return Right(SyncState.complete());
    } catch (e) {
      return Left(ServerFailure('Failed to get sync state: $e'));
    }
  }

  /// Watch sync state changes for reactive UI updates
  Stream<SyncState> watchSyncState() {
    // For now, return a simple stream that emits complete state
    // TODO: Implement proper sync state streaming
    return Stream.value(SyncState.complete());
  }
}

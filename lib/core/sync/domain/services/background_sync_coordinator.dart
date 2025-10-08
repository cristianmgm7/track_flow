/// Interface for triggering sync operations
///
/// This abstraction allows decoupling sync trigger logic from concrete implementations,
/// making it easier to test and avoiding circular dependencies.
///
/// Use this interface in BLoCs and services that need to trigger sync operations
/// but should not depend directly on BackgroundSyncCoordinator.
abstract class BackgroundSyncCoordinator {
  /// Trigger startup sync (critical data only)
  ///
  /// This method syncs only the most critical data needed for app initialization:
  /// - User profile
  /// - Projects list
  /// - Collaborators
  ///
  /// [userId] - The ID of the user to sync data for
  Future<void> triggerStartupSync(String userId);

  /// Trigger foreground sync (non-critical data)
  ///
  /// This method syncs non-critical data when app comes to foreground:
  /// - Audio comments
  /// - Waveforms
  ///
  /// [userId] - The ID of the user to sync data for
  Future<void> triggerForegroundSync(String userId);

  /// Trigger full sync (all data)
  ///
  /// This method performs a comprehensive sync of all entity types.
  /// Use sparingly as it can be resource-intensive.
  ///
  /// [userId] - The ID of the user to sync data for
  Future<void> triggerFullSync(String userId);

  /// Trigger sync for specific entities
  ///
  /// This method syncs only the specified entity types, useful for
  /// targeted updates after specific user actions.
  ///
  /// [userId] - The ID of the user to sync data for
  /// [entityTypes] - List of entity type names to sync (e.g., ['projects', 'audio_tracks'])
  Future<void> triggerEntitySync(String userId, List<String> entityTypes);

  /// Push pending operations upstream
  ///
  /// This method processes all pending operations (create, update, delete)
  /// that were queued while offline and pushes them to the remote server.
  Future<void> pushUpstream();

  /// Check if any sync operation is currently in progress
  bool get hasSyncInProgress;
}

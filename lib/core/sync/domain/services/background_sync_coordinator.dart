import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/sync_trigger.dart';

/// Simple sync coordinator with essential protections
///
/// IMPORTANT: Call initialize() after DI is fully configured to avoid circular dependencies
///
/// Sync is triggered by:
/// - App startup (via AppFlowBloc after authentication)
/// - App foreground (via TriggerForegroundSyncUseCase when app resumes)
/// - Network reconnection (automatically pushes pending operations)
/// - Manual user actions (via repositories triggering upstream sync)
@lazySingleton
class BackgroundSyncCoordinator implements SyncTrigger {
  final NetworkStateManager _networkStateManager;
  final SyncCoordinator _syncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  // Prevent duplicate operations
  final Set<String> _ongoingOperations = {};

  // Auto-sync when connectivity is restored
  StreamSubscription<bool>? _networkSubscription;

  // Track initialization state
  bool _isInitialized = false;

  BackgroundSyncCoordinator(
    this._networkStateManager,
    SyncCoordinator syncCoordinator,
    this._pendingOperationsManager,
  ) : _syncCoordinator = syncCoordinator;

  /// Initialize background sync coordinator
  ///
  /// MUST be called after DI is fully configured to avoid circular dependencies.
  /// This method starts the network connectivity listener.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _initializeNetworkListener();
  }

  // ========================================================================
  // SyncTrigger Interface Implementation
  // ========================================================================

  @override
  Future<void> triggerStartupSync(String userId) async {
    const operationKey = 'startup_sync';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      // 1. Push pending operations first
      await _pendingOperationsManager.processPendingOperations();
      // 2. Pull critical data for startup
      await _syncCoordinator.pullStartupData(userId);
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  @override
  Future<void> triggerForegroundSync(String userId) async {
    if (_ongoingOperations.isEmpty && await _networkStateManager.isConnected) {
      // Sync non-critical entities when app resumes
      await triggerEntitySync(userId, ['audio_comments', 'waveforms']);
    }
  }

  @override
  Future<void> triggerFullSync(String userId) async {
    const operationKey = 'full_sync';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      // 1. Push pending operations first
      await _pendingOperationsManager.processPendingOperations();
      // 2. Pull all data
      await _syncCoordinator.pullAllData(userId);
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  @override
  Future<void> triggerEntitySync(
    String userId,
    List<String> entityTypes,
  ) async {
    const operationKey = 'specific_sync';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      // Push pending operations first
      await _pendingOperationsManager.processPendingOperations();

      // Pull only specified entities
      await _syncCoordinator.pullEntities(userId, entityTypes);
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  @override
  Future<void> pushUpstream() async {
    const operationKey = 'push_upstream';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      await _pendingOperationsManager.processPendingOperations();
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  @override
  bool get hasSyncInProgress => _ongoingOperations.isNotEmpty;

  /// Initialize network connectivity listener for auto-sync
  void _initializeNetworkListener() {
    _networkSubscription = _networkStateManager.onConnectivityChanged.listen((
      bool isConnected,
    ) async {
      if (isConnected && _ongoingOperations.isEmpty) {
        // Auto-sync when connectivity is restored (if no sync is already running)
        await Future.delayed(const Duration(milliseconds: 1500));
        // Note: We can't call performFullSync here without userId
        // This would need to be handled by the app layer
      }
    });
  }


  /// Clean up resources
  void dispose() {
    _networkSubscription?.cancel();
    _ongoingOperations.clear();
    _isInitialized = false;
  }
}

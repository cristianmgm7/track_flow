import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';

/// Simple sync coordinator with essential protections
@lazySingleton
class BackgroundSyncCoordinator {
  final NetworkStateManager _networkStateManager;
  final SyncCoordinator _syncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  // Prevent duplicate operations
  final Set<String> _ongoingOperations = {};

  // Auto-sync when connectivity is restored
  StreamSubscription<bool>? _networkSubscription;

  BackgroundSyncCoordinator(
    this._networkStateManager,
    this._syncCoordinator,
    this._pendingOperationsManager,
  ) {
    _initializeNetworkListener();
  }

  /// Push pending operations to remote
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

  /// Perform startup sync (upstream + critical downstream data)
  Future<void> performStartupSync(String userId) async {
    const operationKey = 'startup_sync';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      // 1. Push pending operations first
      await _pendingOperationsManager.processPendingOperations();
      // 2. Pull critical data for startup
      await _syncCoordinator.pull(userId, syncKey: 'appstartup');
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  /// Perform full sync (upstream + downstream)
  Future<void> performFullSync(String userId) async {
    const operationKey = 'full_sync';

    if (_ongoingOperations.contains(operationKey)) return;
    if (!await _networkStateManager.isConnected) return;

    _ongoingOperations.add(operationKey);
    try {
      // 1. Push pending operations first
      await _pendingOperationsManager.processPendingOperations();
      // 2. Pull all data
      await _syncCoordinator.pull(userId, syncKey: 'full');
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  /// Check if any sync operation is in progress
  bool get hasOngoingOperations => _ongoingOperations.isNotEmpty;

  /// Get list of ongoing operation keys
  List<String> get ongoingOperations => _ongoingOperations.toList();

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
  }
}

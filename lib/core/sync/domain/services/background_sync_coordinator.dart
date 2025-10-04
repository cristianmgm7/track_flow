import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';

/// Simple sync coordinator with essential protections
@lazySingleton
class BackgroundSyncCoordinator {
  final NetworkStateManager _networkStateManager;
  final SyncOrchestrator _syncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;
  final SessionService _sessionService;

  // Prevent duplicate operations
  final Set<String> _ongoingOperations = {};

  // Auto-sync when connectivity is restored
  StreamSubscription<bool>? _networkSubscription;

  // Periodic sync timer for non-critical entities
  Timer? _periodicSyncTimer;

  BackgroundSyncCoordinator(
    this._networkStateManager,
    SyncOrchestrator syncCoordinator,
    this._pendingOperationsManager,
    this._sessionService,
  ) : _syncCoordinator = syncCoordinator {
    _initializeNetworkListener();
    _initializePeriodicSync();
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

  /// Sync specific entities (for targeted updates)
  Future<void> syncSpecificEntities(
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

      // Sync only specified entities
      for (final entityType in entityTypes) {
        await _syncCoordinator.syncEntityByType(userId, entityType);
      }
    } finally {
      _ongoingOperations.remove(operationKey);
    }
  }

  /// Sync non-critical entities (comments, waveforms)
  Future<void> syncNonCriticalEntities(String userId) async {
    await syncSpecificEntities(userId, ['audio_comments', 'waveforms']);
  }

  /// Trigger sync when app comes to foreground (for fresh data)
  Future<void> onAppForeground(String userId) async {
    if (_ongoingOperations.isEmpty && await _networkStateManager.isConnected) {
      // Sync non-critical entities when app resumes
      await syncNonCriticalEntities(userId);
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

  /// Initialize periodic sync for non-critical entities
  void _initializePeriodicSync() {
    // Sync every 15 minutes for non-critical entities (comments, waveforms)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 15), (
      timer,
    ) async {
      if (_ongoingOperations.isEmpty &&
          await _networkStateManager.isConnected) {
        // Get current user session
        final sessionResult = await _sessionService.getCurrentSession();
        if (sessionResult.isRight()) {
          final session = sessionResult.getOrElse(
            () => UserSession.unauthenticated(),
          );
          if (session.currentUser != null) {
            await syncNonCriticalEntities(session.currentUser!.id.value);
          }
        }
      }
    });
  }

  /// Clean up resources
  void dispose() {
    _networkSubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _ongoingOperations.clear();
  }
}

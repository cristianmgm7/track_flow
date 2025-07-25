import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Enhanced network state management with reactive connectivity monitoring
///
/// Provides both immediate connectivity checks and reactive streams for
/// network state changes. More reliable than basic connectivity checks as
/// it validates actual internet connectivity, not just network interface status.
@lazySingleton
class NetworkStateManager {
  final InternetConnectionChecker _connectionChecker;
  final Connectivity _connectivity;

  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  // Cache the last known state to avoid redundant checks
  bool? _lastKnownState;

  // Subscription to connectivity changes
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  NetworkStateManager(this._connectionChecker, this._connectivity) {
    _initializeConnectivityMonitoring();
  }

  /// Stream of network connectivity changes
  /// Emits true when connected, false when disconnected
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Current network connectivity state
  /// Returns cached value if available, otherwise performs fresh check
  Future<bool> get isConnected async {
    try {
      final isConnected = await _connectionChecker.hasConnection;
      _updateConnectionState(isConnected);
      return isConnected;
    } catch (e) {
      // Fallback: assume offline if check fails
      _updateConnectionState(false);
      return false;
    }
  }

  /// Force a fresh connectivity check and emit state change if different
  Future<bool> checkConnectivity() async {
    final currentState = await isConnected;
    return currentState;
  }

  /// Check if device has specific network capabilities
  Future<bool> hasWifiConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is on mobile data
  Future<bool> hasMobileConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }

  /// Check if we have a "good" connection suitable for sync operations
  Future<bool> hasGoodConnection() async {
    if (!await isConnected) return false;

    // For now, any internet connection is considered "good"
    // Future enhancement: could check connection speed/quality
    return true;
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivityMonitoring() {
    // Listen to connectivity changes from the device
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      // When connectivity changes, verify actual internet access
      await checkConnectivity();
    });

    // Perform initial connectivity check
    checkConnectivity();
  }

  /// Update connection state and notify listeners if changed
  void _updateConnectionState(bool isConnected) {
    if (_lastKnownState != isConnected) {
      _lastKnownState = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  /// Clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

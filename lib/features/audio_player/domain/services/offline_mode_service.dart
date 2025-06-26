import 'dart:async';

import 'package:trackflow/features/audio_player/domain/models/connectivity_models.dart.dart';

/// Service for detecting and managing offline mode behavior
/// Provides network connectivity monitoring and offline-first strategy coordination
abstract class OfflineModeService {
  /// Stream that emits connectivity status changes
  Stream<ConnectivityStatus> get connectivityStream;

  /// Current connectivity status
  ConnectivityStatus get currentConnectivity;

  /// Checks if the device is currently online
  bool get isOnline;

  /// Checks if the device is currently offline
  bool get isOffline;

  /// Gets the offline mode preference
  Future<OfflineMode> getOfflineMode();

  /// Sets the offline mode preference
  Future<void> setOfflineMode(OfflineMode mode);

  /// Enables offline-only mode (disables streaming)
  Future<void> enableOfflineOnlyMode();

  /// Disables offline-only mode (allows streaming)
  Future<void> disableOfflineOnlyMode();

  /// Checks if offline-only mode is enabled
  Future<bool> isOfflineOnlyModeEnabled();

  /// Gets network quality information
  Future<NetworkQuality> getNetworkQuality();

  /// Sets bandwidth usage preference
  Future<void> setBandwidthPreference(BandwidthPreference preference);

  /// Gets current bandwidth usage preference
  Future<BandwidthPreference> getBandwidthPreference();

  /// Triggers manual connectivity check
  Future<ConnectivityStatus> checkConnectivity();

  /// Gets data usage statistics
  Future<DataUsageStats> getDataUsageStats();

  /// Resets data usage statistics
  Future<void> resetDataUsageStats();
}

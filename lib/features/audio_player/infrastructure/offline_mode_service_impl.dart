import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trackflow/features/audio_player/domain/models/connectivity_models.dart.dart';
import 'package:trackflow/features/audio_player/domain/services/offline_mode_service.dart';

@Injectable(as: OfflineModeService)
class OfflineModeServiceImpl implements OfflineModeService {
  static const String _offlineModeKey = 'offline_mode';
  static const String _bandwidthPreferenceKey = 'bandwidth_preference';
  static const String _offlineOnlyKey = 'offline_only_mode';
  static const String _dataUsageKey = 'data_usage_stats';

  final Connectivity _connectivity;
  late final StreamController<ConnectivityStatus> _connectivityController;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  OfflineMode _currentOfflineMode = OfflineMode.auto;
  BandwidthPreference _currentBandwidthPreference =
      BandwidthPreference.unlimited;
  bool _offlineOnlyMode = false;

  OfflineModeServiceImpl(this._connectivity) {
    _connectivityController = StreamController<ConnectivityStatus>.broadcast();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _loadPreferences();
    await _initializeConnectivityMonitoring();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final offlineModeIndex =
          prefs.getInt(_offlineModeKey) ?? OfflineMode.auto.index;
      _currentOfflineMode = OfflineMode.values[offlineModeIndex];

      final bandwidthIndex =
          prefs.getInt(_bandwidthPreferenceKey) ??
          BandwidthPreference.unlimited.index;
      _currentBandwidthPreference = BandwidthPreference.values[bandwidthIndex];

      _offlineOnlyMode = prefs.getBool(_offlineOnlyKey) ?? false;
    } catch (e) {
      // Use defaults on error
    }
  }

  Future<void> _initializeConnectivityMonitoring() async {
    // Check initial connectivity
    _currentStatus = await _checkCurrentConnectivity();
    _connectivityController.add(_currentStatus);

    // Monitor connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      final newStatus = _mapConnectivityResult(result);
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _connectivityController.add(_currentStatus);
      }
    });
  }

  @override
  Stream<ConnectivityStatus> get connectivityStream =>
      _connectivityController.stream;

  @override
  ConnectivityStatus get currentConnectivity => _currentStatus;

  @override
  bool get isOnline =>
      _currentStatus == ConnectivityStatus.online ||
      _currentStatus == ConnectivityStatus.limited;

  @override
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  @override
  Future<OfflineMode> getOfflineMode() async {
    return _currentOfflineMode;
  }

  @override
  Future<void> setOfflineMode(OfflineMode mode) async {
    try {
      _currentOfflineMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_offlineModeKey, mode.index);
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<void> enableOfflineOnlyMode() async {
    try {
      _offlineOnlyMode = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineOnlyKey, true);
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<void> disableOfflineOnlyMode() async {
    try {
      _offlineOnlyMode = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineOnlyKey, false);
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<bool> isOfflineOnlyModeEnabled() async {
    return _offlineOnlyMode;
  }

  @override
  Future<NetworkQuality> getNetworkQuality() async {
    if (_offlineOnlyMode || isOffline) {
      return NetworkQuality.offline;
    }

    final connectivityResult = await _connectivity.checkConnectivity();

    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return NetworkQuality.excellent;
      case ConnectivityResult.mobile:
        return _getMobileNetworkQuality();
      case ConnectivityResult.ethernet:
        return NetworkQuality.excellent;
      case ConnectivityResult.bluetooth:
        return NetworkQuality.limited;
      case ConnectivityResult.none:
        return NetworkQuality.offline;
      default:
        return NetworkQuality.poor;
    }
  }

  Future<NetworkQuality> _getMobileNetworkQuality() async {
    // In a real implementation, you might check:
    // - Signal strength
    // - Data plan limitations
    // - Current bandwidth
    // For now, we'll return a default based on bandwidth preference

    switch (_currentBandwidthPreference) {
      case BandwidthPreference.unlimited:
        return NetworkQuality.good;
      case BandwidthPreference.wifi:
        return NetworkQuality.limited; // Discourage mobile usage
      case BandwidthPreference.limited:
        return NetworkQuality.limited;
      case BandwidthPreference.emergency:
        return NetworkQuality.poor;
    }
  }

  @override
  Future<void> setBandwidthPreference(BandwidthPreference preference) async {
    try {
      _currentBandwidthPreference = preference;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bandwidthPreferenceKey, preference.index);
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Future<BandwidthPreference> getBandwidthPreference() async {
    return _currentBandwidthPreference;
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    _currentStatus = await _checkCurrentConnectivity();
    _connectivityController.add(_currentStatus);
    return _currentStatus;
  }

  Future<ConnectivityStatus> _checkCurrentConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _mapConnectivityResult(result);
    } catch (e) {
      return ConnectivityStatus.unknown;
    }
  }

  ConnectivityStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.online;
      case ConnectivityResult.mobile:
        // Consider mobile as limited if bandwidth preference restricts it
        return _currentBandwidthPreference == BandwidthPreference.wifi
            ? ConnectivityStatus.limited
            : ConnectivityStatus.online;
      case ConnectivityResult.bluetooth:
        return ConnectivityStatus.limited;
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
      default:
        return ConnectivityStatus.unknown;
    }
  }

  @override
  Future<DataUsageStats> getDataUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_dataUsageKey);

      if (statsJson != null) {
        final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
        return DataUsageStats(
          totalBytesDownloaded: statsMap['totalBytesDownloaded'] as int,
          totalBytesStreamed: statsMap['totalBytesStreamed'] as int,
          sessionsCount: statsMap['sessionsCount'] as int,
          periodStart: DateTime.parse(statsMap['periodStart'] as String),
          periodEnd: DateTime.parse(statsMap['periodEnd'] as String),
          dailyUsage: Map<String, int>.from(statsMap['dailyUsage'] as Map),
        );
      }
    } catch (e) {
      // Handle error gracefully
    }

    // Return empty stats
    final now = DateTime.now();
    return DataUsageStats(
      totalBytesDownloaded: 0,
      totalBytesStreamed: 0,
      sessionsCount: 0,
      periodStart: now,
      periodEnd: now,
      dailyUsage: {},
    );
  }

  @override
  Future<void> resetDataUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dataUsageKey);
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Updates data usage statistics (called by other services)
  Future<void> updateDataUsage({
    int downloadedBytes = 0,
    int streamedBytes = 0,
  }) async {
    try {
      final currentStats = await getDataUsageStats();
      final today = DateTime.now().toIso8601String().substring(0, 10);

      final updatedDailyUsage = Map<String, int>.from(currentStats.dailyUsage);
      updatedDailyUsage[today] =
          (updatedDailyUsage[today] ?? 0) + downloadedBytes + streamedBytes;

      final updatedStats = DataUsageStats(
        totalBytesDownloaded:
            currentStats.totalBytesDownloaded + downloadedBytes,
        totalBytesStreamed: currentStats.totalBytesStreamed + streamedBytes,
        sessionsCount:
            currentStats.sessionsCount +
            (downloadedBytes > 0 || streamedBytes > 0 ? 1 : 0),
        periodStart: currentStats.periodStart,
        periodEnd: DateTime.now(),
        dailyUsage: updatedDailyUsage,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _dataUsageKey,
        jsonEncode({
          'totalBytesDownloaded': updatedStats.totalBytesDownloaded,
          'totalBytesStreamed': updatedStats.totalBytesStreamed,
          'sessionsCount': updatedStats.sessionsCount,
          'periodStart': updatedStats.periodStart.toIso8601String(),
          'periodEnd': updatedStats.periodEnd.toIso8601String(),
          'dailyUsage': updatedStats.dailyUsage,
        }),
      );
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Determines if an operation should proceed based on current connectivity and preferences
  Future<bool> shouldAllowNetworkOperation({
    required bool isDownload,
    required int estimatedBytes,
  }) async {
    // Always block if offline-only mode is enabled
    if (_offlineOnlyMode) return false;

    // Block if offline
    if (isOffline) return false;

    // Check bandwidth preferences
    switch (_currentBandwidthPreference) {
      case BandwidthPreference.unlimited:
        return true;
      case BandwidthPreference.wifi:
        final currentConnectivity = await _connectivity.checkConnectivity();
        return _currentStatus == ConnectivityStatus.online &&
            currentConnectivity == ConnectivityResult.wifi;
      case BandwidthPreference.limited:
        // Allow small operations, restrict large downloads
        return estimatedBytes < 10 * 1024 * 1024; // 10MB limit
      case BandwidthPreference.emergency:
        // Only allow very small operations
        return estimatedBytes < 1 * 1024 * 1024; // 1MB limit
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController.close();
  }
}

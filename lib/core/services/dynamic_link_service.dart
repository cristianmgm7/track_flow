import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/services/deep_link_service.dart';

/// Legacy wrapper for Firebase Dynamic Links functionality
/// Now delegates to the new DeepLinkService
@singleton
class DynamicLinkService {
  static final DynamicLinkService _instance = DynamicLinkService._internal();
  factory DynamicLinkService() => _instance;
  DynamicLinkService._internal();

  final DeepLinkService _deepLinkService = DeepLinkService();

  /// Delegate to the new deep link service
  ValueNotifier<String?> get magicLinkToken => _deepLinkService.magicLinkToken;

  /// Call this at app startup (e.g., in main.dart)
  /// Note: This is now a no-op since we handle deep links differently
  Future<void> init() async {
    // Firebase Dynamic Links are deprecated
    // Deep link handling is now done through the new DeepLinkService
    // and platform-specific implementations (iOS Universal Links, Android App Links)
    debugPrint('DynamicLinkService.init() called - Firebase Dynamic Links are deprecated');
  }
}

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Service to handle incoming Firebase Dynamic Links (Magic Links)
@singleton
class DynamicLinkService {
  static final DynamicLinkService _instance = DynamicLinkService._internal();
  factory DynamicLinkService() => _instance;
  DynamicLinkService._internal();

  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;
  final ValueNotifier<String?> magicLinkToken = ValueNotifier<String?>(null);

  /// Call this at app startup (e.g., in main.dart)
  Future<void> init() async {
    // Handle dynamic link if app was opened from terminated state
    final PendingDynamicLinkData? initialLink =
        await _dynamicLinks.getInitialLink();
    _handleDynamicLink(initialLink);

    // Listen for dynamic links while app is running
    _dynamicLinks.onLink.listen((PendingDynamicLinkData? dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      // Example: https://yourapp.page.link/magic-link/<token>
      final segments = deepLink.pathSegments;
      if (segments.isNotEmpty && segments.first == 'magic-link') {
        final token = segments.length > 1 ? segments[1] : null;
        if (token != null && token.isNotEmpty) {
          magicLinkToken.value = token;
        }
      }
    }
  }
}

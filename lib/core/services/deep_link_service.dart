import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Service to handle incoming deep links (replacement for Firebase Dynamic Links)
/// Uses custom URL schemes and universal links for cross-platform support
@singleton
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final ValueNotifier<String?> magicLinkToken = ValueNotifier<String?>(null);
  
  static const String _baseUrl = 'https://trackflow.app';
  static const String _customScheme = 'trackflow';

  /// Generate a cross-platform deep link
  Future<String> generateDeepLink({
    required String type,
    required String token,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$_baseUrl/$type/$token');
    
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters).toString();
    }
    
    return uri.toString();
  }

  /// Handle incoming deep links (to be called from main.dart)
  Future<void> handleIncomingLink(String link) async {
    try {
      final uri = Uri.parse(link);
      
      // Handle web URLs (https://trackflow.app/magic-link/token)
      if (uri.host == 'trackflow.app' || uri.host == 'www.trackflow.app') {
        _handleWebLink(uri);
        return;
      }
      
      // Handle custom scheme URLs (trackflow://magic-link/token)
      if (uri.scheme == _customScheme) {
        _handleCustomSchemeLink(uri);
        return;
      }
      
      debugPrint('Unhandled deep link: $link');
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  void _handleWebLink(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments.first == 'magic-link') {
      final token = segments.length > 1 ? segments[1] : null;
      if (token != null && token.isNotEmpty) {
        magicLinkToken.value = token;
      }
    }
  }

  void _handleCustomSchemeLink(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments.first == 'magic-link') {
      final token = segments.length > 1 ? segments[1] : null;
      if (token != null && token.isNotEmpty) {
        magicLinkToken.value = token;
      }
    }
  }

  /// Launch a deep link in external browser/app
  /// Note: This is a simplified implementation. For production use, consider
  /// adding url_launcher package dependency and proper URL launching capabilities
  Future<bool> launchDeepLink(String url) async {
    try {
      debugPrint('Deep link generated: $url');
      // In a real implementation, this would use url_launcher package
      // For now, we just return true to indicate the link was "generated"
      return true;
    } catch (e) {
      debugPrint('Error launching deep link: $e');
      return false;
    }
  }

  /// Generate a magic link for sharing
  Future<String> generateMagicLink({
    required String projectId,
    required String token,
  }) async {
    return generateDeepLink(
      type: 'magic-link',
      token: token,
      queryParameters: {
        'project': projectId,
      },
    );
  }

  /// Clear the current magic link token
  void clearMagicLinkToken() {
    magicLinkToken.value = null;
  }
}
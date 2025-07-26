import 'package:go_router/go_router.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Handles dynamic link processing following Single Responsibility Principle
///
/// This service is responsible for:
/// - Listening to dynamic link tokens
/// - Processing magic link tokens
/// - Navigating to appropriate screens
/// - Cleaning up tokens after processing
class DynamicLinkHandler {
  final DynamicLinkService _dynamicLinkService;
  final GoRouter _router;

  DynamicLinkHandler({
    required DynamicLinkService dynamicLinkService,
    required GoRouter router,
  }) : _dynamicLinkService = dynamicLinkService,
       _router = router;

  /// Initialize the dynamic link handler
  void initialize() {
    AppLogger.info(
      'Initializing dynamic link handler',
      tag: 'DYNAMIC_LINK_HANDLER',
    );
    _dynamicLinkService.magicLinkToken.addListener(_handleMagicLinkToken);
  }

  /// Dispose of the dynamic link handler
  void dispose() {
    AppLogger.info(
      'Disposing dynamic link handler',
      tag: 'DYNAMIC_LINK_HANDLER',
    );
    _dynamicLinkService.magicLinkToken.removeListener(_handleMagicLinkToken);
  }

  /// Handle magic link token changes
  void _handleMagicLinkToken() {
    final token = _dynamicLinkService.magicLinkToken.value;

    if (token != null && token.isNotEmpty) {
      AppLogger.info(
        'Processing magic link token: ${token.substring(0, 8)}...',
        tag: 'DYNAMIC_LINK_HANDLER',
      );

      // Navigate to magic link handler screen
      _router.go(AppRoutes.magicLink);

      // Clean up the token after processing
      _dynamicLinkService.magicLinkToken.value = null;

      AppLogger.info(
        'Magic link token processed and cleaned up',
        tag: 'DYNAMIC_LINK_HANDLER',
      );
    }
  }
}

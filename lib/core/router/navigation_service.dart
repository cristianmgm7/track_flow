import 'package:injectable/injectable.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';

/// Centralized navigation service that handles routing logic based on app flow state
/// Removes business logic from router redirect function for cleaner architecture
@injectable
class NavigationService {
  /// Determines the appropriate route based on the current app flow state
  /// Returns null if no redirect is needed (stay on current route)
  String? getRouteForFlowState(AppFlowState flowState, String currentLocation) {
    if (flowState is AppFlowUnauthenticated) {
      return _handleUnauthenticatedState(currentLocation);
    } else if (flowState is AppFlowAuthenticated) {
      return _handleAuthenticatedState(flowState, currentLocation);
    } else if (flowState is AppFlowReady) {
      return _handleReadyState(currentLocation);
    } else if (flowState is AppFlowLoading) {
      return _handleLoadingState(currentLocation);
    } else if (flowState is AppFlowError) {
      return _handleErrorState(flowState, currentLocation);
    }

    return null;
  }

  /// Handle routing for unauthenticated users
  String? _handleUnauthenticatedState(String currentLocation) {
    // Redirect authenticated routes to auth screen
    final protectedRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.profileCreation,
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
    ];

    if (protectedRoutes.contains(currentLocation)) {
      return AppRoutes.auth;
    }

    return null; // Stay on current route
  }

  /// Handle routing for authenticated but incomplete users
  String? _handleAuthenticatedState(
    AppFlowAuthenticated state,
    String currentLocation,
  ) {
    // Priority: onboarding first, then profile setup
    if (state.needsOnboarding) {
      return AppRoutes.onboarding;
    } else if (state.needsProfileSetup) {
      return AppRoutes.profileCreation;
    }

    // User is authenticated and setup is complete, navigate to dashboard
    final setupRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.auth,
      AppRoutes.profileCreation,
    ];

    if (setupRoutes.contains(currentLocation)) {
      return AppRoutes.dashboard;
    }

    return null; // Stay on current route
  }

  /// Handle routing for fully ready users
  String? _handleReadyState(String currentLocation) {
    final setupRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.auth,
      AppRoutes.profileCreation,
    ];

    if (setupRoutes.contains(currentLocation)) {
      return AppRoutes.dashboard;
    }

    return null; // Stay on current route
  }

  /// Handle routing during loading states
  String? _handleLoadingState(String currentLocation) {
    // Trigger flow check if on splash screen
    // Note: This will be handled by the router's redirect function

    return null; // Stay on current route while loading
  }

  /// Handle routing for error states
  String? _handleErrorState(AppFlowError state, String currentLocation) {
    // Could redirect to error page in the future
    // For now, stay on current route to allow error display
    return null;
  }

  /// Check if a route requires authentication
  bool isProtectedRoute(String route) {
    final protectedRoutes = [
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
      AppRoutes.projectDetails,
      AppRoutes.manageCollaborators,
      AppRoutes.userProfile,
      AppRoutes.artistProfile,
      AppRoutes.audioComments,
      AppRoutes.cacheDemo,
      '/storage-management',
    ];

    return protectedRoutes.contains(route);
  }

  /// Check if a route is part of the setup flow
  bool isSetupRoute(String route) {
    final setupRoutes = [
      AppRoutes.auth,
      AppRoutes.onboarding,
      AppRoutes.profileCreation,
      AppRoutes.magicLink,
    ];

    return setupRoutes.contains(route);
  }

  /// Get the appropriate initial route based on app state
  String getInitialRoute() {
    return AppRoutes.splash;
  }
}

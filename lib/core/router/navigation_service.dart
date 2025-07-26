import 'package:injectable/injectable.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';

/// Centralized navigation service that handles routing logic based on app flow state
/// Removes business logic from router redirect function for cleaner architecture
@injectable
class NavigationService {
  /// Determines the appropriate route based on the current app flow state
  /// Returns null if no redirect is needed (stay on current route)
  String? getRouteForFlowState(AppFlowState state, String currentLocation) {
    switch (state.runtimeType) {
      case AppFlowLoading:
        if (currentLocation != '/') {
          return '/';
        }
        return null;

      case AppFlowUnauthenticated:
        if (currentLocation != AppRoutes.auth) {
          return AppRoutes.auth;
        }
        return null;

      case AppFlowAuthenticated:
        final authenticatedState = state as AppFlowAuthenticated;
        if (authenticatedState.needsOnboarding) {
          if (currentLocation != AppRoutes.onboarding) {
            return AppRoutes.onboarding;
          }
        } else if (authenticatedState.needsProfileSetup) {
          if (currentLocation != AppRoutes.profileCreation) {
            return AppRoutes.profileCreation;
          }
        } else {
          // User is fully set up, go to dashboard
          if (currentLocation != AppRoutes.dashboard) {
            return AppRoutes.dashboard;
          }
        }
        return null;

      case AppFlowReady:
        // Ready users can access dashboard, projects, settings, and other main app routes
        final allowedRoutes = [
          AppRoutes.dashboard,
          AppRoutes.projects,
          AppRoutes.settings,
          AppRoutes.notifications,
          AppRoutes.userProfile,
          AppRoutes.manageCollaborators,
          AppRoutes.audioComments,
          AppRoutes.cacheDemo,
        ];

        if (!allowedRoutes.contains(currentLocation)) {
          return AppRoutes.dashboard;
        }
        return null;

      case AppFlowError:
        final errorState = state as AppFlowError;
        if (currentLocation != '/error') {
          return '/error';
        }
        return null;

      default:
        return null;
    }
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
    // If user needs onboarding, redirect to onboarding
    if (state.needsOnboarding) {
      if (currentLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      return null; // Already on onboarding
    }

    // If user needs profile setup, redirect to profile creation
    if (state.needsProfileSetup) {
      if (currentLocation != AppRoutes.profileCreation) {
        return AppRoutes.profileCreation;
      }
      return null; // Already on profile creation
    }

    // User is authenticated and complete, redirect to dashboard
    if (currentLocation != AppRoutes.dashboard) {
      return AppRoutes.dashboard;
    }

    return null; // Already on dashboard
  }

  /// Handle routing for ready users
  String? _handleReadyState(String currentLocation) {
    // Ready users should be on dashboard or projects
    final allowedRoutes = [
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
    ];

    if (!allowedRoutes.contains(currentLocation)) {
      return AppRoutes.dashboard;
    }

    return null; // Stay on current route
  }

  /// Handle routing for loading state
  String? _handleLoadingState(String currentLocation) {
    // During loading, stay on current route unless it's a protected route
    final protectedRoutes = [
      AppRoutes.onboarding,
      AppRoutes.profileCreation,
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
    ];

    if (protectedRoutes.contains(currentLocation)) {
      return AppRoutes.splash;
    }

    return null; // Stay on current route
  }

  /// Handle routing for error state
  String? _handleErrorState(AppFlowError state, String currentLocation) {
    // On error, redirect to auth screen
    if (currentLocation != AppRoutes.auth) {
      return AppRoutes.auth;
    }

    return null; // Already on auth screen
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

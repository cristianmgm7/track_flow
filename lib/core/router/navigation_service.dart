import 'package:injectable/injectable.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Centralized navigation service that handles routing logic based on app flow state
/// Removes business logic from router redirect function for cleaner architecture
@injectable
class NavigationService {
  /// Determines the appropriate route based on the current app flow state
  /// Returns null if no redirect is needed (stay on current route)
  String? getRouteForFlowState(AppFlowState state, String currentLocation) {
    AppLogger.info(
      'NavigationService: Evaluating route for state $state at location: $currentLocation',
      tag: 'NAVIGATION',
    );

    switch (state.runtimeType) {
      case AppFlowLoading:
        AppLogger.info(
          'NavigationService: Handling loading state at: $currentLocation',
          tag: 'NAVIGATION',
        );
        if (currentLocation != '/') {
          AppLogger.info(
            'NavigationService: Redirecting from protected route during loading to splash',
            tag: 'NAVIGATION',
          );
          return '/';
        }
        return null;

      case AppFlowUnauthenticated:
        AppLogger.info(
          'NavigationService: Handling unauthenticated state at: $currentLocation',
          tag: 'NAVIGATION',
        );
        if (currentLocation != AppRoutes.auth) {
          AppLogger.info(
            'NavigationService: Redirecting to auth',
            tag: 'NAVIGATION',
          );
          return AppRoutes.auth;
        }
        return null;

      case AppFlowAuthenticated:
        final authenticatedState = state as AppFlowAuthenticated;
        AppLogger.info(
          'NavigationService: Handling authenticated state - needsOnboarding: ${authenticatedState.needsOnboarding}, needsProfileSetup: ${authenticatedState.needsProfileSetup} at: $currentLocation',
          tag: 'NAVIGATION',
        );

        if (authenticatedState.needsOnboarding) {
          if (currentLocation != AppRoutes.onboarding) {
            AppLogger.info(
              'NavigationService: Redirecting to onboarding (needs onboarding)',
              tag: 'NAVIGATION',
            );
            return AppRoutes.onboarding;
          }
        } else if (authenticatedState.needsProfileSetup) {
          if (currentLocation != AppRoutes.profileCreation) {
            AppLogger.info(
              'NavigationService: Redirecting to profile setup (needs profile setup)',
              tag: 'NAVIGATION',
            );
            return AppRoutes.profileCreation;
          }
        } else {
          // User is fully set up, go to dashboard
          if (currentLocation != AppRoutes.dashboard) {
            AppLogger.info(
              'NavigationService: Redirecting to dashboard (fully set up)',
              tag: 'NAVIGATION',
            );
            return AppRoutes.dashboard;
          }
        }
        return null;

      case AppFlowReady:
        AppLogger.info(
          'NavigationService: Handling ready state at: $currentLocation',
          tag: 'NAVIGATION',
        );

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
          AppLogger.info(
            'NavigationService: Redirecting ready user to dashboard from invalid route: $currentLocation',
            tag: 'NAVIGATION',
          );
          return AppRoutes.dashboard;
        }

        AppLogger.info(
          'NavigationService: Ready user staying on valid route: $currentLocation',
          tag: 'NAVIGATION',
        );
        return null;

      case AppFlowError:
        final errorState = state as AppFlowError;
        AppLogger.error(
          'NavigationService: Handling error state: ${errorState.message} at: $currentLocation',
          tag: 'NAVIGATION',
        );
        if (currentLocation != '/error') {
          AppLogger.info(
            'NavigationService: Redirecting to error screen',
            tag: 'NAVIGATION',
          );
          return '/error';
        }
        return null;

      default:
        AppLogger.warning(
          'NavigationService: Unknown state type: ${state.runtimeType}',
          tag: 'NAVIGATION',
        );
        return null;
    }
  }

  /// Handle routing for unauthenticated users
  String? _handleUnauthenticatedState(String currentLocation) {
    AppLogger.info(
      'NavigationService: Handling unauthenticated state at: $currentLocation',
      tag: 'NAVIGATION',
    );

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
      AppLogger.info(
        'NavigationService: Redirecting from protected route $currentLocation to auth',
        tag: 'NAVIGATION',
      );
      return AppRoutes.auth;
    }

    AppLogger.info(
      'NavigationService: Staying on current route (not protected): $currentLocation',
      tag: 'NAVIGATION',
    );
    return null; // Stay on current route
  }

  /// Handle routing for authenticated but incomplete users
  String? _handleAuthenticatedState(
    AppFlowAuthenticated state,
    String currentLocation,
  ) {
    AppLogger.info(
      'NavigationService: Handling authenticated state - needsOnboarding: ${state.needsOnboarding}, needsProfileSetup: ${state.needsProfileSetup} at: $currentLocation',
      tag: 'NAVIGATION',
    );

    // If user needs onboarding, redirect to onboarding
    if (state.needsOnboarding) {
      if (currentLocation != AppRoutes.onboarding) {
        AppLogger.info(
          'NavigationService: Redirecting to onboarding (needs onboarding)',
          tag: 'NAVIGATION',
        );
        return AppRoutes.onboarding;
      }
      return null; // Already on onboarding
    }

    // If user needs profile setup, redirect to profile creation
    if (state.needsProfileSetup) {
      if (currentLocation != AppRoutes.profileCreation) {
        AppLogger.info(
          'NavigationService: Redirecting to profile creation (needs profile setup)',
          tag: 'NAVIGATION',
        );
        return AppRoutes.profileCreation;
      }
      return null; // Already on profile creation
    }

    // User is authenticated and complete, redirect to dashboard
    if (currentLocation != AppRoutes.dashboard) {
      AppLogger.info(
        'NavigationService: Redirecting to dashboard (authenticated and complete)',
        tag: 'NAVIGATION',
      );
      return AppRoutes.dashboard;
    }

    return null; // Already on dashboard
  }

  /// Handle routing for ready users
  String? _handleReadyState(String currentLocation) {
    AppLogger.info(
      'NavigationService: Handling ready state at: $currentLocation',
      tag: 'NAVIGATION',
    );

    // Ready users should be on dashboard or projects
    final allowedRoutes = [
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
    ];

    if (!allowedRoutes.contains(currentLocation)) {
      AppLogger.info(
        'NavigationService: Redirecting ready user to dashboard from: $currentLocation',
        tag: 'NAVIGATION',
      );
      return AppRoutes.dashboard;
    }

    AppLogger.info(
      'NavigationService: Ready user staying on current route: $currentLocation',
      tag: 'NAVIGATION',
    );
    return null; // Stay on current route
  }

  /// Handle routing for loading state
  String? _handleLoadingState(String currentLocation) {
    AppLogger.info(
      'NavigationService: Handling loading state at: $currentLocation',
      tag: 'NAVIGATION',
    );

    // During loading, stay on current route unless it's a protected route
    final protectedRoutes = [
      AppRoutes.onboarding,
      AppRoutes.profileCreation,
      AppRoutes.dashboard,
      AppRoutes.projects,
      AppRoutes.settings,
    ];

    if (protectedRoutes.contains(currentLocation)) {
      AppLogger.info(
        'NavigationService: Redirecting from protected route during loading to splash',
        tag: 'NAVIGATION',
      );
      return AppRoutes.splash;
    }

    return null; // Stay on current route
  }

  /// Handle routing for error state
  String? _handleErrorState(AppFlowError state, String currentLocation) {
    AppLogger.error(
      'NavigationService: Handling error state: ${state.message} at: $currentLocation',
      tag: 'NAVIGATION',
    );

    // On error, redirect to auth screen
    if (currentLocation != AppRoutes.auth) {
      AppLogger.info(
        'NavigationService: Redirecting to auth due to error',
        tag: 'NAVIGATION',
      );
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

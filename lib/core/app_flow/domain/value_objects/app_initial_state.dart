/// Simple initial states for app navigation
///
/// These states are used directly by the UI without complex mapping
enum AppInitialState {
  /// App is still loading (splash screen)
  splash,

  /// User needs to authenticate
  auth,

  /// User is authenticated but needs setup (onboarding/profile)
  setup,

  /// User is ready to use the app
  dashboard,

  /// App encountered an error during initialization
  error,
}

/// Extension for better debugging
extension AppInitialStateExtension on AppInitialState {
  String get displayName {
    switch (this) {
      case AppInitialState.splash:
        return 'Splash';
      case AppInitialState.auth:
        return 'Authentication';
      case AppInitialState.setup:
        return 'Setup';
      case AppInitialState.dashboard:
        return 'Dashboard';
      case AppInitialState.error:
        return 'Error';
    }
  }
}

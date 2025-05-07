import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/auth/presentation/pages/auth.dart';
import 'package:trackflow/features/home/presentation/pages/dashboard.dart';
import 'package:trackflow/features/onboarding/presentation/pages/launch_screen.dart';
import 'package:trackflow/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) async {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation == '/auth';
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isLaunchRoute = state.matchedLocation == '/';
        final isDashboardRoute = state.matchedLocation == '/dashboard';

        // Get onboarding status
        final prefs = await SharedPreferences.getInstance();
        final hasCompletedOnboarding =
            prefs.getBool('hasCompletedOnboarding') ?? false;
        final hasSeenLaunch = prefs.getBool('hasSeenLaunch') ?? false;

        // Handle launch screen
        if (!hasSeenLaunch) {
          await prefs.setBool('hasSeenLaunch', true);
          return '/';
        }

        // Handle authentication state
        if (authState is AuthAuthenticated) {
          // If user is authenticated and tries to access auth/onboarding/launch screens
          if (isAuthRoute || isOnboardingRoute || isLaunchRoute) {
            return '/dashboard';
          }
          return null;
        }

        // If user is not authenticated
        if (authState is AuthUnauthenticated) {
          // If user hasn't completed onboarding
          if (!hasCompletedOnboarding) {
            if (isAuthRoute || isDashboardRoute) {
              return '/onboarding';
            }
            return null;
          }

          // If user has completed onboarding but not authenticated
          if (isDashboardRoute) {
            return '/auth';
          }
          return null;
        }

        // For any other state (loading, error, etc.)
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LaunchScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      errorBuilder:
          (context, state) =>
              Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }
}

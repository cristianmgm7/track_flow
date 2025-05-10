import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/features/auth/presentation/pages/auth.dart';
import 'package:trackflow/features/home/presentation/pages/dashboard.dart';
import 'package:trackflow/features/onboarding/presentation/pages/launch_screen.dart';
import 'package:trackflow/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_form_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final onboardingBloc = context.read<OnboardingBloc>();
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) async {
        final authState = authBloc.state;
        final onboardingState = onboardingBloc.state;
        final isAuthRoute = state.matchedLocation == '/auth';
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isLaunchRoute = state.matchedLocation == '/';
        final isDashboardRoute = state.matchedLocation.startsWith('/dashboard');

        // Handle launch screen
        if (onboardingState is OnboardingChecked &&
            !onboardingState.hasSeenLaunch) {
          onboardingBloc.add(OnboardingMarkLaunchSeen());
          return '/';
        }

        // Handle authentication state
        if (authState is AuthAuthenticated) {
          if (isAuthRoute || isOnboardingRoute || isLaunchRoute) {
            return '/dashboard';
          }
          return null;
        }

        // If user is not authenticated
        if (authState is AuthUnauthenticated) {
          if (isDashboardRoute) {
            return '/auth';
          }
          return null;
        }

        // Check onboarding status
        if (onboardingState is OnboardingChecked) {
          if (!onboardingState.hasCompletedOnboarding &&
              (isAuthRoute || isDashboardRoute)) {
            return '/onboarding';
          }
        }

        // If auth state is loading, stay on current route
        if (authState is AuthLoading) {
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LaunchScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        ShellRoute(
          builder: (context, state, child) => DashboardScreen(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const ProjectListScreen(),
            ),
            GoRoute(
              path: '/dashboard/projects/new',
              builder: (context, state) => const ProjectFormScreen(),
            ),
            GoRoute(
              path: '/dashboard/projects/:id/edit',
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                return ProjectFormScreen(project: null);
              },
            ),
          ],
        ),
      ],
      errorBuilder:
          (context, state) =>
              Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

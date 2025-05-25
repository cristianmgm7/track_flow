import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:trackflow/features/auth/presentation/screens/auth_screen.dart';
import 'package:trackflow/features/home/presentation/screens/dashboard.dart';
import 'package:trackflow/features/navegation/presentation/widget/main_scafold.dart';
import 'package:trackflow/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:trackflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';
import 'package:trackflow/features/settings/presentation/pages/seetings_acount.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(AppFlowCubit appFlowCubit) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.dashboard,
      refreshListenable: GoRouterRefreshStream(appFlowCubit.stream),
      redirect: (context, state) {
        final status = appFlowCubit.state;
        switch (status) {
          case AppStatus.unknown:
            return AppRoutes.splash;
          case AppStatus.onboarding:
            return AppRoutes.onboarding;
          case AppStatus.unauthenticated:
            return AppRoutes.auth;
          case AppStatus.authenticated:
            // Only redirect to dashboard if not already in a valid route
            if (state.matchedLocation == AppRoutes.splash ||
                state.matchedLocation == AppRoutes.onboarding ||
                state.matchedLocation == AppRoutes.auth) {
              return AppRoutes.dashboard;
            }
            return null; // Allow navigation to any valid route
        }
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const AuthScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.projects,
              builder: (context, state) => const ProjectListScreen(),
            ),
            GoRoute(
              path: AppRoutes.notifications,
              builder:
                  (context, state) => const Scaffold(
                    body: Center(
                      child: Text("Notifications"),
                    ), // TODO: Add notifications screen
                  ),
            ),
            GoRoute(
              path: AppRoutes.settingsAccount,
              builder: (context, state) => const SettingsAccountScreen(),
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

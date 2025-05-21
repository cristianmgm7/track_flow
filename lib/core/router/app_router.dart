import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:trackflow/features/auth/presentation/screens/auth_screen.dart';
import 'package:trackflow/features/home/presentation/pages/dashboard.dart';
import 'package:trackflow/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:trackflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_form_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_details_screen.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static GoRouter router(BuildContext context) {
    final appFlowCubit = context.watch<AppFlowCubit>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(appFlowCubit.stream),
      redirect: (context, state) {
        final status = appFlowCubit.state;
        switch (status) {
          case AppStatus.unknown:
            return AppRoutes.splash;
          case AppStatus.onboarding:
            return AppRoutes.onboarding;
          case AppStatus.unauthenticated:
            return AppRoutes.welcome;
          case AppStatus.authenticated:
            return AppRoutes.dashboard;
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
          builder: (context, state, child) => DashboardScreen(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => ProjectListScreen(),
            ),
            GoRoute(
              path: AppRoutes.newProject,
              builder: (context, state) => ProjectFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.projectDetails,
              builder: (context, state) {
                final projectId = state.pathParameters['id']!;
                return ProjectDetailsScreen(projectId: projectId);
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

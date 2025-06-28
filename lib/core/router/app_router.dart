import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/audio_comments_screen.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:trackflow/features/auth/presentation/screens/auth_screen.dart';
import 'package:trackflow/features/home/presentation/screens/dashboard.dart';
import 'package:trackflow/features/magic_link/presentation/screens/magic_link_handler_screen.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/navegation/presentation/widget/main_scafold.dart';
import 'package:trackflow/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:trackflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:trackflow/features/project_detail/presentation/screens/project_details_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/settings/presentation/screens/settings_screen.dart';
import 'package:trackflow/features/user_profile/presentation/user_profile_screen.dart';
import 'package:trackflow/features/audio_cache/demo/cache_demo_screen.dart';
import 'package:trackflow/features/audio_cache/screens/storage_management_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.dashboard,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        if (authState is AuthInitial) return AppRoutes.splash;
        if (authState is OnboardingInitial) return AppRoutes.onboarding;
        if (authState is WelcomeScreenInitial) return AppRoutes.welcome;
        if (authState is AuthUnauthenticated) return AppRoutes.auth;
        if (authState is AuthAuthenticated &&
            (state.matchedLocation == AppRoutes.splash ||
                state.matchedLocation == AppRoutes.onboarding ||
                state.matchedLocation == AppRoutes.auth ||
                state.matchedLocation == AppRoutes.welcome)) {
          return AppRoutes.dashboard;
        }
        return null;
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
        GoRoute(
          path: AppRoutes.magicLink,
          builder:
              (context, state) => MagicLinkHandlerScreen(
                token: state.pathParameters['token'] ?? '',
              ),
        ),
        GoRoute(
          path: AppRoutes.audioComments,
          builder: (context, state) {
            // Puedes pasar los argumentos por extra o queryParams
            final args = state.extra as AudioCommentsScreenArgs;
            return AudioCommentsScreen(
              projectId: args.projectId,
              track: args.track,
              collaborators: args.collaborators,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.manageCollaborators,
          builder:
              (context, state) =>
                  ManageCollaboratorsScreen(project: state.extra as Project),
        ),
        GoRoute(
          path: AppRoutes.artistProfile,
          builder: (context, state) {
            final userId = state.pathParameters['id']!;
            return UserProfileScreen(userId: UserId.fromUniqueString(userId));
          },
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
                    body: Center(child: Text("Notifications")),
                  ),
            ),
            GoRoute(
              path: AppRoutes.projectDetails,
              builder:
                  (context, state) =>
                      ProjectDetailsScreen(project: state.extra as Project),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.manageCollaborators,
              builder:
                  (context, state) => ManageCollaboratorsScreen(
                    project: state.extra as Project,
                  ),
            ),
            GoRoute(
              path: AppRoutes.cacheDemo,
              builder: (context, state) => const CacheDemoScreen(),
            ),
            GoRoute(
              path: '/storage-management',
              builder: (context, state) => const StorageManagementScreen(),
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

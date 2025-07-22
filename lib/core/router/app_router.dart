import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/navigation_service.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/app_audio_comments_screen.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:trackflow/features/auth/presentation/screens/new_auth_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';
import 'package:trackflow/features/magic_link/presentation/screens/magic_link_handler_screen.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/navegation/presentation/widget/main_scaffold.dart';
import 'package:trackflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/screens/project_details_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/settings/presentation/screens/settings_screen.dart';
import 'package:trackflow/features/user_profile/presentation/hero_user_profile_screen.dart';
import 'package:trackflow/features/user_profile/presentation/screens/profile_creation_screen.dart';
import 'package:trackflow/features/audio_cache/screens/cache_demo_screen.dart';
import 'package:trackflow/features/audio_cache/screens/storage_management_screen.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/core/session_manager/presentation/bloc/app_flow_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(AppFlowBloc appFlowBloc) {
    final navigationService = sl<NavigationService>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: navigationService.getInitialRoute(),
      refreshListenable: GoRouterRefreshStream(appFlowBloc.stream),
      redirect: (context, state) {
        final flowState = appFlowBloc.state;

        // Special handling for loading state to trigger initial check
        if (flowState is AppFlowLoading &&
            state.matchedLocation == AppRoutes.splash) {
          appFlowBloc.add(CheckAppFlow());
        }

        // Use NavigationService for clean routing logic
        return navigationService.getRouteForFlowState(
          flowState,
          state.matchedLocation,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const NewAuthScreen(),
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
            final args = state.extra as AudioCommentsScreenArgs;
            return BlocProvider<TrackCacheBloc>(
              create: (context) => sl<TrackCacheBloc>(),
              child: AppAudioCommentsScreen(
                projectId: args.projectId,
                track: args.track,
              ),
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
            return HeroUserProfileScreen(
              userId: UserId.fromUniqueString(userId),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.userProfile,
          builder: (context, state) {
            // Get current user ID from auth state or context
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              return HeroUserProfileScreen(userId: authState.user.id);
            }
            // Fallback - this shouldn't happen in normal flow
            return const Scaffold(
              body: Center(child: Text('User not authenticated')),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileCreation,
          builder: (context, state) => const ProfileCreationScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder:
              (context, state, child) => MultiBlocProvider(
                providers: [
                  BlocProvider<ProjectsBloc>(create: (_) => sl<ProjectsBloc>()),
                  BlocProvider<ProjectDetailBloc>(
                    create: (_) => sl<ProjectDetailBloc>(),
                  ),
                  BlocProvider<AudioContextBloc>(
                    create: (_) => sl<AudioContextBloc>(),
                  ),
                ],
                child: MainScaffold(child: child),
              ),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const ProjectListScreen(),
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
  GoRouterRefreshStream(Stream<dynamic> appFlowStream) {
    notifyListeners();

    // Listen to app flow stream and notify when it changes
    _appFlowSubscription = appFlowStream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _appFlowSubscription;

  @override
  void dispose() {
    _appFlowSubscription.cancel();
    super.dispose();
  }
}

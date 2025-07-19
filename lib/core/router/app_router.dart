import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/di/injection.dart';
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
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/screens/project_details_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/settings/presentation/screens/settings_screen.dart';
import 'package:trackflow/features/user_profile/presentation/hero_user_profile_screen.dart';
import 'package:trackflow/features/user_profile/presentation/screens/profile_creation_screen.dart';
import 'package:trackflow/features/audio_cache/screens/cache_demo_screen.dart';
import 'package:trackflow/features/audio_cache/screens/storage_management_screen.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(
    AuthBloc authBloc,
    OnboardingBloc onboardingBloc,
    UserProfileBloc userProfileBloc,
  ) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(
        authBloc.stream,
        onboardingBloc.stream,
        userProfileBloc.stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final onboardingState = context.read<OnboardingBloc>().state;
        final profileState = context.read<UserProfileBloc>().state;

        // Handle unauthenticated users
        if (authState is AuthUnauthenticated) {
          if (state.matchedLocation == AppRoutes.splash ||
              state.matchedLocation == AppRoutes.onboarding ||
              state.matchedLocation == AppRoutes.auth ||
              state.matchedLocation == AppRoutes.profileCreation ||
              state.matchedLocation == AppRoutes.dashboard ||
              state.matchedLocation == AppRoutes.projects ||
              state.matchedLocation == AppRoutes.settings) {
            return AppRoutes.auth;
          }
        }

        // Handle authenticated users
        if (authState is AuthAuthenticated) {
          // First: Check if onboarding is needed (for new users)
          if (onboardingState is OnboardingIncomplete) {
            return AppRoutes.onboarding;
          }

          // Second: Check if profile creation is needed
          if (onboardingState is OnboardingCompleted) {
            // Don't redirect to profile creation if profile is still loading or initial
            if (profileState is UserProfileLoading ||
                profileState is UserProfileInitial) {
              return null; // Stay on current route while loading
            }

            if (profileState is ProfileIncomplete ||
                profileState is UserProfileError) {
              return AppRoutes.profileCreation;
            }
          }

          // Third: If everything is complete, go to dashboard
          if (onboardingState is OnboardingCompleted &&
              (profileState is ProfileComplete ||
                  profileState is UserProfileLoaded)) {
            if (state.matchedLocation == AppRoutes.splash ||
                state.matchedLocation == AppRoutes.onboarding ||
                state.matchedLocation == AppRoutes.auth ||
                state.matchedLocation == AppRoutes.profileCreation) {
              return AppRoutes.dashboard;
            }
          }
        }

        return null;
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
  GoRouterRefreshStream(
    Stream<dynamic> authStream,
    Stream<dynamic> onboardingStream,
    Stream<dynamic> profileStream,
  ) {
    notifyListeners();

    // Listen to all streams and notify when any changes
    _authSubscription = authStream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );

    _onboardingSubscription = onboardingStream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );

    _profileSubscription = profileStream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _authSubscription;
  late final StreamSubscription<dynamic> _onboardingSubscription;
  late final StreamSubscription<dynamic> _profileSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    _onboardingSubscription.cancel();
    _profileSubscription.cancel();
    super.dispose();
  }
}

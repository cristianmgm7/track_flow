import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/app_audio_comments_screen.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:trackflow/features/auth/presentation/screens/new_auth_screen.dart';
import 'package:trackflow/features/projects/presentation/screens/project_list_screen.dart';
import 'package:trackflow/features/magic_link/presentation/screens/magic_link_handler_screen.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/navegation/presentation/widget/main_scaffold.dart';
import 'package:trackflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/screens/project_details_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/settings/presentation/screens/settings_screen.dart';
// import 'package:trackflow/features/user_profile/presentation/hero_user_profile_screen.dart';
import 'package:trackflow/features/user_profile/presentation/screens/collaborator_profile_screen.dart';
import 'package:trackflow/features/user_profile/presentation/screens/profile_creation_screen.dart';
import 'package:trackflow/features/user_profile/presentation/screens/current_user_profile_screen.dart';
import 'package:trackflow/features/cache_management/presentation/screens/cache_management_screen.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart';
import 'package:trackflow/core/notifications/presentation/screens/notification_center_screen.dart';
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static GoRouter router(AppFlowBloc appFlowBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(appFlowBloc.stream),
      redirect: (context, state) {
        final flowState = appFlowBloc.state;
        final currentLocation = state.matchedLocation;

        // Handle loading state
        if (flowState is AppFlowLoading) {
          if (currentLocation != AppRoutes.splash) {
            return AppRoutes.splash;
          }
          return null;
        }

        // Handle unauthenticated state
        if (flowState is AppFlowUnauthenticated) {
          if (currentLocation != AppRoutes.auth) {
            return AppRoutes.auth;
          }
          return null;
        }

        // Handle authenticated state with setup requirements
        if (flowState is AppFlowAuthenticated) {
          if (flowState.needsOnboarding &&
              currentLocation != AppRoutes.onboarding) {
            return AppRoutes.onboarding;
          }
          if (flowState.needsProfileSetup &&
              currentLocation != AppRoutes.profileCreation) {
            return AppRoutes.profileCreation;
          }
          if (!flowState.needsOnboarding &&
              !flowState.needsProfileSetup &&
              currentLocation != AppRoutes.dashboard) {
            return AppRoutes.dashboard;
          }
          return null;
        }

        // Handle ready state - allow access to main app routes
        if (flowState is AppFlowReady) {
          // When app is ready, redirect to dashboard if not on a valid route
          // Valid routes are: dashboard, projects, settings, notifications, user profile, collaborator profile, and any project details
          if (currentLocation == AppRoutes.dashboard ||
              currentLocation == AppRoutes.projects ||
              currentLocation == AppRoutes.settings ||
              currentLocation == AppRoutes.notifications ||
              currentLocation == AppRoutes.userProfile ||
              currentLocation == AppRoutes.manageCollaborators ||
              currentLocation == AppRoutes.audioComments ||
              currentLocation == AppRoutes.cacheManagement ||
              currentLocation.startsWith('/artistprofile/') ||
              currentLocation.startsWith('/projects/')) {
            return null; // Allow navigation
          }

          // Redirect to dashboard for any other route
          return AppRoutes.dashboard;
        }

        // Handle error state
        if (flowState is AppFlowError) {
          if (currentLocation != AppRoutes.auth) {
            return AppRoutes.auth;
          }
          return null;
        }

        return null;
      },
      routes: [
        // Setup routes (outside shell)
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
          path: AppRoutes.profileCreation,
          builder: (context, state) => const ProfileCreationScreen(),
        ),

        // Standalone cache management (outside shell: no mini player/nav)
        GoRoute(
          path: AppRoutes.cacheManagement,
          builder: (context, state) => const CacheManagementScreen(),
        ),

        // Standalone routes (outside shell)
        GoRoute(
          path: AppRoutes.audioComments,
          builder: (context, state) {
            final args = state.extra as AudioCommentsScreenArgs;
            return MultiBlocProvider(
              providers: [
                BlocProvider<TrackCacheBloc>(
                  create: (context) => sl<TrackCacheBloc>(),
                ),
                // Scope AudioCommentBloc to this screen to avoid cross-track leakage
                BlocProvider<AudioCommentBloc>(
                  create: (context) => sl<AudioCommentBloc>(),
                ),
              ],
              child: AppAudioCommentsScreen(
                projectId: args.projectId,
                track: args.track,
                versionId: args.versionId,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.artistProfile,
          builder: (context, state) {
            final userId = state.pathParameters['id']!;
            return BlocProvider<UserProfileBloc>(
              create: (_) => sl<UserProfileBloc>(),
              child: CollaboratorProfileScreen(
                userId: UserId.fromUniqueString(userId),
              ),
            );
          },
        ),

        // Main app shell route
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder:
              (context, state, child) => MultiBlocProvider(
                providers: [
                  BlocProvider<ProjectsBloc>(create: (_) => sl<ProjectsBloc>()),
                  BlocProvider<AudioContextBloc>(
                    create: (_) => sl<AudioContextBloc>(),
                  ),
                  BlocProvider<NotificationWatcherBloc>(
                    create: (_) => sl<NotificationWatcherBloc>(),
                  ),
                  BlocProvider<ProjectInvitationWatcherBloc>(
                    create: (_) => sl<ProjectInvitationWatcherBloc>(),
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
              builder: (context, state) => const NotificationCenterScreen(),
            ),
            GoRoute(
              path: AppRoutes.projectDetails,
              builder: (context, state) {
                final project = state.extra as Project;
                return BlocProvider<ProjectDetailBloc>(
                  create: (_) => sl<ProjectDetailBloc>(),
                  child: ProjectDetailsScreen(project: project),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.manageCollaborators,
              builder: (context, state) {
                final project = state.extra as Project;
                return BlocProvider<ManageCollaboratorsBloc>(
                  create:
                      (_) =>
                          sl<ManageCollaboratorsBloc>()
                            ..add(WatchCollaborators(projectId: project.id)),
                  child: ManageCollaboratorsScreen(project: project),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.userProfile,
              builder: (context, state) => const CurrentUserProfileScreen(),
            ),
            // Cache demo route removed
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
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

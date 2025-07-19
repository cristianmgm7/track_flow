import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/widgets/miniplayer_components/mini_audio_player.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/bottom_nav.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // Initialize user profile watching
    context.read<UserProfileBloc>().add(WatchUserProfile(userId: null));
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Refresh UserProfileBloc when auth state changes
        if (authState is AuthAuthenticated) {
          // User signed in, refresh profile watching
          context.read<UserProfileBloc>().add(WatchUserProfile(userId: null));
        } else if (authState is AuthUnauthenticated) {
          // User signed out, clear profile state
          context.read<UserProfileBloc>().add(ClearUserProfile());
        }
      },
      child: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          // Handle profile state changes if needed
          if (state is UserProfileSaved) {
            // Profile was successfully created/updated
            // The router will handle navigation based on profile completeness
          }
        },
        child: AppScaffold(
          body: Column(
            children: [
              Expanded(child: widget.child),
              BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  // Only show mini player when there's active playback
                  if (state is AudioPlayerPlaying ||
                      state is AudioPlayerPaused ||
                      state is AudioPlayerBuffering) {
                    return const MiniAudioPlayer();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: currentTab.index,
            onTap: (index) {
              final tab = AppTab.values[index];
              context.read<NavigationCubit>().setTab(tab);
              switch (tab) {
                case AppTab.projects:
                  context.go(AppRoutes.projects);
                  break;
                case AppTab.myMusic:
                  // TODO: Create a dedicated route for playlists
                  // For now, we can navigate to a placeholder or the first project
                  context.go(AppRoutes.projects);
                  break;
                case AppTab.settings:
                  context.go(AppRoutes.settings);
                  break;
              }
            },
            items: const [
              AppBottomNavigationItem(
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'Projects',
              ),
              AppBottomNavigationItem(
                icon: Icons.music_note_outlined,
                activeIcon: Icons.music_note,
                label: 'My Music',
              ),
              AppBottomNavigationItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

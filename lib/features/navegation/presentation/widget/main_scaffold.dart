import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/widgets/miniplayer_components/mini_audio_player.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/bottom_nav.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';

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
    // Profile watching is handled by CheckProfileCompleteness in my_app.dart
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return BlocListener<AppFlowBloc, AppFlowState>(
      listener: (context, appFlowState) {
        // ✅ CRÍTICO: Limpiar estado cuando el usuario no está autenticado
        if (appFlowState is AppFlowUnauthenticated) {
          AppLogger.info(
            'MainScaffold: User became unauthenticated, clearing all user data',
            tag: 'MAIN_SCAFFOLD',
          );

          // Limpiar CurrentUserBloc
          context.read<CurrentUserBloc>().add(ClearCurrentUserProfile());
        }
      },
      child: BlocListener<CurrentUserBloc, CurrentUserState>(
        listener: (context, state) {
          // Handle profile state changes if needed
          if (state is CurrentUserSaved) {
            // Profile was successfully created/updated
            // The router will handle navigation based on profile completeness
          }
        },
        child: AppScaffold(
          topSafeArea: false,
          body: Column(
            children: [
              Expanded(child: widget.child),
              BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  // Only show mini player when there's active playback
                  if (state is AudioPlayerPlaying ||
                      state is AudioPlayerPaused ||
                      state is AudioPlayerBuffering) {
                    return const MiniAudioPlayer(
                      config: MiniAudioPlayerConfig(
                        backgroundColor: AppColors.grey400,
                      ),
                    );
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
                case AppTab.dashboard:
                  context.go(AppRoutes.dashboard);
                  break;
                case AppTab.voiceMemos:
                  context.go(AppRoutes.voiceMemos);
                  break;
                case AppTab.notifications:
                  context.go(AppRoutes.notifications);
                  break;
                case AppTab.settings:
                  context.go(AppRoutes.settings);
                  break;
              }
            },
            items: const [
              AppBottomNavigationItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
              ),
              AppBottomNavigationItem(
                icon: Icons.mic_outlined,
                activeIcon: Icons.mic,
                label: 'Voice Memos',
              ),
              AppBottomNavigationItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Notifications',
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit_state.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/mini_audio_player.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit.dart';

import 'package:trackflow/core/router/app_routes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return Scaffold(
      body: Stack(
        children: [
          child,
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              if (state.visualContext == PlayerVisualContext.miniPlayer &&
                  state is AudioPlayerActiveState) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: MiniAudioPlayer(
                    state: state,
                    track: state.track,
                    collaborator: state.collaborator,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color.fromARGB(95, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: BlocBuilder<FabContextCubit, FabContextState>(
            builder: (context, fabState) {
              final fabVisible = fabState.visible;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // --- Home Button ---
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      context.read<FabContextCubit>().hide();
                      context.read<NavigationCubit>().setTab(AppTab.dashboard);
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.dashboard);
                    },
                    color:
                        currentTab == AppTab.dashboard
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                  ),
                  // --- Projects Button ---
                  IconButton(
                    icon: const Icon(Icons.folder),
                    onPressed: () {
                      context.read<NavigationCubit>().setTab(AppTab.projects);
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.projects);
                    },
                    color:
                        currentTab == AppTab.projects
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                  ),
                  if (fabVisible) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 56,
                        width: 56,
                        child: FloatingActionButton(
                          key: ValueKey(fabState.icon),
                          heroTag: 'main-fab',
                          onPressed: fabState.onPressed,
                          tooltip: fabState.tooltip,
                          child: Icon(fabState.icon),
                        ),
                      ),
                    ),
                  ],
                  // --- Notifications Button ---
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      context.read<FabContextCubit>().hide();
                      context.read<NavigationCubit>().setTab(
                        AppTab.notifications,
                      );
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.notifications);
                    },
                    color:
                        currentTab == AppTab.notifications
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                  ),
                  // --- Settings Button ---
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      context.read<FabContextCubit>().hide();
                      context.read<NavigationCubit>().setTab(AppTab.settings);
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.settings);
                    },
                    color:
                        currentTab == AppTab.settings
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

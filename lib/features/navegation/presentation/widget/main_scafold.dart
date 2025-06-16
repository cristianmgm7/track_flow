import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/mini_audio_player.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:trackflow/features/navegation/presentation/widget/fab_context_cubit.dart';

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
              if (state.visualContext == PlayerVisualContext.miniPlayer) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: MiniAudioPlayer(state: state),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        // Sin notch, el FAB será un botón de barra de navegación
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      context.read<NavigationCubit>().setTab(AppTab.dashboard);
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.dashboard);
                    },
                    color:
                        currentTab == AppTab.dashboard
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
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
                            : null,
                  ),
                ],
              ),
            ),
            // FAB como botón de barra de navegación
            BlocBuilder<FabContextCubit, FabContextState>(
              builder: (context, fabState) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child:
                      fabState.visible
                          ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
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
                          )
                          : const SizedBox(width: 56),
                );
              },
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
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
                            : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      context.read<NavigationCubit>().setTab(AppTab.settings);
                      context.read<AudioPlayerBloc>().add(
                        ChangeVisualContext(PlayerVisualContext.miniPlayer),
                      );
                      context.go(AppRoutes.settings);
                    },
                    color:
                        currentTab == AppTab.settings
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/features/navegation/presentation/widget/audio_player_sheet.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:trackflow/core/router/app_routes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            builder: (context, state) {
              if (state is AudioPlayerActiveState &&
                  state.visualContext == PlayerVisualContext.miniPlayer) {
                return const AudioPlayerSheet(mode: PlayerViewMode.mini);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- Home Button ---
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
              // --- Notifications Button ---
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  context.read<NavigationCubit>().setTab(AppTab.notifications);
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
          ),
        ),
      ),
    );
  }
}

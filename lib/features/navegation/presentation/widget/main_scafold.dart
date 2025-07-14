import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/widgets/miniplayer_components/mini_audio_player.dart';
import 'package:trackflow/core/router/app_routes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    if (state is AudioPlayerSessionState) {
                      return const MiniAudioPlayer();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'My Music',
          ),
        ],
      ),
    );
  }
}

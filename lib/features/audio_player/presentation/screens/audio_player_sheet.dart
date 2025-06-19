import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/screens/audio_track_screen.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import '../widgets/mini_audioplayer.dart';

// different player views
enum PlayerViewMode { mini, expanded }

class AudioPlayerSheet extends StatelessWidget {
  final PlayerViewMode mode;
  const AudioPlayerSheet({super.key, required this.mode});

  void _showExpandedPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return BlocProvider.value(
                value: context.read<AudioPlayerBloc>(),
                child: AudioPlayerScreen(scrollController: scrollController),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        if (mode == PlayerViewMode.mini) {
          return MiniAudioPlayer(onExpand: () => _showExpandedPlayer(context));
        } else {
          return AudioPlayerScreen(scrollController: null);
        }
      },
    );
  }
}

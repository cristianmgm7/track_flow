import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/screens/audio_player_screen.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import '../widgets/mini_audioplayer.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

// different player views
enum PlayerViewMode { mini, expanded }

class AudioPlayerSheet extends StatelessWidget {
  final PlayerViewMode mode;
  final ProjectId projectId;
  final List<UserProfile> collaborators;
  const AudioPlayerSheet({
    super.key,
    required this.mode,
    required this.projectId,
    required this.collaborators,
  });

  void _showExpandedPlayer(BuildContext context, AudioTrack track) {
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
                child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    if (state is! AudioPlayerActiveState)
                      return const SizedBox.shrink();
                    return AudioPlayerScreen(
                      scrollController: scrollController,
                      projectId: projectId,
                      track: state.track,
                      collaborators: collaborators,
                    );
                  },
                ),
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
          return MiniAudioPlayer(
            onExpand: () => _showExpandedPlayer(context, state.track),
          );
        } else {
          return AudioPlayerScreen(
            scrollController: null,
            projectId: projectId,
            track: state.track,
            collaborators: collaborators,
          );
        }
      },
    );
  }
}

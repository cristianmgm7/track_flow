import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/components/pro_audio_player.dart';
import 'package:trackflow/features/audio_player/presentation/components/comments_for_audio_player.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class AudioPlayerScreen extends StatelessWidget {
  final ScrollController? scrollController;
  final ProjectId projectId;
  final AudioTrack track;
  final List<UserProfile> collaborators;

  const AudioPlayerScreen({
    super.key,
    this.scrollController,
    required this.projectId,
    required this.track,
    required this.collaborators,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // PRO AUDIO PLAYER
                ProAudioPlayer(scrollController: scrollController),
                const SizedBox(height: 16),
                Expanded(
                  child: CommentsForAudioPlayer(
                    projectId: projectId,
                    track: track,
                    collaborators: collaborators,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

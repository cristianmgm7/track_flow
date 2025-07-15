import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/playlist/presentation/utils/playlist_utils.dart';

class PlaylistStatusWidget extends StatelessWidget {
  final Playlist playlist;

  const PlaylistStatusWidget({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final player = context.read<AudioPlayerBloc>();
        final session = player.currentSession;
        final isPlayingFromThisPlaylist = playerState is AudioPlayerSessionState &&
            session.queue.isNotEmpty &&
            PlaylistUtils.isPlayingFromPlaylist(
              session.queue.sources.map((s) => s.metadata.id.value).toList(),
              playlist,
            );

        if (!isPlayingFromThisPlaylist) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Playing from this playlist • Track ${session.queue.currentIndex + 1} of ${session.queue.length}',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
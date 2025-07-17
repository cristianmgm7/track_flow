import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/playlist/presentation/utils/playlist_utils.dart';
import 'package:trackflow/features/playlist/presentation/widgets/buttons/play_pause_button.dart';
import 'package:trackflow/features/playlist/presentation/widgets/buttons/shuffle_button.dart';
import 'package:trackflow/features/playlist/presentation/widgets/buttons/repeat_button.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/widgets/playlist_cache_icon.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class PlaylistControlsWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;

  const PlaylistControlsWidget({
    super.key,
    required this.playlist,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final player = context.read<AudioPlayerBloc>();
        final session = player.currentSession;
        final isPlayingFromThisPlaylist =
            playerState is AudioPlayerSessionState &&
            session.queue.isNotEmpty &&
            PlaylistUtils.isPlayingFromPlaylist(
              session.queue.sources.map((s) => s.metadata.id.value).toList(),
              playlist,
            );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShuffleButton(
              isEnabled: session.queue.shuffleEnabled,
              onPressed: () => player.add(ToggleShuffleRequested()),
            ),
            const SizedBox(width: 8),
            RepeatButton(
              mode: session.repeatMode,
              onPressed: () => player.add(ToggleRepeatModeRequested()),
            ),
            const SizedBox(width: 8),
            PlaylistCacheIcon(
              playlistId: playlist.id.value,
              trackIds: playlist.trackIds,
              size: 28.0,
            ),
            const SizedBox(width: 8),
            PlayPauseButton(
              isPlaying:
                  isPlayingFromThisPlaylist &&
                  playerState is AudioPlayerPlaying,
              isBuffering:
                  isPlayingFromThisPlaylist &&
                  playerState is AudioPlayerBuffering,
              onPressed: () {
                if (isPlayingFromThisPlaylist &&
                    playerState is AudioPlayerPlaying) {
                  player.add(PauseAudioRequested());
                } else {
                  player.add(PlayPlaylistRequested(tracks: tracks));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

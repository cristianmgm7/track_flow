import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';

class PlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final bool showPlayAll;

  const PlaylistWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.showPlayAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(playlist.name, style: Theme.of(context).textTheme.titleLarge),
            if (showPlayAll)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play All'),
                onPressed: () {
                  context.read<AudioPlayerBloc>().add(
                    PlayPlaylistRequested(playlist),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return ListTile(
              leading: Icon(Icons.music_note),
              title: Text(track.name),
              subtitle: Text(_formatDuration(track.duration)),
              trailing: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  final isCurrent =
                      state is AudioPlayerActiveState &&
                      state.track.id == track.id;
                  return isCurrent
                      ? Icon(
                        Icons.equalizer,
                        color: Theme.of(context).primaryColor,
                      )
                      : null;
                },
              ),
              onTap: () {
                // Reproduce la playlist desde este track
                final reordered = [
                  ...tracks.sublist(index),
                  ...tracks.sublist(0, index),
                ];
                final reorderedPlaylist = playlist.copyWith(
                  trackIds: reordered.map((t) => t.id.value).toList(),
                );
                context.read<AudioPlayerBloc>().add(
                  PlayPlaylistRequested(reorderedPlaylist),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return '$minutes:$seconds';
}

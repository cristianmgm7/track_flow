import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/bloc/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class PlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final Map<String, UserProfile>? collaboratorsByTrackId;
  final bool showPlayAll;
  final String? projectId;

  const PlaylistWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.collaboratorsByTrackId,
    this.showPlayAll = true,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play All'),
          onPressed: () {
            context.read<AudioPlayerBloc>().add(
              PlayPlaylistRequested(playlist),
            );
          },
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final track = tracks[index];
            final uploader = collaboratorsByTrackId?[track.id.value];
            return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, state) {
                final isCurrent =
                    state is AudioPlayerActiveState &&
                    state.track.id == track.id;
                return Container(
                  color:
                      isCurrent
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                  child: TrackComponent(
                    track: track,
                    uploader: uploader,
                    projectId:
                        projectId != null
                            ? ProjectId.fromUniqueString(projectId!)
                            : track.projectId,
                    onPlay: () {
                      context.read<AudioPlayerBloc>().add(
                        PlayPlaylistRequested(playlist, startIndex: index),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

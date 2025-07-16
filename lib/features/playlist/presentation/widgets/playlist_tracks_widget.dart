import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class PlaylistTracksWidget extends StatelessWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final Map<String, UserProfile>? collaboratorsByTrackId;
  final String? projectId;

  const PlaylistTracksWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.collaboratorsByTrackId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];

        return TrackComponent(
          track: track,
          projectId:
              projectId != null
                  ? ProjectId.fromUniqueString(projectId!)
                  : track.projectId,
          onPlay: () {
            context.read<AudioPlayerBloc>().add(
              PlayPlaylistRequested(tracks: tracks, startIndex: index),
            );
          },
        );
      },
    );
  }
}

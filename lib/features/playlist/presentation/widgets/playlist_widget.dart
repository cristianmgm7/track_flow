import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_controls_widget.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_status_widget.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_tracks_widget.dart';

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
        PlaylistControlsWidget(playlist: playlist),
        PlaylistStatusWidget(playlist: playlist),
        const SizedBox(height: 8),
        BlocProvider(
          create: (context) => sl<PlaylistCacheBloc>(),
          child: PlaylistTracksWidget(
            playlist: playlist,
            tracks: tracks,
            collaboratorsByTrackId: collaboratorsByTrackId,
            projectId: projectId,
          ),
        ),
      ],
    );
  }
}

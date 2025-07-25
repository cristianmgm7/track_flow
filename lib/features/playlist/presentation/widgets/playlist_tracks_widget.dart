import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/features/ui/track/track_card.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class PlaylistTracksWidget extends StatefulWidget {
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
  State<PlaylistTracksWidget> createState() => _PlaylistTracksWidgetState();
}

class _PlaylistTracksWidgetState extends State<PlaylistTracksWidget> {
  bool _isUploadingTrack = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioTrackBloc, AudioTrackState>(
      listener: (context, state) {
        if (state is AudioTrackUploadLoading) {
          setState(() => _isUploadingTrack = true);
        } else if (state is AudioTrackUploadSuccess || state is AudioTrackError) {
          setState(() => _isUploadingTrack = false);
        }
      },
      child: AppTrackList(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        tracks: [
          ...widget.tracks.map((track) {
            final index = widget.tracks.indexOf(track);
            return TrackComponent(
              track: track,
              projectId:
                  widget.projectId != null
                      ? ProjectId.fromUniqueString(widget.projectId!)
                      : track.projectId,
              onPlay: () {
                context.read<AudioPlayerBloc>().add(
                  PlayPlaylistRequested(tracks: widget.tracks, startIndex: index),
                );
              },
            );
          }),
          if (_isUploadingTrack) AppTrackShimmerCard(),
        ],
      ),
    );
  }
}

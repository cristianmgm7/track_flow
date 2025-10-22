import 'package:flutter/material.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/ui/menus/app_popup_menu.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_sort.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';

class PlaylistControlsWidget extends StatefulWidget {
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final VoidCallback? onMenuOpened;
  final VoidCallback? onMenuClosed;

  const PlaylistControlsWidget({
    super.key,
    required this.playlist,
    required this.tracks,
    this.onMenuOpened,
    this.onMenuClosed,
  });

  @override
  State<PlaylistControlsWidget> createState() => _PlaylistControlsWidgetState();
}

class _PlaylistControlsWidgetState extends State<PlaylistControlsWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 8),
            const SizedBox(width: 8),
            // Track sort menu
            BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
              builder: (context, detailState) {
                return AppPopupMenuButton<AudioTrackSort>(
                  tooltip: 'Sort tracks',
                  onOpened: widget.onMenuOpened,
                  onClosed: widget.onMenuClosed,
                  items: const [
                    AppPopupMenuItem(
                      value: AudioTrackSort.newest,
                      label: 'Newest',
                      icon: Icons.schedule_rounded,
                    ),
                    AppPopupMenuItem(
                      value: AudioTrackSort.oldest,
                      label: 'Oldest',
                      icon: Icons.history_toggle_off_rounded,
                    ),
                    AppPopupMenuItem(
                      value: AudioTrackSort.nameAsc,
                      label: 'Name A–Z',
                      icon: Icons.sort_by_alpha_rounded,
                    ),
                    AppPopupMenuItem(
                      value: AudioTrackSort.nameDesc,
                      label: 'Name Z–A',
                      icon: Icons.sort_rounded,
                    ),
                    AppPopupMenuItem(
                      value: AudioTrackSort.durationAsc,
                      label: 'Duration ↑',
                      icon: Icons.timer_outlined,
                    ),
                    AppPopupMenuItem(
                      value: AudioTrackSort.durationDesc,
                      label: 'Duration ↓',
                      icon: Icons.timelapse_rounded,
                    ),
                  ],
                  onSelected: (sort) {
                    context.read<ProjectDetailBloc>().add(
                      ChangeTrackSort(sort),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            
          ],
        );
      },
    );
  }
}

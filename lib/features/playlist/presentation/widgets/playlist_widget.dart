import 'package:flutter/material.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_controls_widget.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_status_widget.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_tracks_widget.dart';
import 'package:trackflow/features/ui/menus/app_popup_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class PlaylistWidget extends StatefulWidget {
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
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final projectIdForWatch =
        widget.projectId != null
            ? ProjectId.fromUniqueString(widget.projectId!)
            : (widget.tracks.isNotEmpty ? widget.tracks.first.projectId : null);

    final content = BlocProvider(
      create:
          (_) =>
              sl<PlaylistCubit>()..watch(
                projectIdForWatch ??
                    ProjectId.fromUniqueString('unknown-project'),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaylistControlsWidget(
            playlist: widget.playlist,
            tracks: widget.tracks,
            onMenuOpened: () => setState(() => _isMenuOpen = true),
            onMenuClosed: () => setState(() => _isMenuOpen = false),
          ),
          PlaylistStatusWidget(playlist: widget.playlist),
          const SizedBox(height: 8),
          PlaylistTracksWidget(
            playlist: widget.playlist,
            tracks: widget.tracks,
            collaboratorsByTrackId: widget.collaboratorsByTrackId,
            projectId: widget.projectId,
          ),
        ],
      ),
    );

    return Stack(
      children: [
        content,
        if (_isMenuOpen)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AppBlurBackdrop(child: SizedBox.shrink()),
            ),
          ),
      ],
    );
  }
}

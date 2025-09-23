import 'package:flutter/material.dart';
// duplicate import removed
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
import 'package:trackflow/features/project_detail/presentation/components/upload_track_button.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/up_load_track_form.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:trackflow/features/playlist/presentation/cubit/playlist_state.dart';

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
        } else if (state is AudioTrackUploadSuccess ||
            state is AudioTrackError) {
          setState(() => _isUploadingTrack = false);
        }
      },
      child: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          final items = state.items;
          final tracksForPlayer = state.tracks;
          return AppTrackList(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            tracks: [
              ...List.generate(items.length, (index) {
                final vm = items[index];
                return TrackComponent(
                  vm: vm,
                  projectId:
                      widget.projectId != null
                          ? ProjectId.fromUniqueString(widget.projectId!)
                          : vm.track.projectId,
                  onPlay: () {
                    context.read<AudioPlayerBloc>().add(
                      PlayPlaylistRequested(
                        tracks: tracksForPlayer,
                        startIndex: index,
                      ),
                    );
                  },
                );
              }),
              if (widget.projectId != null)
                UploadTrackButton(
                  projectId: ProjectId.fromUniqueString(widget.projectId!),
                  onTap:
                      _isUploadingTrack
                          ? null
                          : () => _showUploadTrackForm(context),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showUploadTrackForm(BuildContext context) {
    final projectDetailBloc = context.read<ProjectDetailBloc>();
    showAppFormSheet(
      context: context,
      title: 'Upload Track',
      useRootNavigator: true,
      child: BlocProvider.value(
        value: projectDetailBloc,
        child: UploadTrackForm(project: projectDetailBloc.state.project!),
      ),
    );
  }
}

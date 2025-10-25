import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/playlist/presentation/models/track_row_view_model.dart';

class ProjectDetailTracksComponent extends StatelessWidget {
  final ProjectDetailState state;
  final BuildContext context;
  const ProjectDetailTracksComponent({
    super.key,
    required this.state,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note),
                const SizedBox(width: Dimensions.space4),
                Text(
                  'Audio Tracks (${state.tracks.length})',
                  style: Theme.of(this.context).textTheme.titleMedium,
                ),
                if (state.isLoadingTracks) ...[
                  const SizedBox(width: Dimensions.space4),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            if (state.tracksError != null) ...[
              Text(
                'Error loading tracks: ${state.tracksError}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (state.tracks.isEmpty &&
                !state.isLoadingTracks &&
                state.tracksError == null) ...[
              const SizedBox(height: Dimensions.space16),
              const Text('No tracks found'),
            ],
            if (state.tracks.isNotEmpty) ...[
              ...state.tracks.map((trackUi) {
                final index = state.tracks.indexOf(trackUi);
                return TrackComponent(
                  vm: TrackRowViewModel(
                    track: trackUi.track,
                    displayedDuration: trackUi.duration,
                  ),
                  projectId: state.project!.project.id,
                  onPlay: () {
                    context.read<AudioPlayerBloc>().add(
                      PlayPlaylistRequested(
                        tracks: state.tracks.map((t) => t.track).toList(),
                        startIndex: index,
                      ),
                    );
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

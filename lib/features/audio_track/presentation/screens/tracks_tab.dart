import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/navegation/presentation/widget/fab_context_cubit.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/playback_source.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';

class TracksTab extends StatefulWidget {
  final ProjectId projectId;
  final void Function(AudioTrack track)? onCommentTrack;
  const TracksTab({super.key, required this.projectId, this.onCommentTrack});

  @override
  State<TracksTab> createState() => _TracksTabState();
}

class _TracksTabState extends State<TracksTab> {
  @override
  void initState() {
    super.initState();
    context.read<AudioTrackBloc>().add(
      WatchAudioTracksByProjectEvent(projectId: widget.projectId),
    );
    context.read<FabContextCubit>().setProjectDetailTracks(() {
      // pickAndUploadAudio(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<AudioTrackBloc, AudioTrackState>(
            buildWhen:
                (previous, current) =>
                    current is AudioTrackLoaded || current is AudioTrackLoading,
            builder: (context, state) {
              if (state is AudioTrackLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is AudioTrackLoaded) {
                final tracks = state.tracks;
                if (tracks.isEmpty) {
                  return _emptyState(context);
                }

                return ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return Slidable(
                      key: ValueKey(track.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              if (widget.onCommentTrack != null) {
                                widget.onCommentTrack!(track);
                              }
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.comment,
                            label: 'Comment',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(track.name),
                        subtitle: Text(
                          'Duration: ${track.duration.inSeconds}s',
                        ),
                        trailing: Icon(Icons.audiotrack),
                        onTap: () {
                          final audioPlayerBloc =
                              context.read<AudioPlayerBloc>();
                          audioPlayerBloc.add(
                            PlayAudioRequested(
                              source: PlaybackSource(
                                type: PlaybackSourceType.track,
                                track: track,
                              ),
                              visualContext: PlayerVisualContext.miniPlayer,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }

              return Center(child: Text('Something went wrong or no data.'));
            },
          ),
        ),
        BlocListener<AudioTrackBloc, AudioTrackState>(
          listener: (context, state) {
            if (state is AudioTrackError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is AudioTrackUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Audio uploaded successfully!')),
              );
            }
          },
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('No tracks found.')],
      ),
    );
  }
}

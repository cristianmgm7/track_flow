import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/utils/audio_utils.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/mini_audio_player.dart';
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
  }

  Future<void> _pickAndUploadAudio(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
      );
      if (result != null && result.files.single.path != null) {
        final name = result.files.single.name;
        final filePath = result.files.single.path!;

        final duration = await AudioUtils.getAudioDuration(filePath);

        context.read<AudioTrackBloc>().add(
          UploadAudioTrackEvent(
            file: File(filePath),
            name: name,
            duration: duration,
            projectId: widget.projectId,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                  itemCount: tracks.length + 1,
                  itemBuilder: (context, index) {
                    if (index < tracks.length) {
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
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: _uploadButton(context)),
                      );
                    }
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
        children: [
          Text('No tracks found.'),
          const SizedBox(height: 16),
          _uploadButton(context),
        ],
      ),
    );
  }

  Widget _uploadButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.upload_file),
      label: Text('Upload Audio'),
      onPressed: () => _pickAndUploadAudio(context),
    );
  }
}

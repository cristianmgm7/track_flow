import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class CommentsTab extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  const CommentsTab(this.projectId, this.track, {super.key});

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  late final PlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    if (widget.track.url.isNotEmpty) {
      _playerController.preparePlayer(path: widget.track.url);
    }
    // Start watching comments for this track
    context.read<AudioCommentBloc>().add(
      WatchCommentsByTrackEvent(widget.track.id),
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Waveform
        if (widget.track.url.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: AudioFileWaveforms(
              playerController: _playerController,
              size: const Size(double.infinity, 70),
              enableSeekGesture: true,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.blue,
                liveWaveColor: Colors.blueAccent,
                spacing: 6,
              ),
            ),
          )
        else
          Container(
            height: 80,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: const Center(child: Text('No audio file selected')),
          ),
        const Divider(),
        // Comments list
        Expanded(
          child: BlocBuilder<AudioCommentBloc, AudioCommentState>(
            builder: (context, state) {
              if (state is AudioCommentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AudioCommentError) {
                return Center(child: Text('Error: \\${state.message}'));
              }
              if (state is AudioCommentsLoaded) {
                if (state.comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }
                return ListView.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(comment.content),
                      subtitle: Text('By: \\${comment.createdBy.value}'),
                    );
                  },
                );
              }
              if (state is AudioCommentOperationSuccess) {
                // Optionally show a success message, or just reload comments
                return Center(child: Text(state.message));
              }
              // Covers AudioCommentInitial and any unknown state
              return const Center(child: Text('Unable to load comments.'));
            },
          ),
        ),
        // Add Comment Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Add Comment'),
                  onPressed: () async {
                    final content = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        String input = '';
                        return AlertDialog(
                          title: const Text('Add Comment'),
                          content: TextField(
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Enter your comment',
                            ),
                            onChanged: (value) => input = value,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(input),
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                    if (content != null && content.trim().isNotEmpty) {
                      context.read<AudioCommentBloc>().add(
                        AddAudioCommentEvent(
                          widget.projectId,
                          widget.track.id,
                          content.trim(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class TracksTab extends StatefulWidget {
  final ProjectId projectId;
  const TracksTab({super.key, required this.projectId});

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final name = result.files.single.name;

      // Get duration using just_audio
      final player = AudioPlayer();
      try {
        await player.setFilePath(file.path);
        final duration = player.duration ?? Duration.zero;

        context.read<AudioTrackBloc>().add(
          UploadAudioTrackEvent(
            file: file,
            name: name,
            duration: duration,
            projectId: widget.projectId,
          ),
        );
      } finally {
        await player.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioTrackBloc, AudioTrackState>(
      listener: (context, state) {
        if (state is AudioTrackUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio uploaded successfully!')),
          );
        } else if (state is AudioTrackError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        List<AudioTrack> tracks = [];
        if (state is AudioTrackLoaded) {
          tracks = state.tracks;
        }

        return Column(
          children: [
            Expanded(
              child:
                  state is AudioTrackLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: tracks.length + 1,
                        itemBuilder: (context, index) {
                          if (index < tracks.length) {
                            final track = tracks[index];
                            return ListTile(
                              title: Text(track.name),
                              subtitle: Text(
                                'Duration: ${track.duration.inSeconds}s',
                              ),
                              trailing: Icon(Icons.audiotrack),
                              onTap: () {
                                // TODO: Play audio or show details
                              },
                            );
                          } else {
                            // Upload button at the end
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Center(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.upload_file),
                                  label: Text('Upload Audio'),
                                  onPressed: () => _pickAndUploadAudio(context),
                                ),
                              ),
                            );
                          }
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}

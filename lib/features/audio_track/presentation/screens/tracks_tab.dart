import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/utils/audio_utils.dart';

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
        bool isLoading = false;
        String? errorMessage;

        if (state is AudioTrackLoading) {
          isLoading = true;
        }
        if (state is AudioTrackLoaded) {
          tracks = state.tracks;
        }
        if (state is AudioTrackError) {
          errorMessage = state.message;
        }

        if (isLoading && tracks.isEmpty) {
          // Show loading indicator only if no data yet
          return Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null && tracks.isEmpty) {
          // Show error message if no data
          return Center(child: Text(errorMessage));
        }

        if (tracks.isEmpty) {
          // Show empty state with upload button
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No tracks found.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Audio'),
                  onPressed:
                      isLoading ? null : () => _pickAndUploadAudio(context),
                ),
              ],
            ),
          );
        }

        // Show list with optional loading overlay
        return Stack(
          children: [
            ListView.builder(
              itemCount: tracks.length + 1,
              itemBuilder: (context, index) {
                if (index < tracks.length) {
                  final track = tracks[index];
                  return ListTile(
                    title: Text(track.name),
                    subtitle: Text('Duration: ${track.duration.inSeconds}s'),
                    trailing: Icon(Icons.audiotrack),
                    onTap: () {
                      // TODO: Play audio or show details
                    },
                  );
                } else {
                  // Upload button at the end
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text('Upload Audio'),
                        onPressed:
                            isLoading
                                ? null
                                : () => _pickAndUploadAudio(context),
                      ),
                    ),
                  );
                }
              },
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

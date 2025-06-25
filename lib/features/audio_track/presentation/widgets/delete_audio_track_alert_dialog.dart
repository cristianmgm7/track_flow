import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';

class DeleteAudioTrackAlertDialog extends StatelessWidget {
  final ProjectId projectId;
  final AudioTrack track;

  const DeleteAudioTrackAlertDialog({
    super.key,
    required this.projectId,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Track'),
      content: Text(
        'Are you sure you want to delete "${track.name}"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<AudioTrackBloc>().add(
              DeleteAudioTrackEvent(trackId: track.id, projectId: projectId),
            );
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

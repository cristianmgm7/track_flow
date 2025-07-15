import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/ui/dialogs/app_dialog.dart';

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
    return AppConfirmationDialog(
      title: 'Delete Track',
      message:
          'Are you sure you want to delete "${track.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () {
        context.read<AudioTrackBloc>().add(
          DeleteAudioTrackEvent(trackId: track.id, projectId: projectId),
        );
        Navigator.of(context).pop(true);
      },
    );
  }
}

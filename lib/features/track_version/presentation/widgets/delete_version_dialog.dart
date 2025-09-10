import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/dialogs/app_dialog.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';

/// Dialog for confirming deletion of a track version
class DeleteVersionDialog extends StatelessWidget {
  final TrackVersionId versionId;

  const DeleteVersionDialog({super.key, required this.versionId});

  static Future<void> show(
    BuildContext context, {
    required TrackVersionId versionId,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteVersionDialog(versionId: versionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Delete Version',
      content:
          'Are you sure you want to delete this version? This action cannot be undone.',
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      isDestructive: true,
      onPrimaryPressed: () {
        context.read<TrackVersionsBloc>().add(
          DeleteTrackVersionRequested(versionId),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

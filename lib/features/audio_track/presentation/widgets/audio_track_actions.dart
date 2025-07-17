import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/ui/modals/trackflow_action_sheet.dart';
import 'package:trackflow/features/ui/modals/trackflow_form_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/app_audio_comments_screen.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/delete_audio_track_alert_dialog.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/rename_audio_track_form_sheet.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackActions {
  static List<TrackFlowActionItem> forTrack(
    BuildContext context,
    ProjectId projectId,
    AudioTrack track,
  ) => [
    TrackFlowActionItem(
      icon: Icons.comment,
      title: 'Comment',
      subtitle: 'Add feedback or notes to this track',
      onTap: () {
        context.push(
          AppRoutes.audioComments,
          extra: AudioCommentsScreenArgs(
            projectId: track.projectId,
            track: track,
          ),
        );
      },
    ),
    TrackFlowActionItem(
      icon: Icons.edit,
      title: 'Rename',
      subtitle: 'Change the track’s title',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Rename Track',
          child: RenameTrackForm(track: track),
        );
      },
    ),
    TrackFlowActionItem(
      icon: Icons.delete,
      title: 'Delete Track',
      subtitle: 'Remove from the project',
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (context) => DeleteAudioTrackAlertDialog(
                projectId: projectId,
                track: track,
              ),
        );
      },
    ),
    TrackFlowActionItem(
      icon: Icons.download,
      title: 'Download',
      subtitle: 'Save this track to your device',
      onTap: () async {
        Navigator.of(context).pop(); // Close the action sheet

        // Use BLoC pattern for downloads
        context.read<TrackCacheBloc>().add(
          CacheTrackRequested(trackId: track.id.value, audioUrl: track.url),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${track.name} added to download queue'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    ),
  ];
}

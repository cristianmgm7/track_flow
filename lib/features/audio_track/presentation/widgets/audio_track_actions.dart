import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_botton_sheet.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_form_botton_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/audio_comments_screen.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/delete_audio_track_alert_dialog.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/rename_audio_track_form_sheet.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class TrackActions {
  static List<TrackFlowActionItem> forTrack(
    BuildContext context,
    ProjectId projectId,
    AudioTrack track,
    List<UserProfile> collaborators,
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
            collaborators: collaborators,
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
      onTap: () {
        // TODO: download
      },
    ),
  ];
}

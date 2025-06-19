import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_sheet.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class TrackActions {
  static List<TrackFlowActionItem> forTrack(
    BuildContext context,
    AudioTrack track,
  ) => [
    TrackFlowActionItem(
      icon: Icons.play_arrow,
      title: 'Play Track',
      subtitle: 'Preview this audio file',
      onTap: () {
        // TODO: play track
      },
    ),
    TrackFlowActionItem(
      icon: Icons.comment,
      title: 'Comment',
      subtitle: 'Add feedback or notes to this track',
      onTap: () {
        // TODO: open comment view
      },
    ),
    TrackFlowActionItem(
      icon: Icons.edit,
      title: 'Rename',
      subtitle: 'Change the track’s title',
      onTap: () {
        // TODO: rename logic
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
    TrackFlowActionItem(
      icon: Icons.delete,
      title: 'Delete Track',
      subtitle: 'Remove from the project',
      onTap: () {
        // TODO: confirm and delete
      },
    ),
  ];
}

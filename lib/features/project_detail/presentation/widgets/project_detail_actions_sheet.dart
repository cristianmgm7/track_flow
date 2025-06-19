import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_sheet.dart';

class ProjectDetailActions {
  static List<TrackFlowActionItem> forProject(BuildContext context) => [
    TrackFlowActionItem(
      icon: Icons.upload_file,
      title: 'Upload Track',
      subtitle: 'Add an audio file to this project',
      onTap: () {
        // TODO: upload track logic
      },
    ),
    TrackFlowActionItem(
      icon: Icons.mic,
      title: 'Voice Note',
      subtitle: 'Record a voice note directly',
      onTap: () {
        // TODO: voice note recording
      },
    ),
    TrackFlowActionItem(
      icon: Icons.person_add,
      title: 'Invite Collaborator',
      subtitle: 'Send an invite to join this project',
      onTap: () {
        // TODO: invite logic
      },
    ),
    TrackFlowActionItem(
      icon: Icons.settings,
      title: 'Project Settings',
      subtitle: 'Edit name, visibility or delete',
      onTap: () {
        // TODO: open project settings
      },
    ),
  ];
}

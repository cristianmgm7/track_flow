import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_sheet.dart';

class ProjectActions {
  static List<TrackFlowActionItem> onProjectList(BuildContext context) => [
    TrackFlowActionItem(
      icon: Icons.add,
      title: 'Create Project',
      subtitle: 'Start a new project from scratch',
      onTap: () {
        // TODO: open create project flow
      },
    ),
    TrackFlowActionItem(
      icon: Icons.group_add,
      title: 'Join Project',
      subtitle: 'Enter a code to join an existing project',
      onTap: () {
        // TODO: open join project flow
      },
    ),
  ];
}

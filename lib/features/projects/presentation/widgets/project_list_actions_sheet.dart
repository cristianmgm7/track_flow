import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_sheet.dart';
import 'package:trackflow/features/projects/presentation/widgets/join_as_collaborator_dialog.dart';
import 'package:trackflow/features/projects/presentation/widgets/upload_track_action_sheet.dart';

class ProjectActions {
  static List<TrackFlowActionItem> onProjectList(BuildContext context) => [
    TrackFlowActionItem(
      icon: Icons.add,
      title: 'Create Project',
      subtitle: 'Start a new project from scratch',
      childSheetBuilder: (context) => UploadTrackOptionsSheet(),
    ),

    TrackFlowActionItem(
      icon: Icons.group_add,
      title: 'Join Project',
      subtitle: 'Enter a code to join an existing project',
      childSheetBuilder: (context) => JoinAsCollaboratorDialog(),
    ),
  ];
}

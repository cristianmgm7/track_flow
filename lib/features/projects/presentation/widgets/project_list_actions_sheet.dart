import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_botton_sheet.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_form_botton_sheet.dart';
import 'package:trackflow/features/projects/presentation/widgets/join_as_collaborator_dialog.dart';
import 'package:trackflow/features/projects/presentation/widgets/create_project_form.dart';

class ProjectActions {
  static List<TrackFlowActionItem> onProjectList(BuildContext context) => [
    TrackFlowActionItem(
      icon: Icons.add,
      title: 'Create Project',
      subtitle: 'Start a new project from scratch',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Create Project',
          child: ProjectFormBottomSheet(),
        );
      },
    ),

    TrackFlowActionItem(
      icon: Icons.group_add,
      title: 'Join Project',
      subtitle: 'Enter a code to join an existing project',
      childSheetBuilder: (context) => JoinAsCollaboratorDialog(),
    ),
  ];
}

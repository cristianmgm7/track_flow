import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_botton_sheet.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_form_botton_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/delete_project_alert_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/edit_project_form.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailActions {
  static List<TrackFlowActionItem> forProject(
    BuildContext context,
    Project project,
  ) => [
    TrackFlowActionItem(
      icon: Icons.upload_file,
      title: 'Upload Track',
      subtitle: 'Add an audio file to this project',
      onTap: () {
        // TODO: upload track logic
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
      icon: Icons.edit,
      title: 'Edit Project',
      subtitle: 'Edit project name, description or visibility',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Edit Project',
          child: EditProjectForm(project: project),
        );
      },
    ),
    TrackFlowActionItem(
      icon: Icons.delete,
      title: 'Delete Project',
      subtitle: 'Delete this project',
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DeleteProjectDialog(project: project),
        );
      },
    ),
  ];
}

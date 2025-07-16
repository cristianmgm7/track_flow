import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/modals/trackflow_action_sheet.dart';
import 'package:trackflow/features/ui/modals/trackflow_form_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/add_collaborator_form.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/delete_project_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/edit_project_form.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/up_load_track_form.dart';
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
        showTrackFlowFormSheet(
          context: context,
          title: 'Upload Track',
          child: UploadTrackForm(project: project),
        );
      },
    ),
    TrackFlowActionItem(
      icon: Icons.person_add,
      title: 'Invite Collaborator',
      subtitle: 'Send an invite to join this project',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Invite Collaborator',
          child: AddCollaboratorForm(project: project),
        );
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
          useRootNavigator: false,
          builder: (dialogContext) => DeleteProjectDialog(project: project),
        );
      },
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/delete_project_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/edit_project_form.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/up_load_track_form.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailActions {
  static List<AppBottomSheetAction> forProject(
    BuildContext context,
    Project project,
  ) => [
    AppBottomSheetAction(
      icon: Icons.upload_file,
      title: 'Upload Track',
      subtitle: 'Add an audio file to this project',
      onTap: () {
        showAppFormSheet(
          context: context,
          title: 'Upload Track',
          child: UploadTrackForm(project: project),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.edit,
      title: 'Edit Project',
      subtitle: 'Edit project name, description or visibility',
      onTap: () {
        showAppFormSheet(
          context: context,
          title: 'Edit Project',
          child: EditProjectForm(project: project),
        );
      },
    ),
    AppBottomSheetAction(
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

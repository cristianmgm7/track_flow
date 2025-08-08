import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/projects/presentation/widgets/join_as_collaborator_dialog.dart';
import 'package:trackflow/features/projects/presentation/widgets/create_project_form.dart';

class ProjectActions {
  static List<AppBottomSheetAction> onProjectList(BuildContext context) => [
    AppBottomSheetAction(
      icon: Icons.add,
      title: 'Create Project',
      subtitle: 'Start a new project from scratch',
      onTap: () {
        showAppFormSheet(
          context: context,
          title: 'Create Project',
          child: ProjectFormBottomSheet(),
        );
      },
    ),

    AppBottomSheetAction(
      icon: Icons.group_add,
      title: 'Join Project',
      subtitle: 'Enter a code to join an existing project',
      childSheetBuilder: (context) => JoinAsCollaboratorDialog(),
    ),
  ];
}

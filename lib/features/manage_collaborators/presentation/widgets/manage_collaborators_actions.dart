import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/remove_colaborator_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/radio_to_update_collaborator_role.dart';

class CollaboratorActions {
  static List<AppBottomSheetAction> forCollaborator({
    required Project project,
    required BuildContext context,
    required UserProfile collaborator,
  }) => [
    AppBottomSheetAction(
      icon: Icons.person,
      title: 'View Profile',
      subtitle: 'See artist details and activity',
      onTap:
          () => context.push(
            AppRoutes.artistProfile.replaceFirst(':id', collaborator.id.value),
          ),
    ),
    AppBottomSheetAction(
      icon: Icons.edit,
      title: 'Edit Role',
      subtitle: "Change collaborator's role",
      onTap: () {
        final projectCollaborator = project.collaborators.firstWhere(
          (c) => c.userId == collaborator.id,
        );
        showAppContentModal(
          context: context,
          title: 'Edit Role',
          child: RadioToUpdateCollaboratorRole(
            projectId: project.id,
            userId: collaborator.id,
            initialRole: projectCollaborator.role.value,
            onSave: (_) {},
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.person_remove,
      title: 'Remove',
      subtitle: 'Remove from project',
      onTap: () {
        showAppFormSheet(
          context: context,
          title: 'Remove Collaborator',
          child: RemoveCollaboratorDialog(
            projectId: project.id,
            collaboratorId: collaborator.id.value,
            collaboratorName: collaborator.name,
          ),
        );
      },
    ),
  ];
}

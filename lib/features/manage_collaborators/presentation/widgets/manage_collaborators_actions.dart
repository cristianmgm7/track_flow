import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/remove_colaborator_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/radio_to_update_collaborator_role.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';

class CollaboratorActions {
  static List<AppBottomSheetAction> forCollaborator({
    required Project project,
    required BuildContext context,
    required UserProfile collaborator,
    required ManageCollaboratorsBloc manageCollaboratorsBloc,
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
    AppBottomSheetAction.withBloc(
      icon: Icons.edit,
      title: 'Edit Role',
      subtitle: "Change collaborator's role",
      onTapWithBloc: (context, bloc) {
        final projectCollaborator = project.collaborators.firstWhere(
          (c) => c.userId == collaborator.id,
        );
        showAppContentModal(
          showCloseButton: true,
          showHandle: true,
          context: context,
          title: 'Edit Role',
          reprovideBlocs: [bloc],
          child: RadioToUpdateCollaboratorRole(
            projectId: project.id,
            userId: collaborator.id,
            initialRole: projectCollaborator.role.value,
            onSave: (_) {},
            manageCollaboratorsBloc: bloc as ManageCollaboratorsBloc,
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.person_remove,
      title: 'Remove',
      subtitle: 'Remove from project',
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (dialogContext) => BlocProvider.value(
                value: context.read<ManageCollaboratorsBloc>(),
                child: RemoveCollaboratorDialog(
                  projectId: project.id,
                  collaboratorId: collaborator.id.value,
                  collaboratorName: collaborator.name,
                ),
              ),
        );
      },
    ),
  ];
}

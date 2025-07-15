import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/components/dialogs/app_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';

class DeleteProjectDialog extends StatelessWidget {
  final Project project;

  const DeleteProjectDialog({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return AppConfirmationDialog(
      title: 'Delete Project',
      message:
          'Are you sure you want to delete this project? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () {
        context.read<ProjectsBloc>().add(DeleteProjectRequested(project));
        Navigator.of(context).pop();
        if (context.mounted) {
          context.go(AppRoutes.projects);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Project deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }
}

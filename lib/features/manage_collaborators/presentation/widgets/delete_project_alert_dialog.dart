import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';

class DeleteProjectDialog extends StatelessWidget {
  final VoidCallback onDeleteProject;
  final Project project;

  const DeleteProjectDialog({
    super.key,
    required this.onDeleteProject,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Project'),
      content: const Text(
        'Are you sure you want to delete this project? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onDeleteProject();
            Navigator.of(context).pop();
            context.read<ProjectsBloc>().add(DeleteProjectRequested(project));
            context.go(AppRoutes.projects);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red, // Set the button color to red for emphasis
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

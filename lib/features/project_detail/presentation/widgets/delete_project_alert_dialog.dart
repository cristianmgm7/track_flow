import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';

class DeleteProjectDialog extends StatelessWidget {
  final Project project;

  const DeleteProjectDialog({super.key, required this.project});

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
            context.read<ProjectsBloc>().add(DeleteProjectRequested(project));
            Navigator.of(context).pop();
            context.go(AppRoutes.projects);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(
              255,
              106,
              21,
              15,
            ), // Set the button color to red for emphasis
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

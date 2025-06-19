import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

Future<void> showRenameProjectDialog(BuildContext context, Project project) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'New project name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: rename project
            },
            child: const Text('Rename'),
          ),
        ],
      );
    },
  );
}

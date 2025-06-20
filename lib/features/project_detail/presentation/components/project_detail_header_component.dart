import 'package:flutter/material.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailHeaderComponent extends StatelessWidget {
  final Project project;
  const ProjectDetailHeaderComponent({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name.value.fold(
                (failure) => 'Error loading project name',
                (value) => value,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              project.description.value.fold(
                (failure) => 'Error loading project description',
                (value) => value,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('Created: ${project.createdAt.toString().split(' ')[0]}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

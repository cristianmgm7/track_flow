import 'package:flutter/material.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_bottom_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/project_detail_actions_sheet.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailHeaderComponent extends StatelessWidget {
  final Project project;
  final BuildContext context;

  const ProjectDetailHeaderComponent({
    super.key,
    required this.project,
    required this.context,
  });

  void _openProjectDetailActionsSheet(Project project) {
    showTrackFlowActionSheet(
      title: 'Project Actions',
      context: context,
      actions: ProjectDetailActions.forProject(context, project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.name.value.fold(
                      (failure) => 'Error loading project name',
                      (value) => value,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => _openProjectDetailActionsSheet(project),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
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

import 'package:flutter/material.dart';
import 'package:trackflow/features/projects/presentation/helpers/project_presenter.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            if (project.needsAttention())
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.warning, color: Colors.orange),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _buildStatusChip(context),
                    ],
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Created ${ProjectPresenter.getFormattedDuration(project)} ago',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (project.isActive())
                        Text(
                          '${ProjectPresenter.getCompletionPercentage(project).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  if (project.isActive()) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          ProjectPresenter.getCompletionPercentage(project) /
                          100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    switch (project.status) {
      case Project.statusDraft:
        color = Colors.grey;
        break;
      case Project.statusInProgress:
        color = Colors.blue;
        break;
      case Project.statusFinished:
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        ProjectPresenter.getDisplayStatus(project),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

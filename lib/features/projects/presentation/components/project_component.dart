import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
import 'package:trackflow/features/ui/project/project_cover_art.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final projectName = project.name.value.fold((l) => '', (r) => r);
    final projectDescription = project.description.value.fold(
      (l) => '',
      (r) => r,
    );

    return AppProjectCard(
      title: projectName,
      description: projectDescription,
      createdAt: project.createdAt,
      onTap: onTap,
      leading: ProjectCoverArtSizes.large(
        projectName: projectName,
        projectDescription: projectDescription,
        imageUrl: project.coverUrl,
      ),
    );
  }
}

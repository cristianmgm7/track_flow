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

    // DEBUG: Log project cover art fields
    // ignore: avoid_print
    print('[PROJECT_COMPONENT] project=$projectName, coverUrl=${project.coverUrl}, coverLocalPath=${project.coverLocalPath}');

    // Prioritize local path for offline-first, fallback to remote URL
    final coverImageUrl = project.coverLocalPath ?? project.coverUrl;

    return AppProjectCard(
      title: projectName,
      description: projectDescription,
      createdAt: project.createdAt,
      onTap: onTap,
      leading: ProjectCoverArtSizes.large(
        projectName: projectName,
        projectDescription: projectDescription,
        imageUrl: coverImageUrl,
      ),
    );
  }
}

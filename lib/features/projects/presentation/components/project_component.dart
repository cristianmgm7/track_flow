import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
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

    // Prioritize local path for offline-first, fallback to remote URL
    final coverImageUrl = project.coverLocalPath ?? project.coverUrl;

    return AppProjectCard(
      margin: EdgeInsets.all(Dimensions.space0),
      padding: EdgeInsets.only(left: Dimensions.space16),
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

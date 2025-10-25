import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
import 'package:trackflow/features/ui/project/project_cover_art.dart';
import '../models/project_ui_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectUiModel project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use unwrapped primitives from UI model
    final coverImageUrl = project.coverLocalPath ?? project.coverUrl;

    return AppProjectCard(
      margin: EdgeInsets.all(Dimensions.space0),
      padding: EdgeInsets.only(left: Dimensions.space16),
      title: project.name,
      description: project.description,
      createdAt: project.createdAt,
      onTap: onTap,
      leading: ProjectCoverArtSizes.large(
        projectName: project.name,
        projectDescription: project.description,
        imageUrl: coverImageUrl,
      ),
    );
  }
}

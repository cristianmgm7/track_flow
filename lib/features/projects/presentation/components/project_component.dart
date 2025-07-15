import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppProjectCard(
      title: project.name.value.fold((l) => '', (r) => r),
      description: project.description.value.fold((l) => '', (r) => r),
      createdAt: project.createdAt,
      onTap: onTap,
    );
  }
}

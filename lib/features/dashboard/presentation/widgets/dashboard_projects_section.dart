import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/components/project_component.dart';
import 'package:trackflow/features/projects/presentation/widgets/create_project_form.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class DashboardProjectsSection extends StatelessWidget {
  final List<Project> projects;

  const DashboardProjectsSection({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Projects',
          onSeeAll: () => context.go(AppRoutes.projects),
        ),
        SizedBox(height: Dimensions.space12),
        if (projects.isEmpty)
          _buildEmptyState(context)
        else
          _buildProjectsGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding( 
      padding: EdgeInsets.all(Dimensions.space24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: Dimensions.space12),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: Dimensions.space8),
            Text(
              'Create your first project to get started!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: Dimensions.space16),
            FilledButton.icon(
              onPressed: () => _openProjectCreationSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  void _openProjectCreationSheet(BuildContext context) {
    showAppFormSheet(
      minChildSize: 0.7,
      initialChildSize: 0.7,
      maxChildSize: 0.7,
      context: context,
      title: 'Create Project',
      useRootNavigator: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProjectsBloc>()),
        ],
        child: ProjectFormBottomSheet(),
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 3,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          onTap: () => context.push(
            AppRoutes.projectDetails.replaceAll(':id', project.id.value),
            extra: project,
          ),
        );
      },
    );
  }
}



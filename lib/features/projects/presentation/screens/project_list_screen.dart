import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_action_bottom_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/projects/presentation/components/project_component.dart';
import 'package:trackflow/features/projects/presentation/widgets/project_list_actions_sheet.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(StartWatchingProjects());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openProjectActionsSheet() {
    showTrackFlowActionSheet(
      context: context,
      title: 'Create something new',
      actions: ProjectActions.onProjectList(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            onPressed: _openProjectActionsSheet,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<ProjectsBloc, ProjectsState>(
        buildWhen:
            (previous, current) =>
                current is! ProjectOperationSuccess &&
                current is! ProjectsError &&
                current is! ProjectsLoading,
        builder: (context, state) {
          if (state is ProjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProjectOperationSuccess) {
            return Center(child: Text(state.message));
          }
          if (state is ProjectsError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            );
          }
          if (state is ProjectsLoaded) {
            final projects = state.projects;
            if (projects.isEmpty) {
              return const Center(
                child: Text(
                  'No projects yet. Tap + to create your first project!',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(
                  project: project,
                  onTap:
                      () => context.push(
                        AppRoutes.projectDetails,
                        extra: project,
                      ),
                );
              },
            );
          }
          return const Center(child: Text('No projects available'));
        },
      ),
    );
  }
}

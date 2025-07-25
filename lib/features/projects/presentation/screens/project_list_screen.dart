import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/ui/modals/trackflow_action_sheet.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
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

  void _openProjectActionsSheet() {
    showTrackFlowActionSheet(
      context: context,
      title: 'Create something new',
      actions: ProjectActions.onProjectList(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'My Projects',
        centerTitle: true,
        showShadow: true,
        actions: [
          AppIconButton(
            icon: Icons.add_rounded,
            onPressed: _openProjectActionsSheet,
            tooltip: 'Create new project',
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [],
        body: BlocBuilder<ProjectsBloc, ProjectsState>(
          buildWhen:
              (previous, current) =>
                  current is! ProjectOperationSuccess &&
                  current is! ProjectsError &&
                  current is! ProjectsLoading,
          builder: (context, state) {
            if (state is ProjectsLoading) {
              return const AppProjectLoadingState();
            }
            if (state is ProjectOperationSuccess) {
              return AppProjectSuccessState(message: state.message);
            }
            if (state is ProjectsError) {
              return AppProjectErrorState(
                message: state.message,
                onRetry:
                    () => context.read<ProjectsBloc>().add(
                      StartWatchingProjects(),
                    ),
              );
            }
            if (state is ProjectsLoaded) {
              final projects = state.projects;
              if (projects.isEmpty) {
                return AppProjectEmptyState(
                  message: 'No projects yet',
                  subtitle: 'Create your first project to get started!',
                  icon: Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  actionText: 'Create Project',
                  onAction: _openProjectActionsSheet,
                );
              }
              return AppProjectList(
                projects:
                    projects
                        .map(
                          (project) => ProjectCard(
                            project: project,
                            onTap:
                                () => context.push(
                                  AppRoutes.projectDetails,
                                  extra: project,
                                ),
                          ),
                        )
                        .toList(),
              );
            }
            return const AppProjectEmptyState(
              message: 'No projects available',
              subtitle: 'Something went wrong. Please try again.',
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/navegation/presentation/widget/fab_context_cubit.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/projects/presentation/widgets/project_form_screen.dart';
import 'package:trackflow/features/projects/presentation/widgets/join_as_collaborator_dialog.dart';
import 'package:trackflow/features/projects/presentation/widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  FabContextCubit? _fabCubit;

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(StartWatchingProjects());
    context.read<FabContextCubit>().setProjects(_openProjectFormScreen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fabCubit ??= context.read<FabContextCubit>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openProjectFormScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProjectFormScreen(),
    );
  }

  void _showJoinProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JoinAsCollaboratorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'create') {
                _openProjectFormScreen();
              } else if (value == 'join') {
                _showJoinProjectDialog(context);
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'create',
                    child: Text('Crear Proyecto'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'join',
                    child: Text('Unirse a Proyecto con ID'),
                  ),
                ],
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
                      () =>
                          context.go(AppRoutes.projectDetails, extra: project),
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

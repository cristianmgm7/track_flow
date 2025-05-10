import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import '../widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProjectsBloc>().add(LoadProjects(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _loadProjects();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Projects'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push('/dashboard/projects/new');
              },
            ),
          ],
        ),
        body: BlocConsumer<ProjectsBloc, ProjectsState>(
          listener: (context, state) {
            if (state is ProjectsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProjectsLoading && state is! ProjectsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProjectsLoaded) {
              final projects = state.projects;

              if (projects.isEmpty) {
                return const Center(
                  child: Text('No projects yet. Create your first project!'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      context.push('/dashboard/projects/${project.id}');
                    },
                  );
                },
              );
            }

            return const Center(child: Text('No projects available'));
          },
        ),
      ),
    );
  }
}

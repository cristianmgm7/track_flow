import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/projects/presentation/widgets/project_card.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectListScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const ProjectListScreen({super.key, required this.prefs});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(LoadAllProjectsRequested());
  }

  void _loadProjects() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Placeholder: In the new Bloc-driven logic, project list loading will be handled differently.
      // Remove the call to context.read<ProjectsBloc>().add(LoadProjects(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProjectListScreen build called');
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
                          '/dashboard/projects/${project.id.value}',
                        ),
                  );
                },
              );
            }
            return const Center(child: Text('No projects available'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/dashboard/projects/new'),
          tooltip: 'Create New Project',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

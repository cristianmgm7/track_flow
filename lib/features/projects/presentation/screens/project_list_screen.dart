import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../widgets/project_card.dart';
import 'project_form_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectRepository = context.read<ProjectRepository>();
    final userId = 'current-user-id'; // TODO: Get from auth service

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: projectRepository.getUserProjects(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectFormScreen(project: project),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

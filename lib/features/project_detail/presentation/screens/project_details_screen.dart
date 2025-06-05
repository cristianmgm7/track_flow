import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(
      LoadProjectDetails(widget.project.id),
    );
  }

  void _shareProject(BuildContext context, Project project) {
    final projectId = widget.project.id;
    final projectCollaborators = widget.project.collaborators;
    final shareableLink = 'https://example.com/project/$projectId';
    Share.share('Check out this project: $shareableLink');
  }

  void _manageCollaborator(BuildContext context) {
    context.go(AppRoutes.manageCollaborators, extra: widget.project);
  }

  void _leaveProject(BuildContext context) {
    context.read<ProjectDetailBloc>().add(LeaveProject(widget.project.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.project.name.value.fold((l) => '', (r) => r),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go(AppRoutes.projects);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link, color: Colors.white),
            onPressed: () {
              _shareProject(context, widget.project);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'manage_collaborator':
                  _manageCollaborator(context);
                  break;
                case 'leave_project':
                  _leaveProject(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'manage_collaborator', 'leave_project'}.map((
                String choice,
              ) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Project Details Screen',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

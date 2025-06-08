import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/colaborator_list.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project; // recive full project with collaborators
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(
      LoadUserProfiles(widget.project),
    ); // to load user profiles of collaborators
  }

  void _shareProject(BuildContext context, Project project) {
    final projectId = widget.project.id;
    final shareableLink = 'https://example.com/project/$projectId';
    Share.share('Check out this project: $shareableLink');
  }

  void _manageCollaborator(
    BuildContext context,
    ProjectDetailsState state,
    Project project,
  ) {
    if (state is ProjectDetailsLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ManageCollaboratorsScreen(
                project: state.params.project,
                collaborators: state.params.collaborators,
              ),
        ),
      );
    }
  }

  void _leaveProject(BuildContext context) {
    context.read<ProjectDetailBloc>().add(LeaveProject(widget.project.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailBloc, ProjectDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Builder(
              builder: (_) {
                if (state is ProjectDetailsLoading) {
                  return const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  );
                } else if (state is ProjectDetailsLoaded) {
                  return Text(
                    state.params.project.name.value.fold((l) => '', (r) => r),
                    style: const TextStyle(color: Colors.white),
                  );
                } else {
                  return const Text('', style: TextStyle(color: Colors.white));
                }
              },
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300.0,
                  color: Colors.red,
                  child: Center(child: Text('Top of the Screen')),
                ),
                Container(
                  height: 50.0,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Top of the Screen',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                CollaboratorsList(
                  state: state,
                  project:
                      state is ProjectDetailsLoaded
                          ? state.params.project
                          : widget.project,
                  manageCollaborator: _manageCollaborator,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

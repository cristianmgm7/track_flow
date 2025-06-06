import 'package:flutter/material.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class CollaboratorsList extends StatefulWidget {
  final ProjectDetailsState state;
  final Project project;
  final Function(BuildContext, ProjectDetailsState, Project) manageCollaborator;

  const CollaboratorsList({
    super.key,
    required this.state,
    required this.project,
    required this.manageCollaborator,
  });

  @override
  State<CollaboratorsList> createState() => _CollaboratorsListState();
}

class _CollaboratorsListState extends State<CollaboratorsList> {
  void _manageCollaborator(
    BuildContext context,
    ProjectDetailsState state,
    Project project,
  ) {
    widget.manageCollaborator(context, state, project);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is ProjectDetailsLoaded) {
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount:
                (widget.state as ProjectDetailsLoaded).collaborators.length,
            itemBuilder: (context, index) {
              final userProfile =
                  (widget.state as ProjectDetailsLoaded).collaborators[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(userProfile.name),
                  subtitle: Text(userProfile.email),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              _manageCollaborator(context, widget.state, widget.project);
            },
            child: const Text('Manage team'),
          ),
        ],
      );
    } else if (widget.state is ProjectDetailsError) {
      return Center(
        child: Text(
          'Error: ${(widget.state as ProjectDetailsError).message}',
          style: const TextStyle(fontSize: 24, color: Colors.red),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Project Details Screen',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/add_participand_dialog.dart';
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
  }

  void _addParticipant(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AddParticipantDialog(
            onAddParticipant: (participantId) {
              // Handle the participant ID
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Project Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go(AppRoutes.projects);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Add Participant':
                  _addParticipant(context);
                  break;
                case 'Remove Participant':
                  // Trigger ParticipantRemoved event
                  // context.read<ProjectDetailBloc>().add(ParticipantRemoved(userId));
                  break;
                case 'Change Role':
                  // Trigger ParticipantRoleChanged event
                  // context.read<ProjectDetailBloc>().add(ParticipantRoleChanged(userId, newRole));
                  break;
                case 'Update Participants':
                  // Trigger ProjectParticipantsUpdated event
                  // context.read<ProjectDetailBloc>().add(ProjectParticipantsUpdated(updatedList));
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                'Add Participant',
                'Remove Participant',
                'Change Role',
                'Update Participants',
              }.map((String choice) {
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

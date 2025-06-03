import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/add_participand_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/change_rol_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/delete_project_alert_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/remove_participand_dialog.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
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

  void _removeParticipant(BuildContext context, Project project) {
    // showDialog(
    //   context: context,
    //   builder: (context) => RemoveParticipantDialog(
    //     onRemoveParticipant: () {},
    //   ),
    // );
  }

  void _changeRole(BuildContext context, Project project) {
    // showDialog(
    //   context: context,
    //   builder:
    //       (context) => ChangeRoleDialog(
    //         //userProfile: project.collaborators.first,
    //         onRoleChanged: (userProfile) {},
    //       ),
    // );
  }

  void _deleteProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder:
          (context) =>
              DeleteProjectDialog(onDeleteProject: () {}, project: project),
    );
  }

  void _shareProject(BuildContext context, Project project) {
    final projectId = widget.project.id;
    final shareableLink = 'https://example.com/project/$projectId';
    Share.share('Check out this project: $shareableLink');
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
                case 'Add Participant':
                  _addParticipant(context);
                  break;
                case 'Remove Participant':
                  _removeParticipant(context, widget.project);
                  break;
                case 'Change Role':
                  _changeRole(context, widget.project);
                  break;
                case 'Update Participants':
                  // Trigger ProjectParticipantsUpdated event
                  // context.read<ProjectDetailBloc>().add(ProjectParticipantsUpdated(updatedList));
                  break;
                case 'Delete Project':
                  _deleteProject(context, widget.project);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                'Add Participant',
                'Remove Participant',
                'Change Role',
                'Update Participants',
                'Delete Project',
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

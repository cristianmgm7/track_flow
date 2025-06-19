import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_header.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_tracks_component.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_collaborators_component.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectId projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(LoadProjectDetail(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
        builder: (context, state) {
          if (state.isLoadingProject && state.project == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.projectError != null && state.project == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading project: ${state.projectError}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final project = state.project;
          if (project == null) {
            return const Center(child: Text('No project found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Header
                ProjectDetailHeader(project: project),
                // Tracks Section
                ProjectDetailTracksSection(state: state, context: context),
                // Collaborators Section
                ProjectDetailCollaboratorsComponent(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

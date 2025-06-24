import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_header_component.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_tracks_component.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_collaborators_component.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';

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
      WatchProjectDetail(project: widget.project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.name.value.fold(
            (failure) => 'Error loading project name',
            (value) => value,
          ),
        ),
      ),
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
                ProjectDetailHeaderComponent(
                  project: project,
                  context: context,
                ),
                // Tracks Section
                BlocListener<AudioTrackBloc, AudioTrackState>(
                  listener: (context, state) {
                    if (state is AudioTrackError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: ProjectDetailTracksComponent(
                    state: state,
                    context: context,
                  ),
                ),
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

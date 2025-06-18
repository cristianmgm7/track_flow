import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/presentation/component/track_component.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';

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
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProjectDetailBloc>().add(
                        LoadProjectDetail(widget.projectId),
                      );
                    },
                    child: const Text('Retry'),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name.value.fold(
                            (failure) => 'Error loading project name',
                            (value) => value,
                          ),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description.value.fold(
                            (failure) => 'Error loading project description',
                            (value) => value,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Created: ${project.createdAt.toString().split(' ')[0]}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tracks Section
                _buildTracksSection(state),
                const SizedBox(height: 24),

                // Collaborators Section
                _buildCollaboratorsSection(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTracksSection(ProjectDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note),
                const SizedBox(width: 8),
                Text(
                  'Audio Tracks (${state.tracks.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.isLoadingTracks) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            if (state.tracksError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error loading tracks: ${state.tracksError}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (state.tracks.isEmpty &&
                !state.isLoadingTracks &&
                state.tracksError == null) ...[
              const SizedBox(height: 16),
              const Text('No tracks found'),
            ],
            if (state.tracks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...state.tracks.map(
                (track) => TrackComponent(
                  track: track,
                  uploader: state.collaborators.firstWhere(
                    (collaborator) => collaborator.id == track.uploadedBy,
                  ),
                  onPlay: () {
                    // TODO: Implement track playback
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorsSection(ProjectDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Collaborators (${state.collaborators.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.isLoadingCollaborators) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            if (state.collaboratorsError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error loading collaborators: ${state.collaboratorsError}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (state.collaborators.isEmpty &&
                !state.isLoadingCollaborators &&
                state.collaboratorsError == null) ...[
              const SizedBox(height: 16),
              const Text('No collaborators found'),
            ],
            if (state.collaborators.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...state.collaborators.map(
                (collaborator) => ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      collaborator.name.isNotEmpty
                          ? collaborator.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(collaborator.name),
                  subtitle: Text(collaborator.email),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    // TODO: Implement collaborator actions
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

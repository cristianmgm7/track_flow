import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_header_component.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_collaborators_component.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_widget.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart';
import 'package:trackflow/core/di/injection.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isUploadingTrack = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(
      WatchProjectDetail(project: widget.project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioTrackBloc, AudioTrackState>(
      listener: (context, state) {
        if (state is AudioTrackLoading) {
          setState(() => _isUploadingTrack = true);
        } else if (state is AudioTrackUploadSuccess ||
            state is AudioTrackError) {
          setState(() => _isUploadingTrack = false);
        }
      },
      child: Scaffold(
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

            // getting the tracks to build the playlist
            final tracks = state.tracks;
            final playlist = project.toPlaylist(tracks);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Header
                  ProjectDetailHeaderComponent(
                    project: project,
                    context: context,
                  ),

                  // PlaylistWidget para los tracks del proyecto
                  BlocProvider<PlaylistCacheBloc>(
                    create: (_) => sl<PlaylistCacheBloc>(),
                    child: PlaylistWidget(
                      playlist: playlist,
                      tracks: tracks,
                      projectId: project.id.value,
                    ),
                  ),
                  if (_isUploadingTrack)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Uploading track...'),
                        ],
                      ),
                    ),
                  // Collaborators Section
                  ProjectDetailCollaboratorsComponent(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

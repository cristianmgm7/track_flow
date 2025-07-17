import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_collaborators_component.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_sliver_header.dart';
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
  ProjectDetailBloc? _projectDetailBloc;

  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(
      WatchProjectDetail(project: widget.project),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectDetailBloc ??= context.read<ProjectDetailBloc>();
  }

  @override
  void dispose() {
    _projectDetailBloc?.add(const ClearProjectDetail());
    super.dispose();
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
      child: AppScaffold(
        appBar: null, // Remove the default app bar
        body: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            if (state.isLoadingProject && state.project == null) {
              return const Center(
                child: AppLoading(message: 'Loading project...'),
              );
            }

            if (state.projectError != null && state.project == null) {
              return AppProjectErrorState(
                message: 'Error loading project:  ${state.projectError}',
                onRetry:
                    () => context.read<ProjectDetailBloc>().add(
                      WatchProjectDetail(project: widget.project),
                    ),
              );
            }

            final project = state.project;
            if (project == null) {
              return const AppProjectEmptyState(
                message: 'No project found',
                subtitle: 'The project you are looking for does not exist.',
              );
            }

            // getting the tracks to build the playlist
            final tracks = state.tracks;
            final playlist = project.toPlaylist(tracks);

            return CustomScrollView(
              slivers: [
                ProjectDetailSliverHeader(project: project),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.space12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: Dimensions.iconMedium,
                                height: Dimensions.iconMedium,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: Dimensions.space12),
                              Text(
                                'Uploading track...',
                                style: AppTextStyle.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      // Collaborators Section
                      ProjectDetailCollaboratorsComponent(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

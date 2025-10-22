import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_event.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/project/project_card.dart';
import 'package:trackflow/features/ui/project/project_cover_art.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/project_detail_collaborators_component.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/project_detail_actions_sheet.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_permission.dart';
import 'package:trackflow/features/playlist/presentation/widgets/playlist_widget.dart';
import 'package:trackflow/core/sync/presentation/widgets/global_sync_indicator.dart';
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:trackflow/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectDetailBloc? _projectDetailBloc;

  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(
      WatchProjectDetail(projectId: widget.project.id),
    );
    context.read<PlaylistBloc>().add(WatchPlaylist(widget.project.id));
    context.read<SyncBloc>().add(const ForegroundSyncRequested());
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

  void _openProjectDetailActionsSheet(BuildContext context, Project project) {
    showAppActionSheet(
      useRootNavigator: true,
      title: 'Project Actions',
      context: context,
      actions: ProjectDetailActions.forProject(context, project),
      initialChildSize: 0.5,
    );
  }

  bool _userHasEditPermission(Project project, String? currentUserId) {
    if (currentUserId == null) return false;

    final userId = UserId.fromUniqueString(currentUserId);

    final userCollaborator = project.collaborators.where(
      (collaborator) => collaborator.userId == userId,
    ).firstOrNull;

    if (userCollaborator == null) return false;

    return userCollaborator.hasPermission(ProjectPermission.editProject);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
      builder: (context, state) {
        if (state.isLoadingProject && state.project == null) {
          return AppScaffold(
            topSafeArea: false,
            body: const Center(
              child: AppLoading(message: 'Loading project...'),
            ),
          );
        }

        if (state.projectError != null && state.project == null) {
          return AppScaffold(
            topSafeArea: false,
            body: AppProjectErrorState(
              message: 'Error loading project:  ${state.projectError}',
              onRetry:
                  () => context.read<ProjectDetailBloc>().add(
                    WatchProjectDetail(projectId: widget.project.id),
                  ),
            ),
          );
        }

        final project = state.project;
        if (project == null) {
          return AppScaffold(
            topSafeArea: false,
            body: const AppProjectEmptyState(
              message: 'No project found',
              subtitle: 'The project you are looking for does not exist.',
            ),
          );
        }

        // getting the tracks to build the playlist
        final tracks = state.tracks;
        final playlist = project.toPlaylist(tracks);

        return Scaffold(
          body: Stack(
            children: [
              // 1. BACKGROUND IMAGE (COVER)
              Positioned.fill(
                child: ProjectCoverArt(
                  projectName: project.name.value.getOrElse(() => 'Project'),
                  projectDescription: project.description.value.getOrElse(() => ''),
                  imageUrl: project.coverUrl,
                  size: MediaQuery.of(context).size.width,
                  borderRadius: BorderRadius.zero,
                  showShadow: false,
                ),
              ),
              // 3. SCROLLABLE FOREGROUND CONTENT
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        project.name.value.getOrElse(() => 'Project'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: ProjectCoverArt(
                        projectName: project.name.value.getOrElse(() => 'Project'),
                        projectDescription: project.description.value.getOrElse(() => ''),
                        imageUrl: project.coverUrl,
                        size: MediaQuery.of(context).size.width,
                        borderRadius: BorderRadius.zero,
                        showShadow: false,
                      ),
                    ),
                  ),

                  // 4. MAIN CONTENT SECTION
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.all(Dimensions.space0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.space12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
                            child: GlobalSyncIndicator(),
                          ),
                          const SizedBox(height: Dimensions.space12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
                            child: BlocBuilder<CurrentUserBloc, CurrentUserState>(
                              builder: (context, profileState) {
                                final currentUserId = profileState is CurrentUserLoaded
                                    ? profileState.profile.id.value
                                    : null;
                                final hasEditPermission = _userHasEditPermission(project, currentUserId);

                                return Row(
                                  children: [
                                    Text(
                                      "Tracks",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const Spacer(),
                                    if (hasEditPermission)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: AppColors.textPrimary,
                                        ),
                                        onPressed: () => _openProjectDetailActionsSheet(context, project),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.space8),
                          PlaylistWidget(
                            playlist: playlist,
                            tracks: tracks,
                            projectId: project.id.value,
                          ),
                          const SizedBox(height: 16),
                          ProjectDetailCollaboratorsComponent(state: state),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

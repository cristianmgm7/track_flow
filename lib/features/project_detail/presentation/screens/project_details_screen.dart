import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks_tab.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/comments_tab.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/mini_audio_player.dart';
import 'package:trackflow/features/audio_comment/presentation/widgets/comment_audio_player.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AudioTrack? _selectedTrack;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    if (_tabController.index == 1) {
      // Comments tab
      audioPlayerBloc.add(
        ChangeVisualContext(PlayerVisualContext.commentPlayer),
      );
    } else {
      // Tracks o Team tab
      audioPlayerBloc.add(ChangeVisualContext(PlayerVisualContext.miniPlayer));
    }
    if (_tabController.index == 1 && _selectedTrack == null) {
      // Comments tab selected, but no track selected
      // The BlocBuilder in build will handle setting the track
      setState(() {}); // Trigger rebuild
    }
  }

  void _goToCommentsTab(AudioTrack track) {
    setState(() {
      _selectedTrack = track;
    });
    _tabController.animateTo(1); // Comments tab index
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name.toString()),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tracks', icon: Icon(Icons.music_note)),
            Tab(text: 'Comments', icon: Icon(Icons.comment)),
            Tab(text: 'Team', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              TracksTab(
                projectId: widget.project.id,
                onCommentTrack: _goToCommentsTab,
              ),
              // --- Comments Tab ---
              Builder(
                builder: (context) {
                  // Only auto-select if on Comments tab and no track is selected
                  if (_tabController.index == 1 && _selectedTrack == null) {
                    return BlocBuilder<AudioTrackBloc, AudioTrackState>(
                      builder: (context, state) {
                        if (state is AudioTrackLoaded &&
                            state.tracks.isNotEmpty) {
                          // Select the most recent (last) track
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_selectedTrack == null) {
                              setState(() {
                                _selectedTrack = state.tracks.last;
                              });
                            }
                          });
                          // Show a loading indicator while setState triggers rebuild
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is AudioTrackLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is AudioTrackLoaded &&
                            state.tracks.isEmpty) {
                          return const Center(
                            child: Text('No tracks available.'),
                          );
                        } else {
                          return const Center(
                            child: Text('Select a track to comment on.'),
                          );
                        }
                      },
                    );
                  }
                  // If a track is selected, show CommentsTab
                  if (_selectedTrack != null) {
                    return CommentsTab(widget.project.id, _selectedTrack!);
                  }
                  // Fallback
                  return const Center(
                    child: Text('Select a track to comment on.'),
                  );
                },
              ),
              // --- Team Tab ---
              ManageCollaboratorsScreen(projectId: widget.project.id),
            ],
          ),
          // Reproductor global reactivo
          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
            buildWhen: (prev, curr) => prev.visualContext != curr.visualContext,
            builder: (context, state) {
              Widget? player;
              Alignment alignment = Alignment.bottomCenter;

              if (state.visualContext == PlayerVisualContext.miniPlayer) {
                player = MiniAudioPlayer(state: state);
                alignment = Alignment.bottomCenter;
              } else if (state.visualContext ==
                  PlayerVisualContext.commentPlayer) {
                player = CommentAudioPlayer(state: state);
                alignment = Alignment.topCenter;
              }

              return Align(
                alignment: alignment,
                child: player ?? const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}

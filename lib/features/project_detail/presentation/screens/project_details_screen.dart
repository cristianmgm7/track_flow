import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/presentation/cubit/audio_player_cubit.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/mini_audio_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks_tab.dart';
import 'package:trackflow/features/audio_comment/presentation/widgets/comments_tab.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

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
  }

  void _goToCommentsTab(AudioTrack track) {
    setState(() {
      _selectedTrack = track;
    });
    _tabController.animateTo(1); // Comments tab index
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AudioPlayerCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.name.toString()),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Go to project settings
              },
            ),
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
                _selectedTrack != null
                    ? CommentsTab(widget.project.id, _selectedTrack!)
                    : Center(child: Text('Select a track to comment on.')),
                ManageCollaboratorsScreen(projectId: widget.project.id),
              ],
            ),
            Align(alignment: Alignment.bottomCenter, child: MiniAudioPlayer()),
          ],
        ),
      ),
    );
  }
}

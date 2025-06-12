import 'package:trackflow/features/audio_track/presentation/cubit/audio_player_cubit.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/mini_audio_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks_tab.dart';
import 'package:trackflow/features/audio_comment/presentation/widgets/comments_tab.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AudioPlayerCubit(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(project.name.toString()),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Go to project settings
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Tracks', icon: Icon(Icons.music_note)),
                Tab(text: 'Comments', icon: Icon(Icons.comment)),
                Tab(text: 'Team', icon: Icon(Icons.group)),
              ],
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
                children: [
                  TracksTab(projectId: project.id),
                  CommentsTab(projectId: project.id.value),
                  ManageCollaboratorsScreen(projectId: project.id),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: MiniAudioPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

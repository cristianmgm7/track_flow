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
    return DefaultTabController(
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
        body: TabBarView(
          children: [
            TracksTab(projectId: project.id.value),
            CommentsTab(projectId: project.id.value),
            ManageCollaboratorsScreen(projectId: project.id),
          ],
        ),
      ),
    );
  }
}

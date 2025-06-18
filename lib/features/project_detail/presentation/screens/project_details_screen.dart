import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trackflow/features/audio_track/utils/audio_utils.dart';
import 'dart:io';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectDetailBloc>().add(LoadUserProfiles(widget.project));
  }

  void _navigateToTeam() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => ManageCollaboratorsScreen(projectId: widget.project.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailBloc, ProjectDetailsState>(
      builder: (context, state) {
        if (state is ProjectDetailsLoaded) {
          final collaborators = state.params.collaborators;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.project.name.toString()),
              actions: [
                IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: _navigateToTeam,
                  tooltip: 'Team',
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                  tooltip: 'Settings',
                ),
              ],
            ),
            body: AudioTracksList(
              projectId: widget.project.id,
              collaborators: collaborators,
              onCommentTrack: (track) {
                // Navigate to comments view for this track
                context.push('/comments', extra: track);
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _onAddTrack() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a'],
    );
    if (result != null && result.files.single.path != null) {
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final duration = await AudioUtils.getAudioDuration(filePath);

      context.read<AudioTrackBloc>().add(
        UploadAudioTrackEvent(
          file: File(filePath),
          name: name,
          duration: duration,
          projectId: widget.project.id,
        ),
      );
    }
  }
}

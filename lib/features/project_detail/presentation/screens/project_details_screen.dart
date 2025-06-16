import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks_tab.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/comments_tab.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/navegation/presentation/widget/fab_context_cubit.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_state.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_event.dart';

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
  late TracksTab _tracksTab;
  late ManageCollaboratorsScreen _teamTab;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _tracksTab = TracksTab(
      projectId: widget.project.id,
      onCommentTrack: _goToCommentsTab,
    );
    _teamTab = ManageCollaboratorsScreen(projectId: widget.project.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFabContext();
    });
  }

  void _handleTabChange() {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    if (_tabController.index == 1) {
      audioPlayerBloc.add(
        ChangeVisualContext(PlayerVisualContext.commentPlayer),
      );
    } else {
      audioPlayerBloc.add(ChangeVisualContext(PlayerVisualContext.miniPlayer));
    }
    if (_tabController.index == 1 && _selectedTrack == null) {
      setState(() {}); // Trigger rebuild
    }
    _notifyFabContext();
  }

  void _notifyFabContext() {
    final fabCubit = context.read<FabContextCubit>();
    switch (_tabController.index) {
      case 0:
        fabCubit.setProjectDetailTracks(() {
          // Llama al método de TracksTab para subir audio
          _tracksTab.pickAndUploadAudio(context);
        });
        break;
      case 1:
        fabCubit.setProjectDetailComments(() {
          // Mostrar diálogo para añadir comentario
          _showAddCommentDialog(context);
        });
        break;
      case 2:
        fabCubit.setProjectDetailTeam(() {
          // Llama al método de ManageCollaboratorsScreen para añadir colaborador
          _teamTab.addCollaborator(context);
        });
        break;
    }
  }

  void _showAddCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Agregar comentario'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Escribe tu comentario',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedTrack != null && controller.text.isNotEmpty) {
                  context.read<AudioCommentBloc>().add(
                    AddAudioCommentEvent(
                      widget.project.id,
                      _selectedTrack!.id,
                      controller.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
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
    // Oculta el FAB al salir
    context.read<FabContextCubit>().hide();
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
              _tracksTab,
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
              _teamTab,
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/audio_track/presentation/screens/tracks_tab.dart';
import 'package:trackflow/features/audio_comment/presentation/screens/comments_tab.dart';
import 'package:trackflow/features/manage_collaborators/presentation/screens/manage_collaborators_screen.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:trackflow/features/audio_track/utils/audio_utils.dart';
import 'dart:io';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/add_collaborator_dialog.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';

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
  FabContextCubit? _fabCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _tracksTab = TracksTab(
      projectId: widget.project.id,
      collaborators: [],
      onCommentTrack: _goToCommentsTab,
    );
    _teamTab = ManageCollaboratorsScreen(projectId: widget.project.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFabContext();
    });
    context.read<ProjectDetailBloc>().add(LoadUserProfiles(widget.project));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fabCubit ??= context.read<FabContextCubit>();
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
    switch (_tabController.index) {
      case 0:
        _fabCubit?.setProjectDetailTracks(_onAddTrack);
        break;
      case 1:
        _fabCubit?.setProjectDetailComments(_onAddComment);
        break;
      case 2:
        _fabCubit?.setProjectDetailTeam(() {
          _onAddCollaborator();
        });
        break;
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
    // Usar la referencia guardada
    _fabCubit?.hide();
    super.dispose();
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
                    // --- Tracks Tab ---
                    TracksTab(
                      projectId: widget.project.id,
                      collaborators: collaborators,
                      onCommentTrack: _goToCommentsTab,
                    ),
                    // --- Comments Tab ---
                    Builder(
                      builder: (context) {
                        if (_tabController.index == 1 &&
                            _selectedTrack == null) {
                          return BlocBuilder<AudioTrackBloc, AudioTrackState>(
                            builder: (context, state) {
                              if (state is AudioTrackLoaded &&
                                  state.tracks.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_selectedTrack == null) {
                                    setState(() {
                                      _selectedTrack = state.tracks.last;
                                    });
                                  }
                                });
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
                        if (_selectedTrack != null) {
                          // comment tab
                          return CommentsTab(
                            widget.project.id,
                            _selectedTrack!,
                            collaborators,
                          );
                        }
                        return const Center(
                          child: Text('Select a track to comment on.'),
                        );
                      },
                    ),
                    // --- Team Tab ---
                    ManageCollaboratorsScreen(projectId: widget.project.id),
                  ],
                ),
              ],
            ),
          );
        }
        // Loading o error
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _onAddCollaborator() {
    showDialog(
      context: context,
      builder: (context) {
        return AddCollaboratorDialog(projectId: widget.project.id);
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

  void _onAddComment() {
    if (_selectedTrack != null) {
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
                  if (controller.text.isNotEmpty) {
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
  }
}

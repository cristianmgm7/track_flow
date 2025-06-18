import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

// --- NUEVO ENUM Y WIDGET ---
enum PlayerViewMode { mini, expanded }

class AudioPlayerSheet extends StatelessWidget {
  final PlayerViewMode mode;
  const AudioPlayerSheet({super.key, required this.mode});

  void _showExpandedPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return BlocProvider.value(
                value: context.read<AudioPlayerBloc>(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Expanded player content
                      Expanded(
                        child: _ExpandedPlayerContent(
                          scrollController: scrollController,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        if (mode == PlayerViewMode.mini) {
          return _buildMiniPlayer(context, track, collaborator, state);
        } else {
          return _buildExpandedPlayer(context, track, collaborator, state);
        }
      },
    );
  }

  Widget _buildMiniPlayer(
    BuildContext context,
    AudioTrack track,
    UserProfile collaborator,
    AudioPlayerActiveState state,
  ) {
    final isPlaying = state is AudioPlayerPlaying;
    final isLoading = state is AudioPlayerLoading;

    return GestureDetector(
      onTap: () => _showExpandedPlayer(context),
      onVerticalDragUpdate: (details) {
        // Si el deslizamiento es hacia arriba (delta Y negativo) y supera cierto umbral
        if (details.primaryDelta! < -10) {
          _showExpandedPlayer(context);
        }
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  collaborator.avatarUrl.isNotEmpty
                      ? NetworkImage(collaborator.avatarUrl)
                      : null,
              child:
                  collaborator.avatarUrl.isEmpty
                      ? Text(
                        collaborator.name.isNotEmpty
                            ? collaborator.name.substring(0, 1)
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    collaborator.name,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap:
                    isLoading
                        ? null
                        : () {
                          if (isPlaying) {
                            context.read<AudioPlayerBloc>().add(
                              PauseAudioRequested(),
                            );
                          } else {
                            context.read<AudioPlayerBloc>().add(
                              ResumeAudioRequested(),
                            );
                          }
                        },
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(
    BuildContext context,
    AudioTrack track,
    UserProfile collaborator,
    AudioPlayerActiveState state,
  ) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [_ExpandedPlayerContent(scrollController: null)],
        ),
      ),
    );
  }
}

class _ExpandedPlayerContent extends StatelessWidget {
  final ScrollController? scrollController;

  const _ExpandedPlayerContent({this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        final track = state.track;
        final collaborator = state.collaborator;
        final isPlaying = state is AudioPlayerPlaying;

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.expand_more),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                children: [
                  Text(
                    track.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    collaborator.name,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Album art or waveform
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Progress bar
                    LinearProgressIndicator(
                      value: 0.3, // Replace with actual progress
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0:00', // Replace with actual current time
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          '3:45', // Replace with actual duration
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () {},
                          color: Colors.white,
                          iconSize: 36,
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            if (isPlaying) {
                              context.read<AudioPlayerBloc>().add(
                                PauseAudioRequested(),
                              );
                            } else {
                              context.read<AudioPlayerBloc>().add(
                                ResumeAudioRequested(),
                              );
                            }
                          },
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {},
                          color: Colors.white,
                          iconSize: 36,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Additional controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          onPressed: () {},
                          color: Colors.grey[400],
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat),
                          onPressed: () {},
                          color: Colors.grey[400],
                        ),
                        IconButton(
                          icon: const Icon(Icons.queue_music),
                          onPressed: () {},
                          color: Colors.grey[400],
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () => context.push('/comments'),
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

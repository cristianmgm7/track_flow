import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pure_audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../pure_audio_player/presentation/bloc/audio_player_event.dart';
import '../../../pure_audio_player/presentation/bloc/audio_player_state.dart';
import '../../../pure_audio_player/presentation/widgets/pure_audio_player.dart';
import '../../../pure_audio_player/domain/entities/audio_track_id.dart';
import '../../../pure_audio_player/domain/entities/playlist_id.dart';
import '../../../audio_context/presentation/bloc/audio_context_cubit.dart';
import '../../../audio_context/presentation/widgets/track_info_display.dart';

/// Collaborative audio screen that combines pure audio player with business context
/// Uses composition pattern to integrate separate features while maintaining SOLID principles
/// This demonstrates how to use the pure audio architecture in a business context
class CollaborativeAudioScreen extends StatefulWidget {
  const CollaborativeAudioScreen({
    super.key,
    this.initialTrackId,
    this.projectId,
    this.showComments = true,
    this.allowContextEdit = false,
  });

  final String? initialTrackId;
  final String? projectId;
  final bool showComments;
  final bool allowContextEdit;

  @override
  State<CollaborativeAudioScreen> createState() => _CollaborativeAudioScreenState();
}

class _CollaborativeAudioScreenState extends State<CollaborativeAudioScreen> {
  @override
  void initState() {
    super.initState();
    
    // Initialize audio player
    context.read<AudioPlayerBloc>().add(const AudioPlayerInitializeRequested());
    
    // Load initial track if provided
    if (widget.initialTrackId != null) {
      _loadTrackWithContext(widget.initialTrackId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Could open audio settings
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to audio player changes to update context
          BlocListener<AudioPlayerBloc, AudioPlayerState>(
            listener: (context, audioState) {
              if (audioState is AudioPlayerPlaying || audioState is AudioPlayerPaused) {
                final trackId = audioState.session.currentTrack?.id.value;
                if (trackId != null) {
                  context.read<AudioContextCubit>().loadTrackContext(trackId);
                }
              } else if (audioState is AudioPlayerStopped) {
                context.read<AudioContextCubit>().clearContext();
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pure audio player (no business context)
              const PureAudioPlayer(
                showVolumeControl: true,
                showSpeedControl: true,
                showTrackInfo: true,
              ),
              
              const SizedBox(height: 20),
              
              // Business context information
              const TrackInfoDisplay(
                showCollaborator: true,
                showProject: true,
                showTags: true,
                showUploadDate: true,
              ),
              
              const SizedBox(height: 20),
              
              // Quick actions for testing/demo
              _buildQuickActions(context),
              
              const SizedBox(height: 20),
              
              // Comments section placeholder
              if (widget.showComments)
                _buildCommentsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  context,
                  'Load Demo Track',
                  Icons.music_note,
                  () => _loadDemoTrack(context),
                ),
                _buildActionChip(
                  context,
                  'Load Demo Playlist',
                  Icons.queue_music,
                  () => _loadDemoPlaylist(context),
                ),
                _buildActionChip(
                  context,
                  'Clear Player',
                  Icons.clear,
                  () => _clearPlayer(context),
                ),
                _buildActionChip(
                  context,
                  'Save State',
                  Icons.save,
                  () => _saveState(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audio synchronized comments feature will be integrated here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Demo actions for testing the architecture
  void _loadTrackWithContext(String trackId) {
    // Load track in audio player
    context.read<AudioPlayerBloc>().add(
      PlayAudioRequested(AudioTrackId(trackId)),
    );
    
    // Load business context
    context.read<AudioContextCubit>().loadTrackContext(trackId);
  }

  void _loadDemoTrack(BuildContext context) {
    _loadTrackWithContext('demo_track_001');
  }

  void _loadDemoPlaylist(BuildContext context) {
    context.read<AudioPlayerBloc>().add(
      PlayPlaylistRequested(const PlaylistId('demo_playlist_001')),
    );
  }

  void _clearPlayer(BuildContext context) {
    context.read<AudioPlayerBloc>().add(const StopAudioRequested());
    context.read<AudioContextCubit>().clearContext();
  }

  void _saveState(BuildContext context) {
    context.read<AudioPlayerBloc>().add(const SavePlaybackStateRequested());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playback state saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
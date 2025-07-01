import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../track/presentation/bloc/track_cache_bloc.dart';
import '../track/presentation/bloc/track_cache_event.dart';
import '../track/presentation/bloc/track_cache_state.dart';
import '../playlist/presentation/bloc/playlist_cache_bloc.dart';
import '../playlist/presentation/bloc/playlist_cache_event.dart';
import '../playlist/presentation/bloc/playlist_cache_state.dart';

class CacheDemoScreen extends StatelessWidget {
  const CacheDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cache Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Track Cache Demo
            BlocProvider(
              create:
                  (context) => TrackCacheBloc(
                    cacheTrackUseCase: context.read(),
                    getTrackCacheStatusUseCase: context.read(),
                    removeTrackCacheUseCase: context.read(),
                  ),
              child: const TrackCacheDemo(),
            ),

            const SizedBox(height: 32),

            // Playlist Cache Demo
            BlocProvider(
              create:
                  (context) => PlaylistCacheBloc(
                    cachePlaylistUseCase: context.read(),
                    getPlaylistCacheStatusUseCase: context.read(),
                    removePlaylistCacheUseCase: context.read(),
                  ),
              child: const PlaylistCacheDemo(),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackCacheDemo extends StatelessWidget {
  const TrackCacheDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Cache Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TrackCacheBloc>().add(
                        const CacheTrackRequested(
                          trackId: 'demo_track_1',
                          audioUrl: 'https://example.com/demo_track_1.mp3',
                        ),
                      );
                    },
                    child: const Text('Cache Track'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TrackCacheBloc>().add(
                        GetTrackCacheStatusRequested('demo_track_1'),
                      );
                    },
                    child: const Text('Check Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TrackCacheBloc>().add(
                        const RemoveTrackCacheRequested(
                          trackId: 'demo_track_1',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TrackCacheBloc, TrackCacheState>(
              builder: (context, state) {
                if (state is TrackCacheLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TrackCacheStatusLoaded) {
                  return Text('Status: ${state.status}');
                }
                if (state is TrackCacheOperationSuccess) {
                  return Text('Success: ${state.message}');
                }
                if (state is TrackCacheOperationFailure) {
                  return Text('Error: ${state.error}');
                }
                return const Text('No status');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistCacheDemo extends StatelessWidget {
  const PlaylistCacheDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Playlist Cache Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlaylistCacheBloc>().add(
                        CachePlaylistRequested(
                          playlistId: 'demo_playlist_1',
                          trackIds: ['track_1', 'track_2', 'track_3'],
                        ),
                      );
                    },
                    child: const Text('Cache Playlist'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlaylistCacheBloc>().add(
                        GetPlaylistCacheStatusRequested(
                          trackIds: ['track_1', 'track_2', 'track_3'],
                        ),
                      );
                    },
                    child: const Text('Check Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlaylistCacheBloc>().add(
                        RemovePlaylistCacheRequested(
                          playlistId: 'demo_playlist_1',
                          trackIds: ['track_1', 'track_2', 'track_3'],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<PlaylistCacheBloc, PlaylistCacheState>(
              builder: (context, state) {
                if (state is PlaylistCacheLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PlaylistCacheStatusLoaded) {
                  final cachedCount =
                      state.trackStatuses.values
                          .where((exists) => exists)
                          .length;
                  return Text(
                    'Cached: $cachedCount/${state.trackStatuses.length}',
                  );
                }
                if (state is PlaylistCacheOperationSuccess) {
                  return Text('Success: ${state.message}');
                }
                if (state is PlaylistCacheOperationFailure) {
                  return Text('Error: ${state.error}');
                }
                return const Text('No status');
              },
            ),
          ],
        ),
      ),
    );
  }
}

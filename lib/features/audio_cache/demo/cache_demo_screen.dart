import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../track/presentation/bloc/track_cache_bloc.dart';
import '../track/presentation/widgets/smart_track_cache_icon.dart';
import '../playlist/presentation/bloc/playlist_cache_bloc.dart';
import '../playlist/presentation/widgets/playlist_cache_icon.dart';
import '../shared/presentation/widgets/cache_status_indicator.dart';
import '../shared/domain/entities/cached_audio.dart';

class CacheDemoScreen extends StatelessWidget {
  const CacheDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Cache Architecture Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<TrackCacheBloc>(
            create: (context) => TrackCacheBloc(
              // Los use cases se inyectan automáticamente
              context.read(),
              context.read(),
              context.read(),
            ),
          ),
          BlocProvider<PlaylistCacheBloc>(
            create: (context) => PlaylistCacheBloc(
              context.read(),
              context.read(),
              context.read(),
            ),
          ),
        ],
        child: const CacheDemoContent(),
      ),
    );
  }
}

class CacheDemoContent extends StatelessWidget {
  const CacheDemoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva Arquitectura de Cache',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Track Cache Demo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Individual Track Cache',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SmartTrackCacheIcon(
                        trackId: 'demo_track_1',
                        audioUrl: 'https://example.com/audio1.mp3',
                        size: 32,
                        onSuccess: (message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Demo Track 1 - Click para cachear/remover'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SmartTrackCacheIcon(
                        trackId: 'demo_track_2',
                        audioUrl: 'https://example.com/audio2.mp3',
                        referenceId: 'demo_playlist_123',
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Demo Track 2 - Con referencia de playlist'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Playlist Cache Demo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Playlist Bulk Cache',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PlaylistCacheIcon(
                        playlistId: 'demo_playlist_123',
                        playlistName: 'Demo Playlist',
                        trackUrlPairs: const {
                          'track_1': 'https://example.com/audio1.mp3',
                          'track_2': 'https://example.com/audio2.mp3',
                          'track_3': 'https://example.com/audio3.mp3',
                        },
                        size: 36,
                        onSuccess: (message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Demo Playlist (3 tracks) - Click para operación bulk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Indicators Demo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Indicators',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CacheStatusIndicator(
                        status: CacheStatus.notCached,
                        showLabel: true,
                      ),
                      CacheStatusIndicator(
                        status: CacheStatus.downloading,
                        showLabel: true,
                      ),
                      CacheStatusIndicator(
                        status: CacheStatus.cached,
                        showLabel: true,
                      ),
                      CacheStatusIndicator(
                        status: CacheStatus.failed,
                        showLabel: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Integration Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚀 Cómo integrar en tu app:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Envuelve tu widget con BlocProvider<TrackCacheBloc>\n'
                  '2. Usa SmartTrackCacheIcon en listas de tracks\n'
                  '3. Usa PlaylistCacheIcon en headers de playlist\n'
                  '4. Los BLoCs se inyectan automáticamente via DI',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
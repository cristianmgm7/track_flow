import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:trackflow/features/audio_cache/playlist/presentation/widgets/playlist_cache_icon.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_state.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_event.dart';
import 'package:trackflow/features/audio_cache/playlist/domain/usecases/get_playlist_cache_status_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/value_objects/conflict_policy.dart';

import 'playlist_cache_icon_test.mocks.dart';

@GenerateMocks([PlaylistCacheBloc])
void main() {
  group('PlaylistCacheIcon', () {
    late MockPlaylistCacheBloc mockBloc;

    setUp(() {
      mockBloc = MockPlaylistCacheBloc();
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(mockBloc.state).thenReturn(const PlaylistCacheInitial());
    });

    Widget createWidget({
      String playlistId = 'playlist123',
      Map<String, String>? trackUrlPairs,
      String? playlistName,
      double size = 28.0,
      bool showProgress = true,
      bool showTrackCount = true,
      Function(String)? onSuccess,
      Function(String)? onError,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<PlaylistCacheBloc>.value(
            value: mockBloc,
            child: PlaylistCacheIcon(
              playlistId: playlistId,
              trackUrlPairs: trackUrlPairs ?? {
                'track1': 'https://example.com/audio1.mp3',
                'track2': 'https://example.com/audio2.mp3',
              },
              playlistName: playlistName,
              size: size,
              showProgress: showProgress,
              showTrackCount: showTrackCount,
              onSuccess: onSuccess,
              onError: onError,
            ),
          ),
        ),
      );
    }

    group('initialization', () {
      testWidgets('should request cache stats on init', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));
        await tester.pump(); // Allow post-frame callback to execute

        verify(mockBloc.add(
          GetPlaylistCacheStatsRequested(
            playlistId: 'playlist123',
            trackIds: ['track1', 'track2'],
          ),
        )).called(1);
      });

      testWidgets('should display with correct size', (tester) async {
        const testSize = 32.0;
        
        await tester.pumpWidget(createWidget(size: testSize));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(PlaylistCacheIcon),
            matching: find.byType(Container).first,
          ),
        );

        expect(container.constraints?.maxWidth, testSize + 12);
        expect(container.constraints?.maxHeight, testSize + 12);
      });
    });

    group('state rendering', () {
      testWidgets('should show default icon for initial state', (tester) async {
        when(mockBloc.state).thenReturn(const PlaylistCacheInitial());

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.playlist_add_circle_outlined), findsOneWidget);
      });

      testWidgets('should show loading indicator for loading state', (tester) async {
        when(mockBloc.state).thenReturn(const PlaylistCacheLoading());

        await tester.pumpWidget(createWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show fully cached icon when all tracks cached', (tester) async {
        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 2,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.playlist_add_check_circle), findsOneWidget);
      });

      testWidgets('should show partial cache progress when some tracks cached', (tester) async {
        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 4,
            cachedTracks: 2,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.playlist_add_circle_outlined), findsOneWidget);
      });

      testWidgets('should show downloading indicator when tracks are downloading', (tester) async {
        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 0,
            downloadingTracks: 1,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show error icon when tracks have failed', (tester) async {
        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 0,
            downloadingTracks: 0,
            failedTracks: 1,
          ),
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should show success icon for operation success', (tester) async {
        when(mockBloc.state).thenReturn(const PlaylistCacheOperationSuccess(
          playlistId: 'playlist123',
          message: 'Success',
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should show retry icon for operation failure', (tester) async {
        when(mockBloc.state).thenReturn(const PlaylistCacheOperationFailure(
          playlistId: 'playlist123',
          error: 'Error occurred',
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('track count badge', () {
      testWidgets('should show track count when enabled', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
          'track3': 'https://example.com/audio3.mp3',
        };

        await tester.pumpWidget(createWidget(
          trackUrlPairs: trackUrlPairs,
          showTrackCount: true,
        ));

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should not show track count when disabled', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        await tester.pumpWidget(createWidget(
          trackUrlPairs: trackUrlPairs,
          showTrackCount: false,
        ));

        expect(find.text('2'), findsNothing);
      });
    });

    group('user interactions', () {
      testWidgets('should trigger cache request when tapped on not cached playlist', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 0,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));

        await tester.tap(find.byType(PlaylistCacheIcon));

        verify(mockBloc.add(
          CachePlaylistRequested(
            playlistId: 'playlist123',
            trackUrlPairs: trackUrlPairs,
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });

      testWidgets('should trigger remove request when tapped on fully cached playlist', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 2,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));

        await tester.tap(find.byType(PlaylistCacheIcon));

        verify(mockBloc.add(
          RemovePlaylistCacheRequested(
            playlistId: 'playlist123',
            trackIds: ['track1', 'track2'],
          ),
        )).called(1);
      });

      testWidgets('should trigger cache request when tapped on partially cached playlist', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 1,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));

        await tester.tap(find.byType(PlaylistCacheIcon));

        verify(mockBloc.add(
          CachePlaylistRequested(
            playlistId: 'playlist123',
            trackUrlPairs: trackUrlPairs,
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });

      testWidgets('should retry caching on error state tap', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
        };

        when(mockBloc.state).thenReturn(const PlaylistCacheOperationFailure(
          playlistId: 'playlist123',
          error: 'Network error',
        ));

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));

        await tester.tap(find.byType(PlaylistCacheIcon));

        verify(mockBloc.add(
          CachePlaylistRequested(
            playlistId: 'playlist123',
            trackUrlPairs: trackUrlPairs,
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });
    });

    group('progress display', () {
      testWidgets('should show progress information in progress state', (tester) async {
        when(mockBloc.state).thenReturn(const PlaylistCacheProgress(
          playlistId: 'playlist123',
          completedTracks: 2,
          totalTracks: 5,
          currentTrackProgress: 0.5,
        ));

        await tester.pumpWidget(createWidget());

        expect(find.text('2/5'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('should be tappable', (tester) async {
        await tester.pumpWidget(createWidget());

        final inkWell = find.byType(InkWell);
        expect(inkWell, findsOneWidget);

        await tester.tap(inkWell);
        // Should not throw exception
      });

      testWidgets('should have proper hit area', (tester) async {
        const testSize = 28.0;
        
        await tester.pumpWidget(createWidget(size: testSize));

        final containerSize = tester.getSize(find.byType(Container).first);
        expect(containerSize.width, testSize + 12);
        expect(containerSize.height, testSize + 12);
      });
    });

    group('animations', () {
      testWidgets('should animate when tapped', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(PlaylistCacheIcon));
        await tester.pump(const Duration(milliseconds: 100));

        // Animation should be in progress
        final animatedBuilder = find.byType(AnimatedBuilder);
        expect(animatedBuilder, findsOneWidget);
      });
    });

    group('snackbar actions', () {
      testWidgets('should show snackbar when removing fully cached playlist', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 2,
            cachedTracks: 2,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(
          trackUrlPairs: trackUrlPairs,
          playlistName: 'Test Playlist',
        ));

        await tester.tap(find.byType(PlaylistCacheIcon));
        await tester.pump(); // Process the tap
        await tester.pump(); // Process the snackbar

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test Playlist (2 tracks) removed from cache'), findsOneWidget);
        expect(find.text('UNDO'), findsOneWidget);
      });

      testWidgets('should handle undo action', (tester) async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
        };

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 1,
            cachedTracks: 1,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(trackUrlPairs: trackUrlPairs));

        // Tap to remove
        await tester.tap(find.byType(PlaylistCacheIcon));
        await tester.pump();
        await tester.pump();

        // Tap undo
        await tester.tap(find.text('UNDO'));

        verify(mockBloc.add(
          CachePlaylistRequested(
            playlistId: 'playlist123',
            trackUrlPairs: trackUrlPairs,
            policy: ConflictPolicy.lastWins,
          ),
        )).called(2); // Once for undo, plus original call
      });
    });

    group('edge cases', () {
      testWidgets('should handle empty track list', (tester) async {
        await tester.pumpWidget(createWidget(trackUrlPairs: {}));

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('should handle null playlist name', (tester) async {
        final trackUrlPairs = {'track1': 'url1'};

        when(mockBloc.state).thenReturn(PlaylistCacheStatsLoaded(
          playlistId: 'playlist123',
          stats: PlaylistCacheStats(
            totalTracks: 1,
            cachedTracks: 1,
            downloadingTracks: 0,
            failedTracks: 0,
          ),
        ));

        await tester.pumpWidget(createWidget(
          trackUrlPairs: trackUrlPairs,
          playlistName: null,
        ));

        await tester.tap(find.byType(PlaylistCacheIcon));
        await tester.pump();
        await tester.pump();

        expect(find.text('Playlist (1 tracks) removed from cache'), findsOneWidget);
      });
    });
  });
}
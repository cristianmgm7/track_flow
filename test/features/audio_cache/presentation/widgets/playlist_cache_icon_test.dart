import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:trackflow/features/audio_cache/playlist/presentation/widgets/playlist_cache_icon.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_state.dart';
import 'package:trackflow/features/audio_cache/playlist/presentation/bloc/playlist_cache_event.dart';
import 'package:trackflow/features/audio_cache/playlist/domain/entities/playlist_cache_stats.dart';

import 'playlist_cache_icon_test.mocks.dart';

@GenerateMocks([PlaylistCacheBloc])
void main() {
  // Provide dummy values for PlaylistCacheState subtypes
  provideDummy<PlaylistCacheState>(const PlaylistCacheInitial());
  provideDummy<PlaylistCacheInitial>(const PlaylistCacheInitial());
  provideDummy<PlaylistCacheLoading>(const PlaylistCacheLoading());
  provideDummy<PlaylistCacheStatusLoaded>(const PlaylistCacheStatusLoaded(
    trackStatuses: {},
  ));
  provideDummy<PlaylistCacheStatsLoaded>(const PlaylistCacheStatsLoaded(
    stats: PlaylistCacheStats(
      playlistId: 'dummy',
      totalTracks: 0,
      cachedTracks: 0,
      downloadingTracks: 0,
      failedTracks: 0,
      cachePercentage: 0.0,
    ),
    detailedProgress: {},
  ));
  provideDummy<PlaylistCacheOperationSuccess>(const PlaylistCacheOperationSuccess(
    playlistId: 'dummy',
    message: 'dummy',
  ));
  provideDummy<PlaylistCacheOperationFailure>(const PlaylistCacheOperationFailure(
    playlistId: 'dummy',
    error: 'dummy',
  ));
  
  group('PlaylistCacheIcon', () {
    late MockPlaylistCacheBloc mockBloc;

    setUp(() {
      mockBloc = MockPlaylistCacheBloc();
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(mockBloc.state).thenReturn(const PlaylistCacheInitial());
    });

    Widget createWidget({
      String playlistId = 'playlist123',
      List<String> trackIds = const ['track1', 'track2'],
      double size = 28.0,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<PlaylistCacheBloc>.value(
            value: mockBloc,
            child: PlaylistCacheIcon(
              playlistId: playlistId,
              trackIds: trackIds,
              size: size,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    group('initialization', () {
      testWidgets(
        'should display correctly when BlocProvider is available',
        (tester) async {
          // This test verifies that the widget can be used with a BlocProvider
          await tester.pumpWidget(createWidget());

          // Should display the widget without errors
          expect(find.byType(PlaylistCacheIcon), findsOneWidget);
        },
      );

      testWidgets('should display with correct size', (tester) async {
        const testSize = 32.0;

        await tester.pumpWidget(createWidget(size: testSize));

        // Find the icon widget
        final iconFinder = find.byType(Icon);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<Icon>(iconFinder);
        expect(icon.size, testSize);
      });
    });

    group('state rendering', () {
      testWidgets('should show default icon for initial state', (tester) async {
        await tester.pumpWidget(createWidget());

        // Should show cloud_off icon for initial state
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      });

      testWidgets('should show loading indicator for loading state', (
        tester,
      ) async {
        // Set the bloc state to loading
        when(mockBloc.state).thenReturn(const PlaylistCacheLoading());

        await tester.pumpWidget(createWidget());

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('user interactions', () {
      testWidgets('should be tappable', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(createWidget(onTap: () => tapped = true));

        await tester.tap(find.byType(PlaylistCacheIcon));

        expect(tapped, isTrue);
      });

      testWidgets('should have proper hit area', (tester) async {
        const testSize = 28.0;

        await tester.pumpWidget(createWidget(size: testSize));

        // Should be tappable
        await tester.tap(find.byType(PlaylistCacheIcon));
        // Should not throw exception
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible', (tester) async {
        await tester.pumpWidget(createWidget());

        // Should be tappable
        final gestureDetector = find.byType(GestureDetector);
        expect(gestureDetector, findsOneWidget);
      });
    });
  });
}

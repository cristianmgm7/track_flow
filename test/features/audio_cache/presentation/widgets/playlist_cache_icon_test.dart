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
          body: PlaylistCacheIcon(
            playlistId: playlistId,
            trackIds: trackIds,
            size: size,
            onTap: onTap,
          ),
        ),
      );
    }

    group('initialization', () {
      testWidgets(
        'should create its own BlocProvider and not throw ProviderNotFoundException',
        (tester) async {
          // This test verifies that the widget can be used without an external BlocProvider
          await tester.pumpWidget(createWidget());

          // Should not throw ProviderNotFoundException
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
        await tester.pumpWidget(createWidget());

        // The widget should automatically request detailed progress on init
        // which should trigger loading state
        await tester.pump();

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

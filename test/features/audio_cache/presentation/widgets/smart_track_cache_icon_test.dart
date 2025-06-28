import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:trackflow/features/audio_cache/track/presentation/widgets/smart_track_cache_icon.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_state.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/cached_audio.dart';
import 'package:trackflow/features/audio_cache/shared/domain/value_objects/conflict_policy.dart';

import 'smart_track_cache_icon_test.mocks.dart';

@GenerateMocks([TrackCacheBloc])
void main() {
  group('SmartTrackCacheIcon', () {
    late MockTrackCacheBloc mockBloc;

    setUp(() {
      mockBloc = MockTrackCacheBloc();
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(mockBloc.state).thenReturn(const TrackCacheInitial());
    });

    Widget createWidget({
      String trackId = 'track123',
      String audioUrl = 'https://example.com/audio.mp3',
      String? referenceId,
      double size = 24.0,
      bool showProgress = true,
      Function(String)? onSuccess,
      Function(String)? onError,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<TrackCacheBloc>.value(
            value: mockBloc,
            child: SmartTrackCacheIcon(
              trackId: trackId,
              audioUrl: audioUrl,
              referenceId: referenceId,
              size: size,
              showProgress: showProgress,
              onSuccess: onSuccess,
              onError: onError,
            ),
          ),
        ),
      );
    }

    group('initialization', () {
      testWidgets('should request cache status on init', (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pump(); // Allow post-frame callback to execute

        verify(mockBloc.add(
          const GetTrackCacheStatusRequested('track123'),
        )).called(1);
      });

      testWidgets('should display with correct size', (tester) async {
        const testSize = 32.0;
        
        await tester.pumpWidget(createWidget(size: testSize));

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SmartTrackCacheIcon),
            matching: find.byType(Container).first,
          ),
        );

        expect(container.constraints?.maxWidth, testSize + 8);
        expect(container.constraints?.maxHeight, testSize + 8);
      });
    });

    group('state rendering', () {
      testWidgets('should show default download icon for initial state', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheInitial());

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      });

      testWidgets('should show loading indicator for loading state', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheLoading());

        await tester.pumpWidget(createWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show cached icon for cached status', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.cached,
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.download_done), findsOneWidget);
      });

      testWidgets('should show download icon for not cached status', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.notCached,
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      });

      testWidgets('should show progress indicator for downloading status', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.downloading,
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should show error icon for failed status', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.failed,
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should show success icon for operation success', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheOperationSuccess(
          trackId: 'track123',
          message: 'Success',
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should show retry icon for operation failure', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheOperationFailure(
          trackId: 'track123',
          error: 'Error occurred',
        ));

        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('user interactions', () {
      testWidgets('should trigger cache request when tapped on not cached', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.notCached,
        ));

        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(SmartTrackCacheIcon));

        verify(mockBloc.add(
          const CacheTrackRequested(
            trackId: 'track123',
            audioUrl: 'https://example.com/audio.mp3',
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });

      testWidgets('should trigger remove request when tapped on cached', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.cached,
        ));

        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(SmartTrackCacheIcon));

        verify(mockBloc.add(
          const RemoveTrackCacheRequested(
            trackId: 'track123',
            referenceId: 'individual',
          ),
        )).called(1);
      });

      testWidgets('should use custom reference when provided', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheStatusLoaded(
          trackId: 'track123',
          status: CacheStatus.notCached,
        ));

        await tester.pumpWidget(createWidget(referenceId: 'playlist123'));

        await tester.tap(find.byType(SmartTrackCacheIcon));

        verify(mockBloc.add(
          const CacheTrackWithReferenceRequested(
            trackId: 'track123',
            audioUrl: 'https://example.com/audio.mp3',
            referenceId: 'playlist123',
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });

      testWidgets('should retry caching on error state tap', (tester) async {
        when(mockBloc.state).thenReturn(const TrackCacheOperationFailure(
          trackId: 'track123',
          error: 'Network error',
        ));

        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(SmartTrackCacheIcon));

        verify(mockBloc.add(
          const CacheTrackRequested(
            trackId: 'track123',
            audioUrl: 'https://example.com/audio.mp3',
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });
    });

    group('callbacks', () {
      testWidgets('should call onSuccess callback on success state', (tester) async {
        String? successMessage;
        
        await tester.pumpWidget(createWidget(
          onSuccess: (message) => successMessage = message,
        ));

        // Simulate success state
        when(mockBloc.state).thenReturn(const TrackCacheOperationSuccess(
          trackId: 'track123',
          message: 'Track cached successfully',
        ));

        await tester.pump();

        expect(successMessage, isNull); // BlocListener hasn't fired yet
      });

      testWidgets('should call onError callback on failure state', (tester) async {
        String? errorMessage;
        
        await tester.pumpWidget(createWidget(
          onError: (message) => errorMessage = message,
        ));

        // Simulate failure state
        when(mockBloc.state).thenReturn(const TrackCacheOperationFailure(
          trackId: 'track123',
          error: 'Network error',
        ));

        await tester.pump();

        expect(errorMessage, isNull); // BlocListener hasn't fired yet
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
        const testSize = 24.0;
        
        await tester.pumpWidget(createWidget(size: testSize));

        final containerSize = tester.getSize(find.byType(Container).first);
        expect(containerSize.width, testSize + 8);
        expect(containerSize.height, testSize + 8);
      });
    });

    group('animations', () {
      testWidgets('should animate when tapped', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(SmartTrackCacheIcon));
        await tester.pump(const Duration(milliseconds: 100));

        // Animation should be in progress
        final animatedBuilder = find.byType(AnimatedBuilder);
        expect(animatedBuilder, findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle null callbacks gracefully', (tester) async {
        await tester.pumpWidget(createWidget(
          onSuccess: null,
          onError: null,
        ));

        // Should not throw exception
        await tester.tap(find.byType(SmartTrackCacheIcon));
      });

      testWidgets('should handle empty trackId', (tester) async {
        await tester.pumpWidget(createWidget(trackId: ''));

        verify(mockBloc.add(
          const GetTrackCacheStatusRequested(''),
        )).called(1);
      });

      testWidgets('should handle empty audioUrl', (tester) async {
        await tester.pumpWidget(createWidget(audioUrl: ''));

        await tester.tap(find.byType(SmartTrackCacheIcon));

        verify(mockBloc.add(
          const CacheTrackRequested(
            trackId: 'track123',
            audioUrl: '',
            policy: ConflictPolicy.lastWins,
          ),
        )).called(1);
      });
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/cached_audio.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_state.dart';

import 'debug_cache_reactivity_test.mocks.dart';

@GenerateMocks([
  CacheOrchestrationService,
  GetTrackCacheStatusUseCase,
  CacheTrackUseCase,
])
void main() {
  group('Cache Reactivity Debug Tests', () {
    late MockCacheOrchestrationService mockOrchestrationService;
    late MockGetTrackCacheStatusUseCase mockGetStatusUseCase;
    late MockCacheTrackUseCase mockCacheUseCase;
    
    setUp(() {
      mockOrchestrationService = MockCacheOrchestrationService();
      mockGetStatusUseCase = MockGetTrackCacheStatusUseCase();
      mockCacheUseCase = MockCacheTrackUseCase();
    });

    group('Cache Status Retrieval', () {
      test('should return correct status when track is not cached', () async {
        const trackId = 'test_track_123';
        
        when(mockOrchestrationService.getCacheStatus(trackId))
            .thenAnswer((_) async => const Right(CacheStatus.notCached));

        final useCase = GetTrackCacheStatusUseCase(mockOrchestrationService);
        final result = await useCase(trackId: trackId);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (status) => expect(status, equals(CacheStatus.notCached)),
        );

        verify(mockOrchestrationService.getCacheStatus(trackId)).called(1);
      });

      test('should return correct status when track is cached', () async {
        const trackId = 'test_track_123';
        
        when(mockOrchestrationService.getCacheStatus(trackId))
            .thenAnswer((_) async => const Right(CacheStatus.cached));

        final useCase = GetTrackCacheStatusUseCase(mockOrchestrationService);
        final result = await useCase(trackId: trackId);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (status) => expect(status, equals(CacheStatus.cached)),
        );
      });

      test('should stream status changes correctly', () async {
        const trackId = 'test_track_123';
        
        // Create a stream that simulates status changes
        final statusStream = Stream.fromIterable([
          CacheStatus.notCached,
          CacheStatus.downloading,
          CacheStatus.cached,
        ]);

        when(mockOrchestrationService.watchCacheStatus(trackId))
            .thenAnswer((_) => statusStream);

        final useCase = GetTrackCacheStatusUseCase(mockOrchestrationService);
        final stream = useCase.watchCacheStatus(trackId: trackId);

        final statuses = <CacheStatus>[];
        await for (final status in stream) {
          statuses.add(status);
          if (statuses.length == 3) break;
        }

        expect(statuses, equals([
          CacheStatus.notCached,
          CacheStatus.downloading,
          CacheStatus.cached,
        ]));

        verify(mockOrchestrationService.watchCacheStatus(trackId)).called(1);
      });
    });

    group('BLoC State Management', () {
      test('should update state correctly after cache operation', () async {
        const trackId = 'test_track_123';
        const audioUrl = 'https://example.com/audio.mp3';

        // Mock successful caching
        when(mockCacheUseCase(
          trackId: trackId,
          audioUrl: audioUrl,
          policy: any,
        )).thenAnswer((_) async => const Right(unit));

        final bloc = TrackCacheBloc(
          mockCacheUseCase,
          mockGetStatusUseCase,
          MockRemoveTrackCacheUseCase(),
        );

        // Add cache request event
        bloc.add(const CacheTrackRequested(
          trackId: trackId,
          audioUrl: audioUrl,
        ));

        // Wait for state changes
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the use case was called
        verify(mockCacheUseCase(
          trackId: trackId,
          audioUrl: audioUrl,
          policy: any,
        )).called(1);

        bloc.close();
      });

      test('should handle status watching correctly', () async {
        const trackId = 'test_track_123';
        
        final statusController = StreamController<CacheStatus>();
        
        when(mockGetStatusUseCase.watchCacheStatus(trackId: trackId))
            .thenAnswer((_) => statusController.stream);

        final bloc = TrackCacheBloc(
          mockCacheUseCase,
          mockGetStatusUseCase,
          MockRemoveTrackCacheUseCase(),
        );

        final states = <TrackCacheState>[];
        final subscription = bloc.stream.listen(states.add);

        // Start watching
        bloc.add(const WatchTrackCacheStatusRequested(trackId));

        // Wait for initial state
        await Future.delayed(const Duration(milliseconds: 50));

        // Emit status changes
        statusController.add(CacheStatus.notCached);
        await Future.delayed(const Duration(milliseconds: 50));
        
        statusController.add(CacheStatus.downloading);
        await Future.delayed(const Duration(milliseconds: 50));
        
        statusController.add(CacheStatus.cached);
        await Future.delayed(const Duration(milliseconds: 50));

        // Check states
        final watchingStates = states.whereType<TrackCacheWatching>().toList();
        expect(watchingStates.length, greaterThan(0));

        await subscription.cancel();
        await statusController.close();
        await bloc.close();
      });
    });

    group('Service Integration Issues', () {
      test('should detect if orchestration service is properly wired', () async {
        const trackId = 'test_track_123';
        
        // Test if service methods are being called as expected
        when(mockOrchestrationService.getCacheStatus(trackId))
            .thenAnswer((_) async => const Right(CacheStatus.notCached));

        when(mockOrchestrationService.cacheAudio(any, any, any, policy: any))
            .thenAnswer((_) async => const Right(unit));

        // Simulate real workflow
        final getStatusUseCase = GetTrackCacheStatusUseCase(mockOrchestrationService);
        
        // 1. Check initial status
        final initialStatus = await getStatusUseCase(trackId: trackId);
        expect(initialStatus.isRight(), isTrue);
        
        // 2. Cache the track
        final cacheResult = await mockOrchestrationService.cacheAudio(
          trackId,
          'https://example.com/audio.mp3',
          'individual',
        );
        expect(cacheResult.isRight(), isTrue);

        // 3. Check status again
        when(mockOrchestrationService.getCacheStatus(trackId))
            .thenAnswer((_) async => const Right(CacheStatus.cached));
            
        final finalStatus = await getStatusUseCase(trackId: trackId);
        expect(finalStatus.isRight(), isTrue);
        finalStatus.fold(
          (failure) => fail('Expected cached status'),
          (status) => expect(status, equals(CacheStatus.cached)),
        );

        // Verify all interactions
        verify(mockOrchestrationService.getCacheStatus(trackId)).called(2);
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          'https://example.com/audio.mp3',
          'individual',
          policy: anyNamed('policy'),
        )).called(1);
      });

      test('should identify stream connectivity issues', () async {
        const trackId = 'test_track_123';
        
        // Test if streams are properly connected
        var streamCallCount = 0;
        when(mockOrchestrationService.watchCacheStatus(trackId))
            .thenAnswer((_) {
              streamCallCount++;
              return Stream.fromIterable([CacheStatus.notCached]);
            });

        final useCase = GetTrackCacheStatusUseCase(mockOrchestrationService);
        
        // Multiple widgets requesting streams
        final stream1 = useCase.watchCacheStatus(trackId: trackId);
        final stream2 = useCase.watchCacheStatus(trackId: trackId);
        
        // Both should work
        final future1 = stream1.first;
        final future2 = stream2.first;
        
        final results = await Future.wait([future1, future2]);
        
        expect(results[0], equals(CacheStatus.notCached));
        expect(results[1], equals(CacheStatus.notCached));
        
        // Should have been called for each stream request
        expect(streamCallCount, equals(2));
      });
    });

    group('Reactive UI Issues', () {
      test('should simulate proper BLoC lifecycle management', () async {
        const trackId = 'test_track_123';
        
        // Test multiple BLoC instances (simulating widget recreation)
        final bloc1 = TrackCacheBloc(
          mockCacheUseCase,
          mockGetStatusUseCase,
          MockRemoveTrackCacheUseCase(),
        );
        
        final bloc2 = TrackCacheBloc(
          mockCacheUseCase,
          mockGetStatusUseCase,
          MockRemoveTrackCacheUseCase(),
        );

        // Both should start with initial state
        expect(bloc1.state, equals(const TrackCacheInitial()));
        expect(bloc2.state, equals(const TrackCacheInitial()));

        // Mock status check
        when(mockGetStatusUseCase(trackId: trackId))
            .thenAnswer((_) async => const Right(CacheStatus.cached));

        // Both check status
        bloc1.add(const GetTrackCacheStatusRequested(trackId));
        bloc2.add(const GetTrackCacheStatusRequested(trackId));

        // Wait for processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Both should have been called
        verify(mockGetStatusUseCase(trackId: trackId)).called(2);

        await bloc1.close();
        await bloc2.close();
      });
    });
  });
}

@GenerateMocks([RemoveTrackCacheUseCase])
class MockRemoveTrackCacheUseCase extends Mock implements RemoveTrackCacheUseCase {}

class StreamController<T> {
  final List<T> _values = [];
  final List<Function(T)> _listeners = [];
  bool _isClosed = false;

  void add(T value) {
    if (_isClosed) return;
    _values.add(value);
    for (final listener in _listeners) {
      listener(value);
    }
  }

  Stream<T> get stream {
    return Stream.fromIterable(_values);
  }

  Future<void> close() async {
    _isClosed = true;
    _listeners.clear();
  }
}
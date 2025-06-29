import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_state.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_track_cache_status_usecase.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/remove_track_cache_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/cached_audio.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/download_progress.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/track_cache_info.dart';
import 'package:trackflow/features/audio_cache/shared/domain/failures/cache_failure.dart';
import 'package:trackflow/features/audio_cache/shared/domain/value_objects/conflict_policy.dart';

import 'track_cache_bloc_test.mocks.dart';

@GenerateMocks([
  CacheTrackUseCase,
  GetTrackCacheStatusUseCase,
  RemoveTrackCacheUseCase,
])
void main() {
  group('TrackCacheBloc', () {
    late TrackCacheBloc bloc;
    late MockCacheTrackUseCase mockCacheTrackUseCase;
    late MockGetTrackCacheStatusUseCase mockGetTrackCacheStatusUseCase;
    late MockRemoveTrackCacheUseCase mockRemoveTrackCacheUseCase;

    setUp(() {
      mockCacheTrackUseCase = MockCacheTrackUseCase();
      mockGetTrackCacheStatusUseCase = MockGetTrackCacheStatusUseCase();
      mockRemoveTrackCacheUseCase = MockRemoveTrackCacheUseCase();

      bloc = TrackCacheBloc(
        mockCacheTrackUseCase,
        mockGetTrackCacheStatusUseCase,
        mockRemoveTrackCacheUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TrackCacheInitial', () {
      expect(bloc.state, equals(const TrackCacheInitial()));
    });

    group('CacheTrackRequested', () {
      const trackId = 'track123';
      const audioUrl = 'https://example.com/audio.mp3';
      const policy = ConflictPolicy.lastWins;

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, success] when cache track succeeds',
        build: () {
          when(
            mockCacheTrackUseCase(
              trackId: trackId,
              audioUrl: audioUrl,
              policy: policy,
            ),
          ).thenAnswer((_) async => const Right(unit));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackRequested(
                trackId: trackId,
                audioUrl: audioUrl,
                policy: policy,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationSuccess(
                trackId: trackId,
                message: 'Track cached successfully',
              ),
            ],
        verify: (_) {
          verify(
            mockCacheTrackUseCase(
              trackId: trackId,
              audioUrl: audioUrl,
              policy: policy,
            ),
          ).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when cache track fails',
        build: () {
          const failure = ValidationCacheFailure(
            message: 'Invalid URL',
            field: 'audioUrl',
            value: audioUrl,
          );
          when(
            mockCacheTrackUseCase(
              trackId: trackId,
              audioUrl: audioUrl,
              policy: policy,
            ),
          ).thenAnswer((_) async => const Left(failure));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackRequested(
                trackId: trackId,
                audioUrl: audioUrl,
                policy: policy,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Invalid URL',
              ),
            ],
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when exception occurs',
        build: () {
          when(
            mockCacheTrackUseCase(
              trackId: trackId,
              audioUrl: audioUrl,
              policy: policy,
            ),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackRequested(
                trackId: trackId,
                audioUrl: audioUrl,
                policy: policy,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Unexpected error: Exception: Network error',
              ),
            ],
      );
    });

    group('CacheTrackWithReferenceRequested', () {
      const trackId = 'track123';
      const audioUrl = 'https://example.com/audio.mp3';
      const referenceId = 'playlist123';
      const policy = ConflictPolicy.firstWins;

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, success] when cache track with reference succeeds',
        build: () {
          when(
            mockCacheTrackUseCase.cacheWithReference(
              trackId: trackId,
              audioUrl: audioUrl,
              referenceId: referenceId,
              policy: policy,
            ),
          ).thenAnswer((_) async => const Right(unit));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackWithReferenceRequested(
                trackId: trackId,
                audioUrl: audioUrl,
                referenceId: referenceId,
                policy: policy,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationSuccess(
                trackId: trackId,
                message: 'Track cached with reference successfully',
              ),
            ],
        verify: (_) {
          verify(
            mockCacheTrackUseCase.cacheWithReference(
              trackId: trackId,
              audioUrl: audioUrl,
              referenceId: referenceId,
              policy: policy,
            ),
          ).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when cache track with reference fails',
        build: () {
          const failure = ValidationCacheFailure(
            message: 'Reference ID cannot be empty',
            field: 'referenceId',
            value: '',
          );
          when(
            mockCacheTrackUseCase.cacheWithReference(
              trackId: trackId,
              audioUrl: audioUrl,
              referenceId: referenceId,
              policy: policy,
            ),
          ).thenAnswer((_) async => const Left(failure));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackWithReferenceRequested(
                trackId: trackId,
                audioUrl: audioUrl,
                referenceId: referenceId,
                policy: policy,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Reference ID cannot be empty',
              ),
            ],
      );
    });

    group('RemoveTrackCacheRequested', () {
      const trackId = 'track123';
      const referenceId = 'individual';

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, success] when remove track cache succeeds',
        build: () {
          when(
            mockRemoveTrackCacheUseCase(
              trackId: trackId,
              referenceId: referenceId,
            ),
          ).thenAnswer((_) async => const Right(unit));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const RemoveTrackCacheRequested(
                trackId: trackId,
                referenceId: referenceId,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationSuccess(
                trackId: trackId,
                message: 'Track removed from cache successfully',
              ),
            ],
        verify: (_) {
          verify(
            mockRemoveTrackCacheUseCase(
              trackId: trackId,
              referenceId: referenceId,
            ),
          ).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when remove track cache fails',
        build: () {
          const failure = ValidationCacheFailure(
            message: 'Track not found',
            field: 'trackId',
            value: trackId,
          );
          when(
            mockRemoveTrackCacheUseCase(
              trackId: trackId,
              referenceId: referenceId,
            ),
          ).thenAnswer((_) async => const Left(failure));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const RemoveTrackCacheRequested(
                trackId: trackId,
                referenceId: referenceId,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Track not found',
              ),
            ],
      );
    });

    group('GetTrackCacheStatusRequested', () {
      const trackId = 'track123';

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, status loaded] when get status succeeds',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase(trackId: trackId),
          ).thenAnswer((_) async => const Right(CacheStatus.cached));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetTrackCacheStatusRequested(trackId)),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: trackId,
                status: CacheStatus.cached,
              ),
            ],
        verify: (_) {
          verify(mockGetTrackCacheStatusUseCase(trackId: trackId)).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when get status fails',
        build: () {
          const failure = StorageCacheFailure(
            message: 'Database error',
            type: StorageFailureType.diskError,
          );
          when(
            mockGetTrackCacheStatusUseCase(trackId: trackId),
          ).thenAnswer((_) async => const Left(failure));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetTrackCacheStatusRequested(trackId)),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Database error',
              ),
            ],
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should handle different cache statuses correctly',
        build: () => bloc,
        act: (bloc) async {
          // Test not cached
          when(
            mockGetTrackCacheStatusUseCase(trackId: trackId),
          ).thenAnswer((_) async => const Right(CacheStatus.notCached));
          bloc.add(const GetTrackCacheStatusRequested(trackId));

          await Future.delayed(const Duration(milliseconds: 10));

          // Test downloading
          when(
            mockGetTrackCacheStatusUseCase(trackId: trackId),
          ).thenAnswer((_) async => const Right(CacheStatus.downloading));
          bloc.add(const GetTrackCacheStatusRequested(trackId));

          await Future.delayed(const Duration(milliseconds: 10));

          // Test failed
          when(
            mockGetTrackCacheStatusUseCase(trackId: trackId),
          ).thenAnswer((_) async => const Right(CacheStatus.failed));
          bloc.add(const GetTrackCacheStatusRequested(trackId));
        },
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: trackId,
                status: CacheStatus.notCached,
              ),
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: trackId,
                status: CacheStatus.downloading,
              ),
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: trackId,
                status: CacheStatus.failed,
              ),
            ],
      );
    });

    group('GetCachedTrackPathRequested', () {
      const trackId = 'track123';
      const filePath = '/path/to/cached/audio.mp3';

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, path loaded] when get cached path succeeds',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase.getCachedAudioPath(trackId: trackId),
          ).thenAnswer((_) async => const Right(filePath));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetCachedTrackPathRequested(trackId)),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCachePathLoaded(trackId: trackId, filePath: filePath),
            ],
        verify: (_) {
          verify(
            mockGetTrackCacheStatusUseCase.getCachedAudioPath(trackId: trackId),
          ).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit [loading, failure] when get cached path fails',
        build: () {
          const failure = StorageCacheFailure(
            message: 'File not found',
            type: StorageFailureType.fileNotFound,
          );
          when(
            mockGetTrackCacheStatusUseCase.getCachedAudioPath(trackId: trackId),
          ).thenAnswer((_) async => const Left(failure));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetCachedTrackPathRequested(trackId)),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'File not found',
              ),
            ],
      );
    });

    group('WatchTrackCacheInfoRequested', () {
      const trackId = 'track123';

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit watching state and handle unified info stream',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase.watchTrackCacheInfo(
              trackId: trackId,
            ),
          ).thenAnswer(
            (_) => Stream.fromIterable([
              TrackCacheInfo(
                trackId: trackId,
                status: CacheStatus.notCached,
                progress: DownloadProgress.notStarted(trackId),
              ),
              TrackCacheInfo(
                trackId: trackId,
                status: CacheStatus.downloading,
                progress: DownloadProgress.queued(trackId),
              ),
              TrackCacheInfo(
                trackId: trackId,
                status: CacheStatus.cached,
                progress: DownloadProgress.completed(trackId, 1024),
              ),
            ]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const WatchTrackCacheInfoRequested(trackId)),
        expect:
            () => [
              const TrackCacheInfoWatching(
                trackId: trackId,
                status: CacheStatus.notCached,
                progress: DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.notStarted,
                  downloadedBytes: 0,
                  totalBytes: 0,
                ),
              ),
              const TrackCacheInfoWatching(
                trackId: trackId,
                status: CacheStatus.notCached,
                progress: DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.notStarted,
                  downloadedBytes: 0,
                  totalBytes: 0,
                ),
              ),
              const TrackCacheInfoWatching(
                trackId: trackId,
                status: CacheStatus.downloading,
                progress: DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.queued,
                  downloadedBytes: 0,
                  totalBytes: 0,
                ),
              ),
              const TrackCacheInfoWatching(
                trackId: trackId,
                status: CacheStatus.cached,
                progress: DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.completed,
                  downloadedBytes: 1024,
                  totalBytes: 1024,
                ),
              ),
            ],
        verify: (_) {
          verify(
            mockGetTrackCacheStatusUseCase.watchTrackCacheInfo(
              trackId: trackId,
            ),
          ).called(1);
        },
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should emit failure when stream has error',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase.watchTrackCacheInfo(
              trackId: trackId,
            ),
          ).thenAnswer((_) => Stream.error('Stream error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const WatchTrackCacheInfoRequested(trackId)),
        expect:
            () => [
              const TrackCacheInfoWatching(
                trackId: trackId,
                status: CacheStatus.notCached,
                progress: DownloadProgress(
                  trackId: trackId,
                  state: DownloadState.notStarted,
                  downloadedBytes: 0,
                  totalBytes: 0,
                ),
              ),
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Track info watch error: Stream error',
              ),
            ],
      );

      blocTest<TrackCacheBloc, TrackCacheState>(
        'should handle exceptions when starting watch',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase.watchTrackCacheInfo(
              trackId: trackId,
            ),
          ).thenThrow(Exception('Watch error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const WatchTrackCacheInfoRequested(trackId)),
        expect:
            () => [
              const TrackCacheOperationFailure(
                trackId: trackId,
                error: 'Failed to start watching: Exception: Watch error',
              ),
            ],
      );
    });

    group('StopWatchingTrackCacheInfo', () {
      blocTest<TrackCacheBloc, TrackCacheState>(
        'should stop watching and emit initial state',
        build: () => bloc,
        act: (bloc) => bloc.add(const StopWatchingTrackCacheInfo()),
        expect: () => [const TrackCacheInitial()],
      );
    });

    group('error handling', () {
      blocTest<TrackCacheBloc, TrackCacheState>(
        'should handle unexpected exceptions gracefully',
        build: () {
          when(
            mockCacheTrackUseCase(
              trackId: anyNamed('trackId'),
              audioUrl: anyNamed('audioUrl'),
              policy: anyNamed('policy'),
            ),
          ).thenThrow(StateError('Unexpected state error'));
          return bloc;
        },
        act:
            (bloc) => bloc.add(
              const CacheTrackRequested(
                trackId: 'track123',
                audioUrl: 'https://example.com/audio.mp3',
                policy: ConflictPolicy.lastWins,
              ),
            ),
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheOperationFailure(
                trackId: 'track123',
                error: 'Unexpected error: Bad state: Unexpected state error',
              ),
            ],
      );
    });

    group('concurrent operations', () {
      blocTest<TrackCacheBloc, TrackCacheState>(
        'should handle multiple consecutive requests',
        build: () {
          when(
            mockGetTrackCacheStatusUseCase(trackId: 'track1'),
          ).thenAnswer((_) async => const Right(CacheStatus.cached));
          when(
            mockGetTrackCacheStatusUseCase(trackId: 'track2'),
          ).thenAnswer((_) async => const Right(CacheStatus.notCached));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const GetTrackCacheStatusRequested('track1'));
          await Future.delayed(const Duration(milliseconds: 10));
          bloc.add(const GetTrackCacheStatusRequested('track2'));
        },
        expect:
            () => [
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: 'track1',
                status: CacheStatus.cached,
              ),
              const TrackCacheLoading(),
              const TrackCacheStatusLoaded(
                trackId: 'track2',
                status: CacheStatus.notCached,
              ),
            ],
      );
    });
  });
}

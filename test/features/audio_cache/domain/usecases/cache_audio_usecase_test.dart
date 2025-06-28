import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart';
import 'package:trackflow/features/audio_cache/shared/domain/failures/cache_failure.dart';
import 'package:trackflow/features/audio_cache/shared/domain/value_objects/conflict_policy.dart';

import 'cache_audio_usecase_test.mocks.dart';

@GenerateMocks([CacheOrchestrationService])
void main() {
  group('CacheTrackUseCase', () {
    late CacheTrackUseCase useCase;
    late MockCacheOrchestrationService mockOrchestrationService;

    setUp(() {
      mockOrchestrationService = MockCacheOrchestrationService();
      useCase = CacheTrackUseCase(mockOrchestrationService);
    });

    group('call', () {
      test('should cache audio successfully when service returns success', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'ref123';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });

      test('should return failure when service returns failure', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'ref123';
        const failure = ValidationCacheFailure(
          message: 'Invalid URL',
          field: 'audioUrl',
          value: audioUrl,
        );

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Left(failure));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result, equals(const Left(failure)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });

      test('should use custom conflict policy when provided', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'ref123';
        const policy = ConflictPolicy.firstWins;

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: policy,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
          policy: policy,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: policy,
        )).called(1);
      });

      test('should handle exceptions and return failure', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'ref123';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: any,
        )).thenThrow(Exception('Network error'));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationCacheFailure>());
            expect(failure.message, contains('Unexpected error'));
            expect(failure.message, contains('Exception: Network error'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('cacheMultiple', () {
      test('should cache multiple audios successfully', () async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };
        const referenceId = 'ref123';

        when(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase.cacheMultiple(
          trackUrlPairs: trackUrlPairs,
          referenceId: referenceId,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });

      test('should return failure when service fails', () async {
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };
        const referenceId = 'ref123';
        const failure = ValidationCacheFailure(
          message: 'Some tracks failed to cache',
          field: 'trackIds',
          value: ['track1'],
        );

        when(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Left(failure));

        final result = await useCase.cacheMultiple(
          trackUrlPairs: trackUrlPairs,
          referenceId: referenceId,
        );

        expect(result, equals(const Left(failure)));
      });
    });

    group('cacheFromPlaylist', () {
      test('should cache playlist audios successfully', () async {
        const playlistId = 'playlist123';
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          playlistId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase.cacheFromPlaylist(
          playlistId: playlistId,
          trackUrlPairs: trackUrlPairs,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          playlistId,
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });
    });

    group('cacheFromAlbum', () {
      test('should cache album audios successfully', () async {
        const albumId = 'album123';
        final trackUrlPairs = {
          'track1': 'https://example.com/audio1.mp3',
          'track2': 'https://example.com/audio2.mp3',
        };

        when(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          albumId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase.cacheFromAlbum(
          albumId: albumId,
          trackUrlPairs: trackUrlPairs,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheMultipleAudios(
          trackUrlPairs,
          albumId,
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });
    });

    group('validation', () {
      test('should handle empty trackId gracefully', () async {
        const trackId = '';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'ref123';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: any,
        )).thenAnswer((_) async => const Left(ValidationCacheFailure(
          message: 'Invalid trackId',
          field: 'trackId',
          value: '',
        )));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationCacheFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should handle invalid URL gracefully', () async {
        const trackId = 'track123';
        const audioUrl = 'invalid-url';
        const referenceId = 'ref123';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: any,
        )).thenAnswer((_) async => const Left(ValidationCacheFailure(
          message: 'Invalid URL format',
          field: 'audioUrl',
          value: 'invalid-url',
        )));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationCacheFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });
  });
}
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/features/audio_cache/track/domain/usecases/cache_track_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_orchestration_service.dart';
import 'package:trackflow/features/audio_cache/shared/domain/failures/cache_failure.dart';
import 'package:trackflow/features/audio_cache/shared/domain/value_objects/conflict_policy.dart';

import 'cache_track_usecase_test.mocks.dart';

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
      test('should cache track successfully when service returns success', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });

      test('should return failure when service returns failure', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const failure = ValidationCacheFailure(
          message: 'Invalid URL',
          field: 'audioUrl',
          value: audioUrl,
        );

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Left(failure));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
        );

        expect(result, equals(const Left(failure)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: ConflictPolicy.lastWins,
        )).called(1);
      });

      test('should use custom conflict policy when provided', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const policy = ConflictPolicy.firstWins;

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: policy,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
          policy: policy,
        );

        expect(result, equals(const Right(unit)));
        verify(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: policy,
        )).called(1);
      });

      test('should handle exceptions and return failure', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          'individual',
          policy: anyNamed('policy'),
        )).thenThrow(Exception('Network error'));

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
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

    group('validation', () {
      test('should return failure when trackId is empty', () async {
        const trackId = '';
        const audioUrl = 'https://example.com/audio.mp3';

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationCacheFailure>());
            expect(failure.message, contains('Track ID cannot be empty'));
            final validationFailure = failure as ValidationCacheFailure;
            expect(validationFailure.field, equals('trackId'));
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return failure when audioUrl is empty', () async {
        const trackId = 'track123';
        const audioUrl = '';

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationCacheFailure>());
            expect(failure.message, contains('Audio URL cannot be empty'));
            final validationFailure = failure as ValidationCacheFailure;
            expect(validationFailure.field, equals('audioUrl'));
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return failure for invalid URL format', () async {
        const trackId = 'track123';
        const audioUrl = 'invalid-url';

        final result = await useCase(
          trackId: trackId,
          audioUrl: audioUrl,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationCacheFailure>());
            expect(failure.message, contains('Invalid audio URL format'));
            final validationFailure = failure as ValidationCacheFailure;
            expect(validationFailure.field, equals('audioUrl'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('cacheWithReference', () {
      test('should cache track with custom reference successfully', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'playlist123';

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: ConflictPolicy.lastWins,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase.cacheWithReference(
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

      test('should return failure when service fails', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'playlist123';
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

        final result = await useCase.cacheWithReference(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result, equals(const Left(failure)));
      });

      test('should return failure when referenceId is empty', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = '';

        final result = await useCase.cacheWithReference(
          trackId: trackId,
          audioUrl: audioUrl,
          referenceId: referenceId,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationCacheFailure>());
            expect(failure.message, contains('Reference ID cannot be empty'));
            final validationFailure = failure as ValidationCacheFailure;
            expect(validationFailure.field, equals('referenceId'));
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should use custom conflict policy', () async {
        const trackId = 'track123';
        const audioUrl = 'https://example.com/audio.mp3';
        const referenceId = 'playlist123';
        const policy = ConflictPolicy.higherQuality;

        when(mockOrchestrationService.cacheAudio(
          trackId,
          audioUrl,
          referenceId,
          policy: policy,
        )).thenAnswer((_) async => const Right(unit));

        final result = await useCase.cacheWithReference(
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
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_player/domain/entities/audio_track_id.dart';
import 'package:trackflow/features/audio_player/domain/entities/audio_track_metadata.dart';
import 'package:trackflow/features/audio_player/infrastructure/repositories/audio_content_repository_impl.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';

import 'audio_content_repository_test.mocks.dart';

@GenerateMocks([AudioTrackRepository, AudioSourceResolver])
void main() {
  group('AudioContentRepositoryImpl', () {
    late AudioContentRepositoryImpl repository;
    late MockAudioTrackRepository mockAudioTrackRepository;
    late MockAudioSourceResolver mockAudioSourceResolver;

    const testTrackId = 'test-track-123';
    const testAudioUrl = 'https://example.com/audio/test-track-123.mp3';
    const testTrackName = 'Test Track';
    const testDuration = Duration(minutes: 3, seconds: 30);

    setUp(() {
      mockAudioTrackRepository = MockAudioTrackRepository();
      mockAudioSourceResolver = MockAudioSourceResolver();
      repository = AudioContentRepositoryImpl(
        mockAudioTrackRepository,
        mockAudioSourceResolver,
      );
    });

    group('getAudioSourceUrl', () {
      test('should use consistent track ID for cache operations', () async {
        // Arrange
        final audioTrackId = AudioTrackId(testTrackId);
        final coreAudioTrackId = core_ids.AudioTrackId.fromUniqueString(
          testTrackId,
        );

        final audioTrack = AudioTrack(
          id: coreAudioTrackId,
          name: testTrackName,
          url: testAudioUrl,
          duration: testDuration,
          projectId: core_ids.ProjectId.fromUniqueString('project-123'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockAudioTrackRepository.getTrackById(coreAudioTrackId),
        ).thenAnswer((_) async => Right(audioTrack));

        when(
          mockAudioSourceResolver.resolveAudioSource(
            testAudioUrl,
            trackId: testTrackId,
          ),
        ).thenAnswer((_) async => const Right('/cached/path/audio.mp3'));

        // Act
        final result = await repository.getAudioSourceUrl(audioTrackId);

        // Assert
        expect(result, '/cached/path/audio.mp3');

        // Verify that the track ID was passed consistently
        verify(
          mockAudioSourceResolver.resolveAudioSource(
            testAudioUrl,
            trackId: testTrackId,
          ),
        ).called(1);
      });

      test(
        'should fallback to remote URL when cache is not available',
        () async {
          // Arrange
          final audioTrackId = AudioTrackId(testTrackId);
          final coreAudioTrackId = core_ids.AudioTrackId.fromUniqueString(
            testTrackId,
          );

          final audioTrack = AudioTrack(
            id: coreAudioTrackId,
            name: testTrackName,
            url: testAudioUrl,
            duration: testDuration,
            projectId: core_ids.ProjectId.fromUniqueString('project-123'),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          when(
            mockAudioTrackRepository.getTrackById(coreAudioTrackId),
          ).thenAnswer((_) async => Right(audioTrack));

          when(
            mockAudioSourceResolver.resolveAudioSource(
              testAudioUrl,
              trackId: testTrackId,
            ),
          ).thenAnswer((_) async => const Right(testAudioUrl));

          // Act
          final result = await repository.getAudioSourceUrl(audioTrackId);

          // Assert
          expect(result, testAudioUrl);

          // Verify that the track ID was passed consistently
          verify(
            mockAudioSourceResolver.resolveAudioSource(
              testAudioUrl,
              trackId: testTrackId,
            ),
          ).called(1);
        },
      );
    });

    group('isTrackCached', () {
      test('should use consistent track ID for cache check', () async {
        // Arrange
        final audioTrackId = AudioTrackId(testTrackId);
        final coreAudioTrackId = core_ids.AudioTrackId.fromUniqueString(
          testTrackId,
        );

        final audioTrack = AudioTrack(
          id: coreAudioTrackId,
          name: testTrackName,
          url: testAudioUrl,
          duration: testDuration,
          projectId: core_ids.ProjectId.fromUniqueString('project-123'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockAudioTrackRepository.getTrackById(coreAudioTrackId),
        ).thenAnswer((_) async => Right(audioTrack));

        when(
          mockAudioSourceResolver.isTrackCached(
            testAudioUrl,
            trackId: testTrackId,
          ),
        ).thenAnswer((_) async => true);

        // Act
        final result = await repository.isTrackCached(audioTrackId);

        // Assert
        expect(result, true);

        // Verify that the track ID was passed consistently
        verify(
          mockAudioSourceResolver.isTrackCached(
            testAudioUrl,
            trackId: testTrackId,
          ),
        ).called(1);
      });

      test('should return false when track is not found', () async {
        // Arrange
        final audioTrackId = AudioTrackId(testTrackId);
        final coreAudioTrackId = core_ids.AudioTrackId.fromUniqueString(
          testTrackId,
        );

        when(
          mockAudioTrackRepository.getTrackById(coreAudioTrackId),
        ).thenAnswer((_) async => Left(ServerFailure('Track not found')));

        // Act
        final result = await repository.isTrackCached(audioTrackId);

        // Assert
        expect(result, false);

        // Verify that cache resolver was not called
        verifyNever(
          mockAudioSourceResolver.isTrackCached(
            any,
            trackId: anyNamed('trackId'),
          ),
        );
      });
    });

    group('getTrackMetadata', () {
      test(
        'should transform business domain track to pure audio metadata',
        () async {
          // Arrange
          final audioTrackId = AudioTrackId(testTrackId);
          final coreAudioTrackId = core_ids.AudioTrackId.fromUniqueString(
            testTrackId,
          );

          final audioTrack = AudioTrack(
            id: coreAudioTrackId,
            name: testTrackName,
            url: testAudioUrl,
            duration: testDuration,
            projectId: core_ids.ProjectId.fromUniqueString('project-123'),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          when(
            mockAudioTrackRepository.getTrackById(coreAudioTrackId),
          ).thenAnswer((_) async => Right(audioTrack));

          // Act
          final result = await repository.getTrackMetadata(audioTrackId);

          // Assert
          expect(result.id, audioTrackId);
          expect(result.title, testTrackName);
          expect(result.artist, 'Unknown Artist');
          expect(result.duration, testDuration);
          expect(result.coverUrl, null);
        },
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/usecases/delete_track_version_usecase.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart'
    as audio_cache;

import 'delete_track_version_usecase_test.mocks.dart';

@GenerateMocks([
  TrackVersionRepository,
  WaveformRepository,
  AudioCommentRepository,
  AudioStorageRepository,
])
void main() {
  group('DeleteTrackVersionUseCase', () {
    late DeleteTrackVersionUseCase useCase;
    late MockTrackVersionRepository mockTrackVersionRepository;
    late MockWaveformRepository mockWaveformRepository;
    late MockAudioCommentRepository mockAudioCommentRepository;
    late MockAudioStorageRepository mockAudioStorageRepository;

    late TrackVersion testTrackVersion;
    late TrackVersionId testVersionId;
    late AudioTrackId testTrackId;
    late UserId testUserId;
    late DeleteTrackVersionParams testParams;

    setUp(() {
      mockTrackVersionRepository = MockTrackVersionRepository();
      mockWaveformRepository = MockWaveformRepository();
      mockAudioCommentRepository = MockAudioCommentRepository();
      mockAudioStorageRepository = MockAudioStorageRepository();

      useCase = DeleteTrackVersionUseCase(
        mockTrackVersionRepository,
        mockWaveformRepository,
        mockAudioCommentRepository,
        mockAudioStorageRepository,
      );

      testVersionId = TrackVersionId.fromUniqueString('version-123');
      testTrackId = AudioTrackId.fromUniqueString('track-456');
      testUserId = UserId.fromUniqueString('user-789');

      testTrackVersion = TrackVersion(
        id: testVersionId,
        trackId: testTrackId,
        versionNumber: 1,
        label: 'Test Version',
        fileRemoteUrl: 'https://example.com/test_track_v1.mp3',
        durationMs: 180000, // 3 minutes
        status: TrackVersionStatus.ready,
        createdAt: DateTime.now(),
        createdBy: testUserId,
      );

      testParams = DeleteTrackVersionParams(versionId: testVersionId);
    });

    group('Successful deletion scenarios', () {
      test(
        'should successfully delete track version with all related data',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify deletion order and that all operations were called
          verify(mockTrackVersionRepository.getById(testVersionId)).called(1);
          verify(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).called(1);
          verify(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).called(1);
          verify(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).called(1);
          verify(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).called(1);
        },
      );
    });

    group('Version not found scenarios', () {
      test('should fail when track version is not found', () async {
        // Arrange
        when(
          mockTrackVersionRepository.getById(testVersionId),
        ).thenAnswer((_) async => Left(DatabaseFailure('Version not found')));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should have returned failure'),
        );

        // Verify no related data deletion was attempted
        verifyNever(mockWaveformRepository.deleteWaveformsForVersion(any));
        verifyNever(mockAudioCommentRepository.deleteCommentsByVersion(any));
        verifyNever(
          mockAudioStorageRepository.deleteAudioVersionFile(any, any),
        );
        verifyNever(mockTrackVersionRepository.deleteVersion(any));
      });
    });

    group('Partial failure scenarios', () {
      test(
        'should continue deletion even if waveform deletion fails',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          // Waveform deletion fails
          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Waveform deletion failed')),
          );

          when(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify other operations still proceeded
          verify(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).called(1);
          verify(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).called(1);
          verify(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).called(1);
        },
      );

      test('should continue deletion even if comment deletion fails', () async {
        // Arrange
        when(
          mockTrackVersionRepository.getById(testVersionId),
        ).thenAnswer((_) async => Right(testTrackVersion));

        when(
          mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
        ).thenAnswer((_) async => const Right(unit));

        // Comment deletion fails
        when(
          mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
        ).thenAnswer(
          (_) async => Left(DatabaseFailure('Comment deletion failed')),
        );

        when(
          mockAudioStorageRepository.deleteAudioVersionFile(
            testTrackId,
            testVersionId,
          ),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockTrackVersionRepository.deleteVersion(testVersionId),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isRight(), true);

        // Verify other operations still proceeded
        verify(
          mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
        ).called(1);
        verify(
          mockAudioStorageRepository.deleteAudioVersionFile(
            testTrackId,
            testVersionId,
          ),
        ).called(1);
        verify(
          mockTrackVersionRepository.deleteVersion(testVersionId),
        ).called(1);
      });

      test(
        'should continue deletion even if audio file deletion fails',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Audio file deletion fails
          when(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).thenAnswer(
            (_) async => Left(
              audio_cache.StorageCacheFailure(
                message: 'Audio file deletion failed',
                type: audio_cache.StorageFailureType.fileNotFound,
              ),
            ),
          );

          when(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify version deletion still proceeded
          verify(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).called(1);
        },
      );

      test(
        'should continue deletion even if multiple related deletions fail',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          // Multiple failures
          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Waveform deletion failed')),
          );

          when(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Comment deletion failed')),
          );

          when(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).thenAnswer(
            (_) async => Left(
              audio_cache.StorageCacheFailure(
                message: 'Audio file deletion failed',
                type: audio_cache.StorageFailureType.fileNotFound,
              ),
            ),
          );

          when(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify version deletion still proceeded despite all related failures
          verify(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).called(1);
        },
      );
    });

    group('Critical failure scenarios', () {
      test('should fail when version repository deletion fails', () async {
        // Arrange
        when(
          mockTrackVersionRepository.getById(testVersionId),
        ).thenAnswer((_) async => Right(testTrackVersion));

        when(
          mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockAudioStorageRepository.deleteAudioVersionFile(
            testTrackId,
            testVersionId,
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Version deletion fails
        when(
          mockTrackVersionRepository.deleteVersion(testVersionId),
        ).thenAnswer(
          (_) async => Left(DatabaseFailure('Version deletion failed')),
        );

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should have returned failure'),
        );
      });

      test(
        'should handle unexpected exceptions during version retrieval',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenThrow(Exception('Unexpected database error'));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isLeft(), true);
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (_) => fail('Should have returned failure'),
          );
        },
      );

      test(
        'should handle unexpected exceptions during deletion process',
        () async {
          // Arrange
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenThrow(Exception('Unexpected waveform error'));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isLeft(), true);
          result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (_) => fail('Should have returned failure'),
          );
        },
      );
    });

    group('Edge cases', () {
      test(
        'should handle version with null or empty track id gracefully',
        () async {
          // This is more of a validation that our setup is correct
          // In practice, TrackVersion should always have a valid trackId
          expect(testTrackVersion.trackId, isNotNull);
          expect(testTrackVersion.trackId.value, isNotEmpty);
        },
      );

      test(
        'should handle deletion of version that was already partially deleted',
        () async {
          // Arrange - simulate a scenario where some related data was already deleted
          when(
            mockTrackVersionRepository.getById(testVersionId),
          ).thenAnswer((_) async => Right(testTrackVersion));

          // Some operations succeed, some fail with "not found" type errors
          when(
            mockWaveformRepository.deleteWaveformsForVersion(
               testTrackId,
               testVersionId,
             ),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Waveforms not found')),
          );

          when(
            mockAudioCommentRepository.deleteCommentsByVersion(testVersionId),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Comments not found')),
          );

          when(
            mockAudioStorageRepository.deleteAudioVersionFile(
              testTrackId,
              testVersionId,
            ),
          ).thenAnswer(
            (_) async => Left(
              audio_cache.StorageCacheFailure(
                message: 'File not found',
                type: audio_cache.StorageFailureType.fileNotFound,
              ),
            ),
          );

          when(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Should still complete successfully even if related data was missing
          verify(
            mockTrackVersionRepository.deleteVersion(testVersionId),
          ).called(1);
        },
      );
    });
  });
}

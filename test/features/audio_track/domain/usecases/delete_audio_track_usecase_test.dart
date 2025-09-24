import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';

import 'delete_audio_track_usecase_test.mocks.dart';

@GenerateMocks([
  SessionStorage,
  ProjectsRepository,
  ProjectTrackService,
  TrackVersionRepository,
  WaveformRepository,
  AudioStorageRepository,
  AudioCommentRepository,
])
void main() {
  group('DeleteAudioTrack', () {
    late DeleteAudioTrack useCase;
    late MockSessionStorage mockSessionStorage;
    late MockProjectsRepository mockProjectsRepository;
    late MockProjectTrackService mockProjectTrackService;
    late MockTrackVersionRepository mockTrackVersionRepository;
    late MockWaveformRepository mockWaveformRepository;
    late MockAudioStorageRepository mockAudioStorageRepository;
    late MockAudioCommentRepository mockAudioCommentRepository;

    late Project testProject;
    late UserId testUserId;
    late AudioTrackId testTrackId;
    late ProjectId testProjectId;
    late List<TrackVersion> testVersions;
    late DeleteAudioTrackParams testParams;

    setUp(() {
      mockSessionStorage = MockSessionStorage();
      mockProjectsRepository = MockProjectsRepository();
      mockProjectTrackService = MockProjectTrackService();
      mockTrackVersionRepository = MockTrackVersionRepository();
      mockWaveformRepository = MockWaveformRepository();
      mockAudioStorageRepository = MockAudioStorageRepository();
      mockAudioCommentRepository = MockAudioCommentRepository();

      useCase = DeleteAudioTrack(
        mockSessionStorage,
        mockProjectsRepository,
        mockProjectTrackService,
        mockTrackVersionRepository,
        mockWaveformRepository,
        mockAudioStorageRepository,
        mockAudioCommentRepository,
      );

      testUserId = UserId.fromUniqueString('user-123');
      testProjectId = ProjectId.fromUniqueString('project-123');
      testTrackId = AudioTrackId.fromUniqueString('track-123');

      testProject = Project(
        id: testProjectId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Test Description'),
        ownerId: testUserId,
        collaborators: [
          ProjectCollaborator.create(
            userId: testUserId,
            role: ProjectRole.owner,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testVersions = [
        TrackVersion(
          id: TrackVersionId.fromUniqueString('version-1'),
          trackId: testTrackId,
          versionNumber: 1,
          label: 'Version 1',
          fileRemoteUrl: 'https://example.com/track_v1.mp3',
          durationMs: 180000, // 3 minutes
          status: TrackVersionStatus.ready,
          createdAt: DateTime.now(),
          createdBy: testUserId,
        ),
        TrackVersion(
          id: TrackVersionId.fromUniqueString('version-2'),
          trackId: testTrackId,
          versionNumber: 2,
          label: 'Version 2',
          fileRemoteUrl: 'https://example.com/track_v2.mp3',
          durationMs: 240000, // 4 minutes
          status: TrackVersionStatus.ready,
          createdAt: DateTime.now(),
          createdBy: testUserId,
        ),
      ];

      testParams = DeleteAudioTrackParams(
        trackId: testTrackId,
        projectId: testProjectId,
      );
    });

    group('Successful deletion scenarios', () {
      test(
        'should successfully delete audio track with all related data',
        () async {
          // Arrange
          when(
            mockSessionStorage.getUserId(),
          ).thenAnswer((_) async => testUserId.value);

          when(
            mockProjectsRepository.getProjectById(testProjectId),
          ).thenAnswer((_) async => Right(testProject));

          when(
            mockTrackVersionRepository.getVersionsByTrack(testTrackId),
          ).thenAnswer((_) async => Right(testVersions));

          when(
            mockAudioCommentRepository.deleteByTrackId(testTrackId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockTrackVersionRepository.deleteVersion(any),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockWaveformRepository.deleteWaveformsForVersion(any, any),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioStorageRepository.deleteAudioFile(testTrackId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify cascade deletion order
          verify(
            mockAudioCommentRepository.deleteByTrackId(testTrackId),
          ).called(1);
          verify(
            mockTrackVersionRepository.deleteVersion(testVersions[0].id),
          ).called(1);
          verify(
            mockTrackVersionRepository.deleteVersion(testVersions[1].id),
          ).called(1);
          verify(
            mockWaveformRepository.deleteWaveformsForVersion(
              testTrackId,
              testVersions[0].id,
            ),
          ).called(1);
          verify(
            mockWaveformRepository.deleteWaveformsForVersion(
              testTrackId,
              testVersions[1].id,
            ),
          ).called(1);
          verify(
            mockAudioStorageRepository.deleteAudioFile(testTrackId),
          ).called(1);
          verify(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).called(1);
        },
      );

      test('should successfully delete audio track with no versions', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectsRepository.getProjectById(testProjectId),
        ).thenAnswer((_) async => Right(testProject));

        when(
          mockTrackVersionRepository.getVersionsByTrack(testTrackId),
        ).thenAnswer((_) async => const Right([]));

        when(
          mockAudioCommentRepository.deleteByTrackId(testTrackId),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockAudioStorageRepository.deleteAudioFile(testTrackId),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockProjectTrackService.deleteTrack(
            project: testProject,
            requester: testUserId,
            trackId: testTrackId,
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isRight(), true);

        // Verify no version-specific operations were called
        verifyNever(mockTrackVersionRepository.deleteVersion(any));
        verifyNever(mockWaveformRepository.deleteWaveformsForVersion(any, any));

        // Verify track-level operations were still called
        verify(
          mockAudioCommentRepository.deleteByTrackId(testTrackId),
        ).called(1);
        verify(
          mockAudioStorageRepository.deleteAudioFile(testTrackId),
        ).called(1);
        verify(
          mockProjectTrackService.deleteTrack(
            project: testProject,
            requester: testUserId,
            trackId: testTrackId,
          ),
        ).called(1);
      });
    });

    group('Authentication failure scenarios', () {
      test('should fail when user is not authenticated', () async {
        // Arrange
        when(mockSessionStorage.getUserId()).thenAnswer((_) async => null);

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (_) => fail('Should have returned failure'),
        );

        // Verify no deletion operations were attempted
        verifyNever(mockProjectsRepository.getProjectById(any));
        verifyNever(mockTrackVersionRepository.getVersionsByTrack(any));
      });
    });

    group('Project access failure scenarios', () {
      test('should fail when project is not found', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectsRepository.getProjectById(testProjectId),
        ).thenAnswer((_) async => Left(DatabaseFailure('Project not found')));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('Should have returned failure'),
        );

        // Verify no version operations were attempted
        verifyNever(mockTrackVersionRepository.getVersionsByTrack(any));
      });
    });

    group('Partial failure scenarios', () {
      test(
        'should continue deletion even if comments deletion fails',
        () async {
          // Arrange
          when(
            mockSessionStorage.getUserId(),
          ).thenAnswer((_) async => testUserId.value);

          when(
            mockProjectsRepository.getProjectById(testProjectId),
          ).thenAnswer((_) async => Right(testProject));

          when(
            mockTrackVersionRepository.getVersionsByTrack(testTrackId),
          ).thenAnswer((_) async => Right(testVersions));

          // Comments deletion fails
          when(
            mockAudioCommentRepository.deleteByTrackId(testTrackId),
          ).thenThrow(Exception('Comments deletion failed'));

          when(
            mockTrackVersionRepository.deleteVersion(any),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockWaveformRepository.deleteWaveformsForVersion(any, any),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioStorageRepository.deleteAudioFile(testTrackId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify other operations still proceeded
          verify(mockTrackVersionRepository.deleteVersion(any)).called(2);
          verify(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).called(1);
        },
      );

      test(
        'should continue deletion even if some versions fail to delete',
        () async {
          // Arrange
          when(
            mockSessionStorage.getUserId(),
          ).thenAnswer((_) async => testUserId.value);

          when(
            mockProjectsRepository.getProjectById(testProjectId),
          ).thenAnswer((_) async => Right(testProject));

          when(
            mockTrackVersionRepository.getVersionsByTrack(testTrackId),
          ).thenAnswer((_) async => Right(testVersions));

          when(
            mockAudioCommentRepository.deleteByTrackId(testTrackId),
          ).thenAnswer((_) async => const Right(unit));

          // First version deletion succeeds, second fails
          when(
            mockTrackVersionRepository.deleteVersion(testVersions[0].id),
          ).thenAnswer((_) async => const Right(unit));
          when(
            mockTrackVersionRepository.deleteVersion(testVersions[1].id),
          ).thenAnswer(
            (_) async => Left(DatabaseFailure('Version deletion failed')),
          );

          when(
            mockWaveformRepository.deleteWaveformsForVersion(any, any),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockAudioStorageRepository.deleteAudioFile(testTrackId),
          ).thenAnswer((_) async => const Right(unit));

          when(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testParams);

          // Assert
          expect(result.isRight(), true);

          // Verify track deletion still proceeded
          verify(
            mockProjectTrackService.deleteTrack(
              project: testProject,
              requester: testUserId,
              trackId: testTrackId,
            ),
          ).called(1);
        },
      );

      test('should continue deletion even if cache cleanup fails', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectsRepository.getProjectById(testProjectId),
        ).thenAnswer((_) async => Right(testProject));

        when(
          mockTrackVersionRepository.getVersionsByTrack(testTrackId),
        ).thenAnswer((_) async => Right(testVersions));

        when(
          mockAudioCommentRepository.deleteByTrackId(testTrackId),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockTrackVersionRepository.deleteVersion(any),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockWaveformRepository.deleteWaveformsForVersion(any, any),
        ).thenAnswer((_) async => const Right(unit));

        // Cache deletion fails
        when(
          mockAudioStorageRepository.deleteAudioFile(testTrackId),
        ).thenThrow(Exception('Cache cleanup failed'));

        when(
          mockProjectTrackService.deleteTrack(
            project: testProject,
            requester: testUserId,
            trackId: testTrackId,
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isRight(), true);

        // Verify track deletion still proceeded
        verify(
          mockProjectTrackService.deleteTrack(
            project: testProject,
            requester: testUserId,
            trackId: testTrackId,
          ),
        ).called(1);
      });
    });

    group('Critical failure scenarios', () {
      test('should fail when track deletion fails', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectsRepository.getProjectById(testProjectId),
        ).thenAnswer((_) async => Right(testProject));

        when(
          mockTrackVersionRepository.getVersionsByTrack(testTrackId),
        ).thenAnswer((_) async => Right(testVersions));

        when(
          mockAudioCommentRepository.deleteByTrackId(testTrackId),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockTrackVersionRepository.deleteVersion(any),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockWaveformRepository.deleteWaveformsForVersion(any, any),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockAudioStorageRepository.deleteAudioFile(testTrackId),
        ).thenAnswer((_) async => const Right(unit));

        // Track deletion fails
        when(
          mockProjectTrackService.deleteTrack(
            project: testProject,
            requester: testUserId,
            trackId: testTrackId,
          ),
        ).thenAnswer(
          (_) async => Left(DatabaseFailure('Track deletion failed')),
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

      test('should handle unexpected exceptions', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectsRepository.getProjectById(testProjectId),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase.call(testParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('Should have returned failure'),
        );
      });
    });
  });
}

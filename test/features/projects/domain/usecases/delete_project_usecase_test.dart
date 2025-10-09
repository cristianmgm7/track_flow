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
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart';

import 'delete_project_usecase_test.mocks.dart';

@GenerateMocks([
  SessionStorage,
  ProjectsRepository,
  ProjectTrackService,
  DeleteAudioTrack,
])
void main() {
  group('DeleteProjectUseCase', () {
    late DeleteProjectUseCase useCase;
    late MockSessionStorage mockSessionStorage;
    late MockProjectsRepository mockProjectsRepository;
    late MockProjectTrackService mockProjectTrackService;
    late MockDeleteAudioTrack mockDeleteAudioTrack;

    late Project testProject;
    late UserId testUserId;
    late List<AudioTrack> testTracks;

    setUp(() {
      mockSessionStorage = MockSessionStorage();
      mockProjectsRepository = MockProjectsRepository();
      mockProjectTrackService = MockProjectTrackService();
      mockDeleteAudioTrack = MockDeleteAudioTrack();

      useCase = DeleteProjectUseCase(
        mockProjectsRepository,
        mockSessionStorage,
        mockProjectTrackService,
        mockDeleteAudioTrack,
      );

      testUserId = UserId.fromUniqueString('user-123');
      testProject = Project(
        id: ProjectId.fromUniqueString('project-123'),
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

      testTracks = [
        AudioTrack(
          id: AudioTrackId.fromUniqueString('track-1'),
          name: 'Track 1',
          url: 'https://example.com/track1.mp3',
          duration: const Duration(minutes: 3),
          projectId: testProject.id,
          uploadedBy: testUserId,
          createdAt: DateTime.now(),
        ),
        AudioTrack(
          id: AudioTrackId.fromUniqueString('track-2'),
          name: 'Track 2',
          url: 'https://example.com/track2.mp3',
          duration: const Duration(minutes: 4),
          projectId: testProject.id,
          uploadedBy: testUserId,
          createdAt: DateTime.now(),
        ),
      ];
    });

    group('Successful deletion scenarios', () {
      test('should successfully delete project with all tracks', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectTrackService.watchTracksByProject(testProject.id),
        ).thenAnswer((_) => Stream.value(Right(testTracks)));

        when(
          mockDeleteAudioTrack.call(any),
        ).thenAnswer((_) async => const Right(unit));

        when(
          mockProjectsRepository.deleteProject(testProject),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(testProject);

        // Assert
        expect(result.isRight(), true);

        // Verify all tracks were deleted
        verify(mockDeleteAudioTrack.call(any)).called(2);

        // Verify project was deleted
        verify(mockProjectsRepository.deleteProject(testProject)).called(1);
      });

      test('should successfully delete project with no tracks', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectTrackService.watchTracksByProject(testProject.id),
        ).thenAnswer((_) => Stream.value(const Right([])));

        when(
          mockProjectsRepository.deleteProject(testProject),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(testProject);

        // Assert
        expect(result.isRight(), true);

        // Verify no track deletion was attempted
        verifyNever(mockDeleteAudioTrack.call(any));

        // Verify project was deleted
        verify(mockProjectsRepository.deleteProject(testProject)).called(1);
      });
    });

    group('Authentication failure scenarios', () {
      test('should fail when user is not authenticated', () async {
        // Arrange
        when(mockSessionStorage.getUserId()).thenAnswer((_) async => null);

        // Act
        final result = await useCase.call(testProject);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (_) => fail('Should have returned failure'),
        );

        // Verify no deletion operations were attempted
        verifyNever(mockProjectTrackService.watchTracksByProject(any));
        verifyNever(mockDeleteAudioTrack.call(any));
        verifyNever(mockProjectsRepository.deleteProject(any as Project));
      });

      test('should fail when user lacks delete permission', () async {
        // Arrange
        final unauthorizedProject = Project(
          id: ProjectId.fromUniqueString('project-456'),
          name: ProjectName('Unauthorized Project'),
          description: ProjectDescription('Description'),
          ownerId: UserId.fromUniqueString('other-user'),
          collaborators: [
            ProjectCollaborator.create(
              userId: testUserId,
              role: ProjectRole.viewer, // No delete permission
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        // Act
        final result = await useCase.call(unauthorizedProject);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ProjectException>()),
          (_) => fail('Should have returned failure'),
        );
      });
    });

    group('Partial failure scenarios', () {
      test(
        'should complete project deletion even if some tracks fail to delete',
        () async {
          // Arrange
          when(
            mockSessionStorage.getUserId(),
          ).thenAnswer((_) async => testUserId.value);

          when(
            mockProjectTrackService.watchTracksByProject(testProject.id),
          ).thenAnswer((_) => Stream.value(Right(testTracks)));

          // Mock track deletions - some succeed, some fail
          var callCount = 0;
          when(mockDeleteAudioTrack.call(any)).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return const Right(unit);
            } else {
              return Left(DatabaseFailure('Track deletion failed'));
            }
          });

          when(
            mockProjectsRepository.deleteProject(testProject),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testProject);

          // Assert
          expect(result.isRight(), true);

          // Verify both track deletions were attempted
          verify(mockDeleteAudioTrack.call(any)).called(2);

          // Verify project was still deleted despite track deletion failure
          verify(
            mockProjectsRepository.deleteProject(testProject),
          ).called(1);
        },
      );

      test(
        'should complete project deletion even if getting tracks fails',
        () async {
          // Arrange
          when(
            mockSessionStorage.getUserId(),
          ).thenAnswer((_) async => testUserId.value);

          when(
            mockProjectTrackService.watchTracksByProject(testProject.id),
          ).thenAnswer(
            (_) => Stream.value(Left(DatabaseFailure('Failed to get tracks'))),
          );

          when(
            mockProjectsRepository.deleteProject(testProject),
          ).thenAnswer((_) async => const Right(unit));

          // Act
          final result = await useCase.call(testProject);

          // Assert
          expect(result.isRight(), true);

          // Verify no track deletion was attempted
          verifyNever(mockDeleteAudioTrack.call(any));

          // Verify project was still deleted
          verify(
            mockProjectsRepository.deleteProject(testProject),
          ).called(1);
        },
      );
    });

    group('Critical failure scenarios', () {
      test('should fail when project repository deletion fails', () async {
        // Arrange
        when(
          mockSessionStorage.getUserId(),
        ).thenAnswer((_) async => testUserId.value);

        when(
          mockProjectTrackService.watchTracksByProject(testProject.id),
        ).thenAnswer((_) => Stream.value(const Right([])));

        when(
          mockProjectsRepository.deleteProject(testProject),
        ).thenAnswer((_) async => Left(DatabaseFailure('Database error')));

        // Act
        final result = await useCase.call(testProject);

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
          mockProjectTrackService.watchTracksByProject(testProject.id),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase.call(testProject);

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

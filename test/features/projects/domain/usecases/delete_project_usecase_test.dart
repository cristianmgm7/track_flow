import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/user_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';

@GenerateMocks([ProjectRepository])
import 'delete_project_usecase_test.mocks.dart';

void main() {
  late DeleteProjectUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = DeleteProjectUseCase(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProject = Project(
    id: ProjectId('test-id'),
    title: 'Test Project',
    description: 'Test Description',
    userId: UserId('test-user'),
    status: ProjectStatus(Project.statusDraft),
    createdAt: testDate,
  );

  group('DeleteProjectUseCase', () {
    test('should delete project when user owns it', () async {
      // arrange
      when(
        mockRepository.getProjectById('test-id'),
      ).thenAnswer((_) async => Right(testProject));
      when(
        mockRepository.deleteProject('test-id'),
      ).thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(projectId: 'test-id', userId: 'test-user');

      // assert
      expect(result, const Right(null));
      verify(mockRepository.getProjectById('test-id'));
      verify(mockRepository.deleteProject('test-id'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when projectId is empty', () async {
      // act
      final result = await useCase(projectId: '', userId: 'test-user');

      // assert
      expect(result, Left(ValidationFailure('Project ID cannot be empty')));
      verifyNever(mockRepository.getProjectById(any));
      verifyNever(mockRepository.deleteProject(any));
    });

    test('should return ValidationFailure when userId is empty', () async {
      // act
      final result = await useCase(projectId: 'test-id', userId: '');

      // assert
      expect(result, Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(mockRepository.getProjectById(any));
      verifyNever(mockRepository.deleteProject(any));
    });

    test(
      'should return PermissionFailure when user does not own project',
      () async {
        // arrange
        final differentUserProject = Project(
          id: ProjectId('test-id'),
          title: 'Test Project',
          description: 'Test Description',
          userId: UserId('different-user'),
          status: ProjectStatus(Project.statusDraft),
          createdAt: testDate,
        );

        when(
          mockRepository.getProjectById('test-id'),
        ).thenAnswer((_) async => Right(differentUserProject));

        // act
        final result = await useCase(projectId: 'test-id', userId: 'test-user');

        // assert
        expect(
          result,
          Left(PermissionFailure('User does not own this project')),
        );
        verify(mockRepository.getProjectById('test-id'));
        verifyNever(mockRepository.deleteProject(any));
      },
    );

    test('should return Failure when project lookup fails', () async {
      // arrange
      when(
        mockRepository.getProjectById('test-id'),
      ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

      // act
      final result = await useCase(projectId: 'test-id', userId: 'test-user');

      // assert
      expect(result, Left(ServerFailure('Repository error')));
      verify(mockRepository.getProjectById('test-id'));
      verifyNever(mockRepository.deleteProject(any));
    });

    test('should return Failure when deletion fails', () async {
      // arrange
      when(
        mockRepository.getProjectById('test-id'),
      ).thenAnswer((_) async => Right(testProject));
      when(
        mockRepository.deleteProject('test-id'),
      ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

      // act
      final result = await useCase(projectId: 'test-id', userId: 'test-user');

      // assert
      expect(result, Left(ServerFailure('Repository error')));
      verify(mockRepository.getProjectById('test-id'));
      verify(mockRepository.deleteProject('test-id'));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

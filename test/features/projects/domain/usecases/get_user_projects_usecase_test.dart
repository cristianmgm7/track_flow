import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/get_user_projects_usecase.dart';

@GenerateMocks([ProjectRepository])
import 'get_user_projects_usecase_test.mocks.dart';

void main() {
  late GetUserProjectsUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = GetUserProjectsUseCase(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProject = Project(
    id: 'test-id',
    title: 'Test Project',
    description: 'Test Description',
    userId: 'test-user',
    status: Project.statusDraft,
    createdAt: testDate,
  );

  final testProjects = [testProject];
  final testUserId = 'test-user';
  final testStatus = Project.statusDraft;

  group('getUserProjects', () {
    test('should get projects stream when userId is valid', () {
      // arrange
      final projectsStream = Stream.value(testProjects);
      when(
        mockRepository.getUserProjects(testUserId),
      ).thenReturn(Right(projectsStream));

      // act
      final result = useCase(testUserId);

      // assert
      expect(result, Right(projectsStream));
      verify(mockRepository.getUserProjects(testUserId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when userId is empty', () {
      // act
      final result = useCase('');

      // assert
      expect(result, Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(mockRepository.getUserProjects(any));
    });

    test('should return Failure when repository fails', () {
      // arrange
      when(
        mockRepository.getUserProjects(testUserId),
      ).thenReturn(Left(ServerFailure('Repository error')));

      // act
      final result = useCase(testUserId);

      // assert
      expect(result, Left(ServerFailure('Repository error')));
      verify(mockRepository.getUserProjects(testUserId));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('getByStatus', () {
    test('should get projects stream when userId and status are valid', () {
      // arrange
      final projectsStream = Stream.value(testProjects);
      when(
        mockRepository.getUserProjectsByStatus(testUserId, testStatus),
      ).thenReturn(Right(projectsStream));

      // act
      final result = useCase.getByStatus(testUserId, testStatus);

      // assert
      expect(result, Right(projectsStream));
      verify(mockRepository.getUserProjectsByStatus(testUserId, testStatus));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when userId is empty', () {
      // act
      final result = useCase.getByStatus('', testStatus);

      // assert
      expect(result, Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(mockRepository.getUserProjectsByStatus(any, any));
    });

    test('should return ValidationFailure when status is invalid', () {
      // act
      final result = useCase.getByStatus(testUserId, 'invalid_status');

      // assert
      expect(
        result,
        Left(ValidationFailure('Invalid project status: invalid_status')),
      );
      verifyNever(mockRepository.getUserProjectsByStatus(any, any));
    });

    test('should return Failure when repository fails', () {
      // arrange
      when(
        mockRepository.getUserProjectsByStatus(testUserId, testStatus),
      ).thenReturn(Left(ServerFailure('Repository error')));

      // act
      final result = useCase.getByStatus(testUserId, testStatus);

      // assert
      expect(result, Left(ServerFailure('Repository error')));
      verify(mockRepository.getUserProjectsByStatus(testUserId, testStatus));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

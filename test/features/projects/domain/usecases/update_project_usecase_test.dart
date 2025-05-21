import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';

@GenerateMocks([ProjectRepository])
import 'update_project_usecase_test.mocks.dart';

void main() {
  late UpdateProjectUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = UpdateProjectUseCase(mockRepository);
  });

  test('should update project when project is valid', () async {
    // arrange
    final project = Project(
      id: UniqueId(),
      ownerId: UserId(),
      name: ProjectName('Updated Project'),
      description: ProjectDescription('Updated Description'),
      createdAt: DateTime.now(),
    );
    when(
      mockRepository.updateProject(any),
    ).thenAnswer((_) async => Right(unit));

    // act
    final result = await useCase(project);

    // assert
    expect(result, Right(unit));
    verify(mockRepository.updateProject(project)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    final project = Project(
      id: UniqueId(),
      ownerId: UserId(),
      name: ProjectName('Updated Project'),
      description: ProjectDescription('Updated Description'),
      createdAt: DateTime.now(),
    );
    when(
      mockRepository.updateProject(any),
    ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

    // act
    final result = await useCase(project);

    // assert
    expect(result, Left(ServerFailure('Repository error')));
    verify(mockRepository.updateProject(project)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

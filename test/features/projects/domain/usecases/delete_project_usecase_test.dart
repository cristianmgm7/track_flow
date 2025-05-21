import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
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

  test('should delete project when id is valid', () async {
    // arrange
    final id = UniqueId();
    when(
      mockRepository.deleteProject(any),
    ).thenAnswer((_) async => Right(unit));

    // act
    final result = await useCase(id);

    // assert
    expect(result, Right(unit));
    verify(mockRepository.deleteProject(id)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    final id = UniqueId();
    when(
      mockRepository.deleteProject(any),
    ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

    // act
    final result = await useCase(id);

    // assert
    expect(result, Left(ServerFailure('Repository error')));
    verify(mockRepository.deleteProject(id)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

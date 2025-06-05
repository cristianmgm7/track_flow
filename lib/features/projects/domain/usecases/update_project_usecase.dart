import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@LazySingleton()
class UpdateProjectUseCase {
  final ProjectsRepository _repository;
  final AuthRepository _authRepository;

  UpdateProjectUseCase(this._repository, this._authRepository);

  /// Updates an existing project.
  Future<Either<Failure, Unit>> call(Project project) async {
    final userIdResult = await _authRepository.getSignedInUserId();
    return await userIdResult.fold((failure) => left(failure), (
      userIdString,
    ) async {
      final updatedProject = project.copyWith(
        ownerId: UserId.fromUniqueString(userIdString),
      );
      return await _repository.updateProject(updatedProject);
    });
  }
}

import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

@LazySingleton()
class UpdateProjectUseCase {
  final ProjectsRepository _repository;
  final SessionStorage _sessionStorage;

  UpdateProjectUseCase(this._repository, this._sessionStorage);

  /// Updates an existing project.
  Future<Either<Failure, Unit>> call(
    Project project, {
    ProjectName? newName,
    ProjectDescription? newDescription,
  }) async {
    final userIdResult = await _sessionStorage.getUserId();
    if (userIdResult == null) {
      return left(AuthenticationFailure('User ID not found'));
    }
    try {
      final updatedProject = project.updateProject(
        requester: UserId.fromUniqueString(userIdResult),
        newName: newName,
        newDescription: newDescription,
      );
      return await _repository.updateProject(updatedProject);
    } on ProjectException catch (e) {
      return left(ProjectException(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}

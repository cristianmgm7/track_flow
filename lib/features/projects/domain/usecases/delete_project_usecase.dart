import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';

@lazySingleton
class DeleteProjectUseCase {
  final ProjectsRepository _projectsRepository;
  final SessionStorage _sessionStorage;

  DeleteProjectUseCase(this._projectsRepository, this._sessionStorage);

  Future<Either<Failure, Unit>> call(Project project) async {
    final userIdResult = await _sessionStorage.getUserId();
    if (userIdResult == null) {
      return left(AuthenticationFailure('User ID not found'));
    }
    try {
      final updatedProject = project.deleteProject(
        requester: UserId.fromUniqueString(userIdResult),
      );
      return _projectsRepository.deleteProject(updatedProject.id);
    } on ProjectException catch (e) {
      return left(ProjectException(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}

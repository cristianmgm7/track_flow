import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

@lazySingleton
class GetProjectByIdUseCase {
  final ProjectsRepository _projectsRepository;

  GetProjectByIdUseCase(this._projectsRepository);

  Future<Either<Failure, Project>> call(ProjectId projectId) async {
    return await _projectsRepository.getProjectById(projectId);
  }
}

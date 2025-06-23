import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

@lazySingleton
class GetProjectByIdUseCase {
  final ProjectDetailRepository _projectDetailRepository;

  GetProjectByIdUseCase(this._projectDetailRepository);

  Future<Either<Failure, Project>> call(ProjectId projectId) async {
    return await _projectDetailRepository.getProjectById(projectId);
  }
}

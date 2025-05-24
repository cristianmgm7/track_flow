import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';

@lazySingleton
class DeleteProjectUseCase {
  final ProjectsRepository _repository;

  DeleteProjectUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UniqueId id) async {
    return await _repository.deleteProject(id);
  }
}

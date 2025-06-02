import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class GetProjectWithCollaboratorsParams extends Equatable {
  final ProjectId projectId;

  const GetProjectWithCollaboratorsParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class GetProjectWithCollaboratorsUseCase {
  final ProjectRepository _repository;

  GetProjectWithCollaboratorsUseCase(this._repository);

  Future<Either<Failure, Project>> call(
    GetProjectWithCollaboratorsParams params,
  ) async {
    return await _repository.getProjectById(params.projectId);
  }
}

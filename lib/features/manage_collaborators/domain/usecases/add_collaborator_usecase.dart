import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

class AddCollaboratorToProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId collaboratorId;

  const AddCollaboratorToProjectParams({
    required this.projectId,
    required this.collaboratorId,
  });

  @override
  List<Object?> get props => [projectId, collaboratorId];
}

@lazySingleton
class AddCollaboratorToProjectUseCase {
  final ManageCollaboratorsRepository _repository;

  AddCollaboratorToProjectUseCase(this._repository);

  Future<Either<Failure, void>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    return await _repository.addCollaboratorWithUserId(
      params.projectId,
      params.collaboratorId,
    );
  }
}

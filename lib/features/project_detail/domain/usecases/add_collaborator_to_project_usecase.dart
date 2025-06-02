import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class AddCollaboratorToProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;

  const AddCollaboratorToProjectParams({
    required this.projectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class AddCollaboratorToProjectUseCase {
  final ProjectRepository _repository;

  AddCollaboratorToProjectUseCase(this._repository);

  Future<Either<Failure, void>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    return await _repository.addParticipant(params.projectId, params.userId);
  }
}

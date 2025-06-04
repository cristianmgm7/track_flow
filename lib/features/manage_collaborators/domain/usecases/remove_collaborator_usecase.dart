import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class RemoveCollaboratorParams {
  final ProjectId projectId;
  final UserId userId;

  RemoveCollaboratorParams({required this.projectId, required this.userId});
}

@lazySingleton
class RemoveCollaboratorUseCase {
  final ManageCollaboratorsRepository _repository;

  RemoveCollaboratorUseCase(this._repository);

  Future<Either<Failure, void>> call(RemoveCollaboratorParams params) async {
    return await _repository.removeParticipant(params.projectId, params.userId);
  }
}

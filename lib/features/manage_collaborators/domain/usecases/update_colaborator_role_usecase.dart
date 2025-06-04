import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class UpdateCollaboratorRoleParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;
  final UserRole role;

  const UpdateCollaboratorRoleParams({
    required this.projectId,
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, userId, role];
}

@lazySingleton
class UpdateCollaboratorRoleUseCase {
  final ManageCollaboratorsRepository _repository;

  UpdateCollaboratorRoleUseCase(this._repository);

  Future<Either<Failure, void>> call(
    UpdateCollaboratorRoleParams params,
  ) async {
    return await _repository.updateParticipantRole(
      params.projectId,
      params.userId,
      params.role,
    );
  }
}

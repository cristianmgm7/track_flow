import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class LoadCollaboratorsParams {
  final ProjectId projectId;

  LoadCollaboratorsParams({required this.projectId});
}

@lazySingleton
class LoadCollaboratorsUseCase {
  final ManageCollaboratorsRepository _repository;

  LoadCollaboratorsUseCase(this._repository);

  Future<Either<Failure, List<UserProfile>>> call(
    LoadCollaboratorsParams params,
  ) async {
    return await _repository.getProjectParticipants(params.projectId);
  }
}

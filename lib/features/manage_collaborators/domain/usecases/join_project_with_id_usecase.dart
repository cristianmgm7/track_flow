import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';

class JoinProjectWithIdParams extends Equatable {
  final UniqueId projectId;

  const JoinProjectWithIdParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class JoinProjectWithIdUseCase {
  final ManageCollaboratorsRepository _projectsRepository;
  final SessionStorage _sessionRepository;

  JoinProjectWithIdUseCase(this._projectsRepository, this._sessionRepository);

  Future<Either<Failure, void>> call(JoinProjectWithIdParams params) async {
    final userId = await _sessionRepository.getUserId();
    return _projectsRepository.joinProjectWithId(
      ProjectId.fromUniqueString(params.projectId.value),
      UserId.fromUniqueString(userId!),
    );
  }
}

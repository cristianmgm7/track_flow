import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/collaborator_repository.dart';

class LeaveProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;

  const LeaveProjectParams({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class LeaveProjectUseCase {
  final CollaboratorRepository _collaboratorRepository;
  final SessionStorage _sessionStorage;

  LeaveProjectUseCase(
    this._collaboratorRepository,
    this._sessionStorage,
  );

  Future<Either<Failure, void>> call(LeaveProjectParams params) async {
    final userId = _sessionStorage.getUserId();
    return await _collaboratorRepository.leaveProject(
      projectId: params.projectId,
      userId: UserId.fromUniqueString(userId ?? ''),
    );
  }
}

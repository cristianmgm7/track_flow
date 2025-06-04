import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class LeaveProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;

  const LeaveProjectParams({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class LeaveProjectUseCase {
  final ProjectRepository _repository;
  final SessionStorage _sessionStorage;

  LeaveProjectUseCase(this._repository, this._sessionStorage);

  Future<Either<Failure, void>> call(LeaveProjectParams params) async {
    final userId = await _sessionStorage.getUserId();
    return await _repository.leaveProject(
      projectId: params.projectId,
      userId: UserId.fromUniqueString(userId!),
    );
  }
}

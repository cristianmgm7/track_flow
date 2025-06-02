import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class RemoveCollaboratorFromProjectParams extends Equatable {
  final ProjectId projectId;
  final UserId userId;

  const RemoveCollaboratorFromProjectParams({
    required this.projectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class RemoveCollaboratorFromProjectUseCase {
  final ProjectRepository _repository;

  RemoveCollaboratorFromProjectUseCase(this._repository);

  Future<Either<Failure, void>> call(
    RemoveCollaboratorFromProjectParams params,
  ) async {
    return await _repository.removeParticipant(params.projectId, params.userId);
  }
}

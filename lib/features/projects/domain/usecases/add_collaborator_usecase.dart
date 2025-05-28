import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:equatable/equatable.dart';
import '../repositories/projects_repository.dart';

class AddCollaboratorParams extends Equatable {
  final UniqueId projectId;
  final UserId userId;

  const AddCollaboratorParams({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

@lazySingleton
class AddCollaboratorUseCase {
  final ProjectsRepository _repository;
  AddCollaboratorUseCase(this._repository);

  Future<Either<Failure, Unit>> call(AddCollaboratorParams params) {
    return _repository.addCollaborator(
      projectId: params.projectId,
      userId: params.userId,
    );
  }
}

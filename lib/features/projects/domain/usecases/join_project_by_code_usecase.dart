import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../repositories/projects_repository.dart';

class JoinProjectByCodeParams extends Equatable {
  final UniqueId projectId;
  final String joinCode;

  const JoinProjectByCodeParams({
    required this.projectId,
    required this.joinCode,
  });

  @override
  List<Object?> get props => [projectId, joinCode];
}

@lazySingleton
class JoinProjectByCodeUseCase {
  final ProjectsRepository _repository;
  JoinProjectByCodeUseCase(this._repository);

  Future<Either<Failure, Unit>> call(JoinProjectByCodeParams params) {
    return _repository.joinProjectByCode(
      projectId: params.projectId,
      joinCode: params.joinCode,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import '../repositories/projects_repository.dart';

class JoinProjectWithIdParams extends Equatable {
  final UniqueId projectId;

  const JoinProjectWithIdParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class JoinProjectWithIdUseCase {
  final ProjectsRepository _projectsRepository;
  final AuthRepository _authRepository;

  JoinProjectWithIdUseCase(this._projectsRepository, this._authRepository);

  Future<Either<Failure, Unit>> call(JoinProjectWithIdParams params) async {
    final userIdOrFailure = await _authRepository.getSignedInUserId();
    return await userIdOrFailure.fold(
      (failure) => Left(failure),
      (userId) => _projectsRepository.joinProjectWithId(
        projectId: params.projectId,
        userId: UserId.fromUniqueString(userId),
      ),
    );
  }
}

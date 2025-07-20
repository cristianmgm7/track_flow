import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class GenerateMagicLinkParams extends Equatable {
  final String projectId;

  const GenerateMagicLinkParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

@lazySingleton
class GenerateMagicLinkUseCase {
  final MagicLinkRepository _repository;
  final AuthRepository _authRepository;

  GenerateMagicLinkUseCase(this._repository, this._authRepository);

  Future<Either<Failure, MagicLink>> call(
    GenerateMagicLinkParams params,
  ) async {
    final userIdOrFailure = await _authRepository.getSignedInUserId();
    return userIdOrFailure.fold(
      (failure) => Left(failure),
      (userId) => _repository.generateMagicLink(
        projectId: ProjectId.fromUniqueString(params.projectId),
        userId: userId!,
      ),
    );
  }
}

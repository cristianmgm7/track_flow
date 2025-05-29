import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

@immutable
class ValidateMagicLinkParams extends Equatable {
  final String linkId;

  const ValidateMagicLinkParams({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

@lazySingleton
class ValidateMagicLinkUseCase {
  final MagicLinkRepository _repository;

  ValidateMagicLinkUseCase(this._repository);

  Future<Either<Failure, MagicLink>> call(
    ValidateMagicLinkParams params,
  ) async {
    return await _repository.validateMagicLink(linkId: params.linkId);
  }
}

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class GenerateMagicLinkParams extends Equatable {
  final String email;

  const GenerateMagicLinkParams({required this.email});

  @override
  List<Object?> get props => [email];
}

@lazySingleton
class GenerateMagicLinkUseCase {
  final MagicLinkRepository _repository;

  GenerateMagicLinkUseCase(this._repository);

  Future<Either<Failure, MagicLink>> call(
    GenerateMagicLinkParams params,
  ) async {
    return await _repository.generateMagicLink(params.email);
  }
}

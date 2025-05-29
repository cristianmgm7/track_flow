import 'package:equatable/equatable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

abstract class MagicLinkState extends Equatable {
  const MagicLinkState();

  @override
  List<Object?> get props => [];
}

class MagicLinkInitial extends MagicLinkState {}

class MagicLinkLoading extends MagicLinkState {}

class MagicLinkGeneratedSuccess extends MagicLinkState {
  final String linkId;

  const MagicLinkGeneratedSuccess({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkGenerationError extends MagicLinkState {
  final Failure error;

  const MagicLinkGenerationError({required this.error});

  @override
  List<Object?> get props => [error];
}

class MagicLinkValidatedSuccess extends MagicLinkState {
  final MagicLink magicLink;
  const MagicLinkValidatedSuccess(this.magicLink);
  @override
  List<Object?> get props => [magicLink];
}

class MagicLinkValidationError extends MagicLinkState {
  final Failure error;

  const MagicLinkValidationError({required this.error});

  @override
  List<Object?> get props => [error];
}

class MagicLinkConsumedSuccess extends MagicLinkState {}

class MagicLinkConsumedError extends MagicLinkState {
  final Failure error;

  const MagicLinkConsumedError({required this.error});

  @override
  List<Object?> get props => [error];
}

class MagicLinkResentSuccess extends MagicLinkState {}

class MagicLinkResendError extends MagicLinkState {
  final Failure error;

  const MagicLinkResendError({required this.error});

  @override
  List<Object?> get props => [error];
}

class MagicLinkStatusLoaded extends MagicLinkState {
  final MagicLinkStatus status;

  const MagicLinkStatusLoaded({required this.status});

  @override
  List<Object?> get props => [status];
}

class MagicLinkStatusError extends MagicLinkState {
  final Failure error;

  const MagicLinkStatusError({required this.error});

  @override
  List<Object?> get props => [error];
}

// Magic Link Handling.............

class MagicLinkHandling extends MagicLinkState {}

class MagicLinkHandleSuccessState extends MagicLinkState {}

class MagicLinkHandleErrorState extends MagicLinkState {
  final Failure error;
  const MagicLinkHandleErrorState({required this.error});
  @override
  List<Object?> get props => [error];
}

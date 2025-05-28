import 'package:equatable/equatable.dart';
import 'package:trackflow/core/error/failures.dart';

abstract class MagicLinkEvent extends Equatable {
  const MagicLinkEvent();

  @override
  List<Object?> get props => [];
}

class MagicLinkRequested extends MagicLinkEvent {
  final String projectId;

  const MagicLinkRequested({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class MagicLinkGenerated extends MagicLinkEvent {
  final String linkId;

  const MagicLinkGenerated({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkGenerationFailed extends MagicLinkEvent {
  final Failure failure;

  const MagicLinkGenerationFailed({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class MagicLinkValidated extends MagicLinkEvent {
  final String linkId;

  const MagicLinkValidated({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkValidationFailed extends MagicLinkEvent {
  final Failure failure;

  const MagicLinkValidationFailed({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class MagicLinkConsumed extends MagicLinkEvent {
  final String linkId;

  const MagicLinkConsumed({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkResent extends MagicLinkEvent {
  final String linkId;

  const MagicLinkResent({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkResendFailed extends MagicLinkEvent {
  final Failure failure;

  const MagicLinkResendFailed({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class MagicLinkStatusChecked extends MagicLinkEvent {
  final String linkId;

  const MagicLinkStatusChecked({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

class MagicLinkStatusCheckFailed extends MagicLinkEvent {
  final Failure failure;

  const MagicLinkStatusCheckFailed({required this.failure});

  @override
  List<Object?> get props => [failure];
}

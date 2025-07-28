import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

/// Value object representing parameters for sending an invitation
class SendInvitationParams extends Equatable {
  final ProjectId projectId;
  final UserId?
  invitedByUserId; // Optional, will be set by use case if not provided
  final UserId? invitedUserId; // For existing users
  final String invitedEmail; // For new users
  final ProjectRole proposedRole;
  final String? message;
  final Duration? expirationDuration;

  const SendInvitationParams({
    required this.projectId,
    this.invitedByUserId,
    this.invitedUserId,
    required this.invitedEmail,
    required this.proposedRole,
    this.message,
    this.expirationDuration,
  });

  @override
  List<Object?> get props => [
    projectId,
    invitedByUserId,
    invitedUserId,
    invitedEmail,
    proposedRole,
    message,
    expirationDuration,
  ];
}

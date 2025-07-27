import 'package:equatable/equatable.dart';
import 'package:trackflow/core/error/failures.dart';

/// Domain failures for invitation-related operations

class InvitationFailure extends Failure {
  final String? code;

  const InvitationFailure(super.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
}

class NotificationFailure extends Failure {
  final String? code;

  const NotificationFailure(super.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
}

// Specific invitation failures
class InvitationNotFoundFailure extends InvitationFailure {
  const InvitationNotFoundFailure([String? message])
    : super(message ?? 'Invitation not found', code: 'INVITATION_NOT_FOUND');
}

class InvitationExpiredFailure extends InvitationFailure {
  const InvitationExpiredFailure([String? message])
    : super(message ?? 'Invitation has expired', code: 'INVITATION_EXPIRED');
}

class InvitationAlreadyProcessedFailure extends InvitationFailure {
  const InvitationAlreadyProcessedFailure([String? message])
    : super(
        message ?? 'Invitation has already been processed',
        code: 'INVITATION_ALREADY_PROCESSED',
      );
}

class InvitationCannotBeCancelledFailure extends InvitationFailure {
  const InvitationCannotBeCancelledFailure([String? message])
    : super(
        message ?? 'Invitation cannot be cancelled',
        code: 'INVITATION_CANNOT_BE_CANCELLED',
      );
}

class UserAlreadyInvitedFailure extends InvitationFailure {
  const UserAlreadyInvitedFailure([String? message])
    : super(
        message ?? 'User has already been invited to this project',
        code: 'USER_ALREADY_INVITED',
      );
}

class UserAlreadyCollaboratorFailure extends InvitationFailure {
  const UserAlreadyCollaboratorFailure([String? message])
    : super(
        message ?? 'User is already a collaborator on this project',
        code: 'USER_ALREADY_COLLABORATOR',
      );
}

class InvalidInvitationEmailFailure extends InvitationFailure {
  const InvalidInvitationEmailFailure([String? message])
    : super(
        message ?? 'Invalid email address for invitation',
        code: 'INVALID_INVITATION_EMAIL',
      );
}

// Specific notification failures
class NotificationNotFoundFailure extends NotificationFailure {
  const NotificationNotFoundFailure([String? message])
    : super(
        message ?? 'Notification not found',
        code: 'NOTIFICATION_NOT_FOUND',
      );
}

class NotificationAlreadyReadFailure extends NotificationFailure {
  const NotificationAlreadyReadFailure([String? message])
    : super(
        message ?? 'Notification is already marked as read',
        code: 'NOTIFICATION_ALREADY_READ',
      );
}

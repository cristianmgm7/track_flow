/// Domain exceptions for invitation-related operations
library;

class InvitationDomainException implements Exception {
  final String message;
  final String? code;

  const InvitationDomainException(this.message, {this.code});

  @override
  String toString() => 'InvitationDomainException: $message';
}

class InvitationNotFoundException extends InvitationDomainException {
  const InvitationNotFoundException([String? message])
    : super(message ?? 'Invitation not found', code: 'INVITATION_NOT_FOUND');
}

class InvitationExpiredException extends InvitationDomainException {
  const InvitationExpiredException([String? message])
    : super(message ?? 'Invitation has expired', code: 'INVITATION_EXPIRED');
}

class InvitationAlreadyProcessedException extends InvitationDomainException {
  const InvitationAlreadyProcessedException([String? message])
    : super(
        message ?? 'Invitation has already been processed',
        code: 'INVITATION_ALREADY_PROCESSED',
      );
}

class InvitationCannotBeCancelledException extends InvitationDomainException {
  const InvitationCannotBeCancelledException([String? message])
    : super(
        message ?? 'Invitation cannot be cancelled',
        code: 'INVITATION_CANNOT_BE_CANCELLED',
      );
}

class UserAlreadyInvitedException extends InvitationDomainException {
  const UserAlreadyInvitedException([String? message])
    : super(
        message ?? 'User has already been invited to this project',
        code: 'USER_ALREADY_INVITED',
      );
}

class UserAlreadyCollaboratorException extends InvitationDomainException {
  const UserAlreadyCollaboratorException([String? message])
    : super(
        message ?? 'User is already a collaborator on this project',
        code: 'USER_ALREADY_COLLABORATOR',
      );
}

class InvalidInvitationEmailException extends InvitationDomainException {
  const InvalidInvitationEmailException([String? message])
    : super(
        message ?? 'Invalid email address for invitation',
        code: 'INVALID_INVITATION_EMAIL',
      );
}

class NotificationDomainException implements Exception {
  final String message;
  final String? code;

  const NotificationDomainException(this.message, {this.code});

  @override
  String toString() => 'NotificationDomainException: $message';
}

class NotificationNotFoundException extends NotificationDomainException {
  const NotificationNotFoundException([String? message])
    : super(
        message ?? 'Notification not found',
        code: 'NOTIFICATION_NOT_FOUND',
      );
}

class NotificationAlreadyReadException extends NotificationDomainException {
  const NotificationAlreadyReadException([String? message])
    : super(
        message ?? 'Notification is already marked as read',
        code: 'NOTIFICATION_ALREADY_READ',
      );
}

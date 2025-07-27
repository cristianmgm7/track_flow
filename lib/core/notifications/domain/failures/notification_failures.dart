import 'package:trackflow/core/error/failures.dart';

/// Domain failures for notification-related operations

class NotificationFailure extends Failure {
  final String? code;

  const NotificationFailure(super.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
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

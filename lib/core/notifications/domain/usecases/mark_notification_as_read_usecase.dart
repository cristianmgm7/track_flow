import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';

/// Use case to mark a notification as read
@lazySingleton
class MarkNotificationAsReadUseCase {
  final NotificationRepository _notificationRepository;

  MarkNotificationAsReadUseCase(this._notificationRepository);

  /// Mark a notification as read
  /// Returns the updated notification
  Future<Either<Failure, Notification>> call(NotificationId notificationId) {
    return _notificationRepository.markAsRead(notificationId);
  }
}

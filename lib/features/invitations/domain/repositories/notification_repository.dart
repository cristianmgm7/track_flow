import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_entity.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_id.dart';

/// Repository responsible for notification operations
abstract class NotificationRepository {
  // Actor methods (for actions)

  /// Create a new notification
  Future<Either<Failure, NotificationEntity>> createNotification(
    NotificationEntity notification,
  );

  /// Mark a notification as read
  Future<Either<Failure, NotificationEntity>> markAsRead(
    NotificationId notificationId,
  );

  /// Mark a notification as unread
  Future<Either<Failure, NotificationEntity>> markAsUnread(
    NotificationId notificationId,
  );

  /// Mark all notifications as read for a user
  Future<Either<Failure, Unit>> markAllAsRead(UserId userId);

  /// Delete a notification
  Future<Either<Failure, Unit>> deleteNotification(
    NotificationId notificationId,
  );

  /// Delete all notifications for a user
  Future<Either<Failure, Unit>> deleteAllNotifications(UserId userId);

  // Watcher methods (for observing)

  /// Watch all notifications for a user
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications(
    UserId userId,
  );

  /// Watch unread notifications for a user
  Stream<Either<Failure, List<NotificationEntity>>> watchUnreadNotifications(
    UserId userId,
  );

  /// Get a specific notification by ID
  Future<Either<Failure, NotificationEntity?>> getNotificationById(
    NotificationId notificationId,
  );

  /// Get unread notifications count for a user
  Future<Either<Failure, int>> getUnreadNotificationsCount(UserId userId);

  /// Get total notifications count for a user
  Future<Either<Failure, int>> getTotalNotificationsCount(UserId userId);
}

import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';

// =============================================================================
// WATCHER EVENTS
// =============================================================================

/// Base event for notification watcher
abstract class NotificationWatcherEvent extends Equatable {
  const NotificationWatcherEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start watching all notifications
class WatchAllNotifications extends NotificationWatcherEvent {
  const WatchAllNotifications();
}

/// Event to start watching unread notifications
class WatchUnreadNotifications extends NotificationWatcherEvent {
  const WatchUnreadNotifications();
}

/// Event to start watching notification count
class WatchNotificationCount extends NotificationWatcherEvent {
  const WatchNotificationCount();
}

/// Event to stop watching notifications
class StopWatchingNotifications extends NotificationWatcherEvent {
  const StopWatchingNotifications();
}

// =============================================================================
// ACTOR EVENTS
// =============================================================================

/// Base event for notification actor
abstract class NotificationActorEvent extends Equatable {
  const NotificationActorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a notification
class CreateNotification extends NotificationActorEvent {
  final Notification notification;

  const CreateNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// Event to mark a notification as read
class MarkAsRead extends NotificationActorEvent {
  final NotificationId notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark a notification as unread
class MarkAsUnread extends NotificationActorEvent {
  final NotificationId notificationId;

  const MarkAsUnread(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class MarkAllAsRead extends NotificationActorEvent {
  const MarkAllAsRead();
}

/// Event to delete a notification
class DeleteNotification extends NotificationActorEvent {
  final NotificationId notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to reset actor state
class ResetNotificationActorState extends NotificationActorEvent {
  const ResetNotificationActorState();
}

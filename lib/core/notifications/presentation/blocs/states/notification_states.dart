import 'package:equatable/equatable.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';

// =============================================================================
// WATCHER STATES
// =============================================================================

/// Base state for notification watcher
abstract class NotificationWatcherState extends Equatable {
  const NotificationWatcherState();

  @override
  List<Object?> get props => [];
}

/// Initial state for notification watcher
class NotificationWatcherInitial extends NotificationWatcherState {
  const NotificationWatcherInitial();
}

/// Loading state for notification watcher
class NotificationWatcherLoading extends NotificationWatcherState {
  const NotificationWatcherLoading();
}

/// Success state for notification watcher
class NotificationWatcherSuccess extends NotificationWatcherState {
  final List<Notification> notifications;

  const NotificationWatcherSuccess(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Error state for notification watcher
class NotificationWatcherError extends NotificationWatcherState {
  final String message;

  const NotificationWatcherError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// ACTOR STATES
// =============================================================================

/// Base state for notification actor
abstract class NotificationActorState extends Equatable {
  const NotificationActorState();

  @override
  List<Object?> get props => [];
}

/// Initial state for notification actor
class NotificationActorInitial extends NotificationActorState {
  const NotificationActorInitial();
}

/// Loading state for notification actor
class NotificationActorLoading extends NotificationActorState {
  const NotificationActorLoading();
}

/// Success state for notification actor
class NotificationActorSuccess extends NotificationActorState {
  final String message;
  final Notification? notification;

  const NotificationActorSuccess({required this.message, this.notification});

  @override
  List<Object?> get props => [message, notification];
}

/// Error state for notification actor
class NotificationActorError extends NotificationActorState {
  final String message;

  const NotificationActorError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// SPECIFIC WATCHER STATES
// =============================================================================

/// State for all notifications watcher
class AllNotificationsWatcherState extends NotificationWatcherState {
  final List<Notification> notifications;

  const AllNotificationsWatcherState(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// State for unread notifications watcher
class UnreadNotificationsWatcherState extends NotificationWatcherState {
  final List<Notification> unreadNotifications;

  const UnreadNotificationsWatcherState(this.unreadNotifications);

  @override
  List<Object?> get props => [unreadNotifications];
}

/// State for notification count watcher
class NotificationCountWatcherState extends NotificationWatcherState {
  final int unreadCount;

  const NotificationCountWatcherState(this.unreadCount);

  @override
  List<Object?> get props => [unreadCount];
}

// =============================================================================
// SPECIFIC ACTOR STATES
// =============================================================================

/// State for create notification action
class CreateNotificationSuccess extends NotificationActorSuccess {
  const CreateNotificationSuccess({
    required super.message,
    required Notification super.notification,
  });
}

/// State for mark as read action
class MarkAsReadSuccess extends NotificationActorSuccess {
  const MarkAsReadSuccess({
    required super.message,
    required Notification super.notification,
  });
}

/// State for mark as unread action
class MarkAsUnreadSuccess extends NotificationActorSuccess {
  const MarkAsUnreadSuccess({
    required super.message,
    required Notification super.notification,
  });
}

/// State for mark all as read action
class MarkAllAsReadSuccess extends NotificationActorSuccess {
  const MarkAllAsReadSuccess({required super.message});
}

/// State for delete notification action
class DeleteNotificationSuccess extends NotificationActorSuccess {
  const DeleteNotificationSuccess({required super.message});
}

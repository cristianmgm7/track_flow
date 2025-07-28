import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:trackflow/core/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:trackflow/core/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:trackflow/core/notifications/domain/usecases/mark_as_unread_usecase.dart';
import 'package:trackflow/core/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:trackflow/core/notifications/presentation/blocs/events/notification_events.dart';
import 'package:trackflow/core/notifications/presentation/blocs/states/notification_states.dart';

@injectable
class NotificationActorBloc
    extends Bloc<NotificationActorEvent, NotificationActorState> {
  final CreateNotificationUseCase _createNotificationUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final MarkAsUnreadUseCase _markAsUnreadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;

  NotificationActorBloc({
    required CreateNotificationUseCase createNotificationUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required MarkAsUnreadUseCase markAsUnreadUseCase,
    required MarkAllNotificationsAsReadUseCase markAllAsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
  }) : _createNotificationUseCase = createNotificationUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _markAsUnreadUseCase = markAsUnreadUseCase,
       _markAllAsReadUseCase = markAllAsReadUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       super(const NotificationActorInitial()) {
    on<CreateNotification>(_onCreateNotification);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAsUnread>(_onMarkAsUnread);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ResetNotificationActorState>(_onResetNotificationActorState);
  }

  /// Create a notification
  Future<void> _onCreateNotification(
    CreateNotification event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorLoading());

    final result = await _createNotificationUseCase(event.notification);

    result.fold(
      (failure) => emit(NotificationActorError(failure.message)),
      (notification) => emit(
        CreateNotificationSuccess(
          message: 'Notification created successfully',
          notification: notification,
        ),
      ),
    );
  }

  /// Mark a notification as read
  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorLoading());

    final result = await _markAsReadUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationActorError(failure.message)),
      (notification) => emit(
        MarkAsReadSuccess(
          message: 'Notification marked as read',
          notification: notification,
        ),
      ),
    );
  }

  /// Mark a notification as unread
  Future<void> _onMarkAsUnread(
    MarkAsUnread event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorLoading());

    final result = await _markAsUnreadUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationActorError(failure.message)),
      (notification) => emit(
        MarkAsUnreadSuccess(
          message: 'Notification marked as unread',
          notification: notification,
        ),
      ),
    );
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorLoading());

    final result = await _markAllAsReadUseCase(event.userId);

    result.fold(
      (failure) => emit(NotificationActorError(failure.message)),
      (_) => emit(
        const MarkAllAsReadSuccess(message: 'All notifications marked as read'),
      ),
    );
  }

  /// Delete a notification
  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorLoading());

    final result = await _deleteNotificationUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationActorError(failure.message)),
      (_) => emit(
        const DeleteNotificationSuccess(
          message: 'Notification deleted successfully',
        ),
      ),
    );
  }

  /// Reset actor state
  Future<void> _onResetNotificationActorState(
    ResetNotificationActorState event,
    Emitter<NotificationActorState> emit,
  ) async {
    emit(const NotificationActorInitial());
  }
}

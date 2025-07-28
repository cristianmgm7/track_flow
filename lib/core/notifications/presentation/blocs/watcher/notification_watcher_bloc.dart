import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/session/current_user_service.dart';
import 'package:trackflow/core/notifications/presentation/blocs/events/notification_events.dart';
import 'package:trackflow/core/notifications/presentation/blocs/states/notification_states.dart';

@injectable
class NotificationWatcherBloc
    extends Bloc<NotificationWatcherEvent, NotificationWatcherState> {
  final NotificationRepository _notificationRepository;
  final CurrentUserService _currentUserService;

  NotificationWatcherBloc({
    required NotificationRepository notificationRepository,
    required CurrentUserService currentUserService,
  }) : _notificationRepository = notificationRepository,
       _currentUserService = currentUserService,
       super(NotificationWatcherInitial()) {
    on<WatchAllNotifications>(_onWatchAllNotifications);
    on<WatchUnreadNotifications>(_onWatchUnreadNotifications);
    on<WatchNotificationCount>(_onWatchNotificationCount);
    on<StopWatchingNotifications>(_onStopWatchingNotifications);
  }

  /// Watch all notifications for a user
  Future<void> _onWatchAllNotifications(
    WatchAllNotifications event,
    Emitter<NotificationWatcherState> emit,
  ) async {
    emit(NotificationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<Notification>>>(
        _notificationRepository.watchNotifications(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(NotificationWatcherError(failure.message)),
            (notifications) =>
                emit(AllNotificationsWatcherState(notifications)),
          );
        },
        onError: (error, stackTrace) {
          emit(NotificationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(NotificationWatcherError(e.toString()));
    }
  }

  /// Watch unread notifications for a user
  Future<void> _onWatchUnreadNotifications(
    WatchUnreadNotifications event,
    Emitter<NotificationWatcherState> emit,
  ) async {
    emit(NotificationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<Notification>>>(
        _notificationRepository.watchUnreadNotifications(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(NotificationWatcherError(failure.message)),
            (notifications) =>
                emit(UnreadNotificationsWatcherState(notifications)),
          );
        },
        onError: (error, stackTrace) {
          emit(NotificationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(NotificationWatcherError(e.toString()));
    }
  }

  /// Watch notification count for a user
  Future<void> _onWatchNotificationCount(
    WatchNotificationCount event,
    Emitter<NotificationWatcherState> emit,
  ) async {
    emit(NotificationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<Notification>>>(
        _notificationRepository.watchUnreadNotifications(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(NotificationWatcherError(failure.message)),
            (notifications) =>
                emit(NotificationCountWatcherState(notifications.length)),
          );
        },
        onError: (error, stackTrace) {
          emit(NotificationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(NotificationWatcherError(e.toString()));
    }
  }

  /// Stop watching notifications
  Future<void> _onStopWatchingNotifications(
    StopWatchingNotifications event,
    Emitter<NotificationWatcherState> emit,
  ) async {
    emit(NotificationWatcherInitial());
  }

  @override
  Future<void> close() {
    // Clean up any subscriptions if needed
    return super.close();
  }
}

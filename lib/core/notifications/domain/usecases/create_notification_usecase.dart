import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';

@injectable
class CreateNotificationUseCase {
  final NotificationRepository _notificationRepository;

  CreateNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, Notification>> call(Notification notification) async {
    return await _notificationRepository.createNotification(notification);
  }
}

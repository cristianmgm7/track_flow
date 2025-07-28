import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/notifications/data/models/notification_dto.dart';
import 'package:trackflow/core/notifications/data/models/notification_document.dart';

abstract class NotificationLocalDataSource {
  /// Cache a notification locally
  Future<void> cacheNotification(NotificationDto notification);

  /// Get a notification by ID
  Future<NotificationDto?> getNotificationById(String notificationId);

  /// Watch a notification by ID (reactive)
  Stream<NotificationDto?> watchNotificationById(String notificationId);

  /// Get all notifications for a user
  Future<List<NotificationDto>> getNotificationsForUser(String userId);

  /// Watch all notifications for a user (reactive)
  Stream<List<NotificationDto>> watchNotificationsForUser(String userId);

  /// Get unread notifications for a user
  Future<List<NotificationDto>> getUnreadNotificationsForUser(String userId);

  /// Watch unread notifications for a user (reactive)
  Stream<List<NotificationDto>> watchUnreadNotificationsForUser(String userId);

  /// Update a notification
  Future<void> updateNotification(NotificationDto notification);

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId);

  /// Clear all cached notifications
  Future<void> clearCache();

  /// Get unread notifications count for a user
  Future<int> getUnreadNotificationsCount(String userId);
}

@LazySingleton(as: NotificationLocalDataSource)
class IsarNotificationLocalDataSource implements NotificationLocalDataSource {
  final Isar _isar;

  IsarNotificationLocalDataSource(this._isar);

  @override
  Future<void> cacheNotification(NotificationDto notification) async {
    final notificationDoc = NotificationDocument.fromDTO(notification);
    await _isar.writeTxn(() async {
      await _isar.notificationDocuments.put(notificationDoc);
    });
  }

  @override
  Future<NotificationDto?> getNotificationById(String notificationId) async {
    final doc =
        await _isar.notificationDocuments
            .where()
            .idEqualTo(notificationId)
            .findFirst();
    return doc?.toDTO();
  }

  @override
  Stream<NotificationDto?> watchNotificationById(String notificationId) {
    return _isar.notificationDocuments
        .watchObject(fastHash(notificationId), fireImmediately: true)
        .map((doc) => doc?.toDTO());
  }

  @override
  Future<List<NotificationDto>> getNotificationsForUser(String userId) async {
    final docs =
        await _isar.notificationDocuments
            .where()
            .filter()
            .recipientUserIdEqualTo(userId)
            .sortByTimestampDesc()
            .findAll();
    return docs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<NotificationDto>> watchNotificationsForUser(String userId) {
    return _isar.notificationDocuments
        .where()
        .filter()
        .recipientUserIdEqualTo(userId)
        .sortByTimestampDesc()
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }

  @override
  Future<List<NotificationDto>> getUnreadNotificationsForUser(
    String userId,
  ) async {
    final docs =
        await _isar.notificationDocuments
            .where()
            .filter()
            .recipientUserIdEqualTo(userId)
            .and()
            .isReadEqualTo(false)
            .sortByTimestampDesc()
            .findAll();
    return docs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<NotificationDto>> watchUnreadNotificationsForUser(String userId) {
    return _isar.notificationDocuments
        .where()
        .filter()
        .recipientUserIdEqualTo(userId)
        .and()
        .isReadEqualTo(false)
        .sortByTimestampDesc()
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }

  @override
  Future<void> updateNotification(NotificationDto notification) async {
    final notificationDoc = NotificationDocument.fromDTO(notification);
    await _isar.writeTxn(() async {
      await _isar.notificationDocuments.put(notificationDoc);
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _isar.writeTxn(() async {
      await _isar.notificationDocuments.delete(fastHash(notificationId));
    });
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _isar.writeTxn(() async {
      final doc =
          await _isar.notificationDocuments
              .where()
              .idEqualTo(notificationId)
              .findFirst();

      if (doc != null) {
        doc.isRead = true;
        await _isar.notificationDocuments.put(doc);
      }
    });
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    await _isar.writeTxn(() async {
      final docs =
          await _isar.notificationDocuments
              .where()
              .filter()
              .recipientUserIdEqualTo(userId)
              .and()
              .isReadEqualTo(false)
              .findAll();

      for (final doc in docs) {
        doc.isRead = true;
      }

      await _isar.notificationDocuments.putAll(docs);
    });
  }

  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.notificationDocuments.clear();
    });
  }

  @override
  Future<int> getUnreadNotificationsCount(String userId) async {
    final count =
        await _isar.notificationDocuments
            .where()
            .filter()
            .recipientUserIdEqualTo(userId)
            .and()
            .isReadEqualTo(false)
            .count();
    return count;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/data/models/notification_dto.dart';

abstract class NotificationRemoteDataSource {
  /// Create a new notification
  Future<Either<Failure, NotificationDto>> createNotification(
    NotificationDto notification,
  );

  /// Get a notification by ID
  Future<Either<Failure, NotificationDto>> getNotificationById(
    String notificationId,
  );

  /// Update a notification
  Future<Either<Failure, NotificationDto>> updateNotification(
    NotificationDto notification,
  );

  /// Delete a notification
  Future<Either<Failure, Unit>> deleteNotification(String notificationId);

  /// Get all notifications for a user
  Future<Either<Failure, List<NotificationDto>>> getNotificationsForUser(
    String userId,
  );

  /// Get unread notifications for a user
  Future<Either<Failure, List<NotificationDto>>> getUnreadNotificationsForUser(
    String userId,
  );

  /// Mark a notification as read
  Future<Either<Failure, Unit>> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(String userId);

  /// Get unread notifications count for a user
  Future<Either<Failure, int>> getUnreadNotificationsCount(String userId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class FirestoreNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreNotificationRemoteDataSource(this._firestore);

  @override
  Future<Either<Failure, NotificationDto>> createNotification(
    NotificationDto notification,
  ) async {
    try {
      await _firestore
          .collection(NotificationDto.collection)
          .doc(notification.id)
          .set(notification.toJson());
      return Right(notification);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create notification'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationDto>> getNotificationById(
    String notificationId,
  ) async {
    try {
      final doc =
          await _firestore
              .collection(NotificationDto.collection)
              .doc(notificationId)
              .get();

      if (!doc.exists) {
        return Left(DatabaseFailure('Notification not found'));
      }

      return Right(NotificationDto.fromJson(doc.data()!));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get notification'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationDto>> updateNotification(
    NotificationDto notification,
  ) async {
    try {
      await _firestore
          .collection(NotificationDto.collection)
          .doc(notification.id)
          .update(notification.toJson());
      return Right(notification);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update notification'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection(NotificationDto.collection)
          .doc(notificationId)
          .delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete notification'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationDto>>> getNotificationsForUser(
    String userId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(NotificationDto.collection)
              .where('recipientUserId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      final notifications =
          query.docs
              .map((doc) => NotificationDto.fromJson(doc.data()))
              .toList();

      return Right(notifications);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get notifications'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationDto>>> getUnreadNotificationsForUser(
    String userId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(NotificationDto.collection)
              .where('recipientUserId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .orderBy('timestamp', descending: true)
              .get();

      final notifications =
          query.docs
              .map((doc) => NotificationDto.fromJson(doc.data()))
              .toList();

      return Right(notifications);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to get unread notifications'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection(NotificationDto.collection)
          .doc(notificationId)
          .update({
            'isRead': true,
            'lastModified': DateTime.now().toIso8601String(),
          });
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to mark notification as read'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
    String userId,
  ) async {
    try {
      final batch = _firestore.batch();

      final query =
          await _firestore
              .collection(NotificationDto.collection)
              .where('recipientUserId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'lastModified': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to mark all notifications as read'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount(
    String userId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(NotificationDto.collection)
              .where('recipientUserId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      return Right(query.docs.length);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to get unread notifications count'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/notifications/data/datasources/notification_local_datasource.dart';
import 'package:trackflow/core/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:trackflow/core/notifications/data/models/notification_dto.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  final NotificationRemoteDataSource _remoteDataSource;
  final NetworkStateManager _networkStateManager;

  NotificationRepositoryImpl({
    required NotificationLocalDataSource localDataSource,
    required NotificationRemoteDataSource remoteDataSource,
    required NetworkStateManager networkStateManager,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkStateManager = networkStateManager;

  // Actor Methods (for performing actions)

  @override
  Future<Either<Failure, Notification>> createNotification(
    Notification notification,
  ) async {
    try {
      // Convert to DTO
      final notificationDto = NotificationDto.fromDomain(notification);

      // OFFLINE-FIRST: Save locally immediately
      await _localDataSource.cacheNotification(notificationDto);

      // Try to sync to remote if connected
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.createNotification(
            notificationDto,
          );
          remoteResult.fold(
            (failure) {
              AppLogger.warning(
                'Failed to sync notification to remote: ${failure.message}',
                tag: 'NotificationRepository',
              );
              // Don't fail the operation - local save was successful
            },
            (_) {
              AppLogger.info(
                'Notification synced to remote successfully',
                tag: 'NotificationRepository',
              );
            },
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local save was successful: $e',
          tag: 'NotificationRepository',
        );
        // Don't fail the operation - local save was successful
      }

      return Right(notification);
    } catch (e) {
      return Left(ServerFailure('Failed to create notification: $e'));
    }
  }

  Future<Either<Failure, Notification>> markNotificationAsRead(
    NotificationId notificationId,
  ) async {
    try {
      // Get the notification
      final notificationResult = await getNotificationById(notificationId);

      return notificationResult.fold((failure) => Left(failure), (
        notification,
      ) async {
        if (notification == null) {
          return Left(ServerFailure('Notification not found'));
        }

        // Mark as read using domain logic
        final readNotification = notification.markAsRead();
        final notificationDto = NotificationDto.fromDomain(readNotification);

        // Update locally immediately
        await _localDataSource.updateNotification(notificationDto);

        // Try to sync to remote if connected
        try {
          final isConnected = await _networkStateManager.isConnected;
          if (isConnected) {
            final remoteResult = await _remoteDataSource.updateNotification(
              notificationDto,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync read notification to remote: ${failure.message}',
                  tag: 'NotificationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Read notification synced to remote successfully',
                  tag: 'NotificationRepository',
                );
              },
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background sync failed, but local update was successful: $e',
            tag: 'NotificationRepository',
          );
        }

        return Right(readNotification);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
    UserId userId,
  ) async {
    try {
      // Update locally immediately
      await _localDataSource.markAllNotificationsAsRead(userId.value);

      // Try to sync to remote if connected
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource
              .markAllNotificationsAsRead(userId.value);
          remoteResult.fold(
            (failure) {
              AppLogger.warning(
                'Failed to sync mark all as read to remote: ${failure.message}',
                tag: 'NotificationRepository',
              );
            },
            (_) {
              AppLogger.info(
                'Mark all as read synced to remote successfully',
                tag: 'NotificationRepository',
              );
            },
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local update was successful: $e',
          tag: 'NotificationRepository',
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark all notifications as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNotification(
    NotificationId notificationId,
  ) async {
    try {
      // Delete locally immediately
      await _localDataSource.deleteNotification(notificationId.value);

      // Try to sync to remote if connected
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.deleteNotification(
            notificationId.value,
          );
          remoteResult.fold(
            (failure) {
              AppLogger.warning(
                'Failed to sync delete notification to remote: ${failure.message}',
                tag: 'NotificationRepository',
              );
            },
            (_) {
              AppLogger.info(
                'Delete notification synced to remote successfully',
                tag: 'NotificationRepository',
              );
            },
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local delete was successful: $e',
          tag: 'NotificationRepository',
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete notification: $e'));
    }
  }

  // Watcher Methods (for observing data)

  @override
  Future<Either<Failure, Notification?>> getNotificationById(
    NotificationId notificationId,
  ) async {
    try {
      // Try to get from local cache first
      final localNotification = await _localDataSource.getNotificationById(
        notificationId.value,
      );

      if (localNotification != null) {
        return Right(localNotification.toDomain());
      }

      // If not in local cache, try to sync from remote
      final syncResult = await syncNotificationFromRemote(notificationId);
      return syncResult.fold(
        (failure) => Left(failure),
        (notification) => Right(notification),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get notification: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Notification>>> watchNotifications(
    UserId userId,
  ) async* {
    try {
      // Return local data immediately
      await for (final dtos in _localDataSource.watchNotificationsForUser(
        userId.value,
      )) {
        yield Right(dtos.map((dto) => dto.toDomain()).toList());
      }
    } catch (e) {
      yield Left(DatabaseFailure('Failed to watch notifications: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<Notification>>> watchUnreadNotifications(
    UserId userId,
  ) async* {
    try {
      // Return local data immediately
      await for (final dtos in _localDataSource.watchUnreadNotificationsForUser(
        userId.value,
      )) {
        yield Right(dtos.map((dto) => dto.toDomain()).toList());
      }
    } catch (e) {
      yield Left(DatabaseFailure('Failed to watch unread notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount(
    UserId userId,
  ) async {
    try {
      // Get count from local cache
      final count = await _localDataSource.getUnreadNotificationsCount(
        userId.value,
      );
      return Right(count);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get unread notifications count: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Notification>> markAsRead(
    NotificationId notificationId,
  ) async {
    return markNotificationAsRead(notificationId);
  }

  @override
  Future<Either<Failure, Notification>> markAsUnread(
    NotificationId notificationId,
  ) async {
    try {
      // Get the notification
      final notificationResult = await getNotificationById(notificationId);

      return notificationResult.fold((failure) => Left(failure), (
        notification,
      ) async {
        if (notification == null) {
          return Left(ServerFailure('Notification not found'));
        }

        // Mark as unread using domain logic
        final unreadNotification = notification.markAsUnread();
        final notificationDto = NotificationDto.fromDomain(unreadNotification);

        // Update locally immediately
        await _localDataSource.updateNotification(notificationDto);

        // Try to sync to remote if connected
        try {
          final isConnected = await _networkStateManager.isConnected;
          if (isConnected) {
            final remoteResult = await _remoteDataSource.updateNotification(
              notificationDto,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync unread notification to remote: ${failure.message}',
                  tag: 'NotificationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Unread notification synced to remote successfully',
                  tag: 'NotificationRepository',
                );
              },
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background sync failed, but local update was successful: $e',
            tag: 'NotificationRepository',
          );
        }

        return Right(unreadNotification);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as unread: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead(UserId userId) async {
    return markAllNotificationsAsRead(userId);
  }

  @override
  Future<Either<Failure, Unit>> deleteAllNotifications(UserId userId) async {
    try {
      // Get all notifications for the user
      final notifications = await _localDataSource.getNotificationsForUser(
        userId.value,
      );

      // Delete all locally
      for (final notification in notifications) {
        await _localDataSource.deleteNotification(notification.id);
      }

      // Try to sync to remote if connected
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          // Note: This is a simplified approach. In a real app, you might want to batch delete
          for (final notification in notifications) {
            final remoteResult = await _remoteDataSource.deleteNotification(
              notification.id,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync delete notification to remote: ${failure.message}',
                  tag: 'NotificationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Delete notification synced to remote successfully',
                  tag: 'NotificationRepository',
                );
              },
            );
          }
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local delete was successful: $e',
          tag: 'NotificationRepository',
        );
      }

      return Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalNotificationsCount(UserId userId) async {
    try {
      // Get all notifications for the user
      final notifications = await _localDataSource.getNotificationsForUser(
        userId.value,
      );
      return Right(notifications.length);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get total notifications count: $e'),
      );
    }
  }

  // Helper Methods

  Future<Either<Failure, Notification?>> syncNotificationFromRemote(
    NotificationId notificationId,
  ) async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Left(DatabaseFailure('No internet connection'));
      }

      // Get notification from remote data source
      final remoteResult = await _remoteDataSource.getNotificationById(
        notificationId.value,
      );

      return remoteResult.fold((failure) => Left(failure), (
        remoteNotification,
      ) async {
        // Cache the notification locally
        await _localDataSource.cacheNotification(remoteNotification);
        return Right(remoteNotification.toDomain());
      });
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to sync notification from remote: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> syncNotificationsFromRemote(
    UserId userId,
  ) async {
    try {
      // Check if we have network connectivity
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        AppLogger.warning(
          'No network connection - skipping notification sync',
          tag: 'NotificationRepository',
        );
        return Left(NetworkFailure('No network connection available'));
      }

      AppLogger.info(
        'Starting notification sync from remote for user: ${userId.value}',
        tag: 'NotificationRepository',
      );

      // Fetch all notifications for the user from remote
      final remoteResult = await _remoteDataSource.getNotificationsForUser(
        userId.value,
      );

      return remoteResult.fold(
        (failure) {
          AppLogger.warning(
            'Failed to fetch notifications from remote: ${failure.message}',
            tag: 'NotificationRepository',
          );
          return Left(failure);
        },
        (remoteNotifications) async {
          // Get existing local notifications for comparison
          final localNotifications = await _localDataSource
              .getNotificationsForUser(userId.value);

          // Create a map of local notifications by ID for quick lookup
          final localNotificationMap = <String, NotificationDto>{
            for (final notification in localNotifications)
              notification.id: notification
          };

          int newCount = 0;
          int updatedCount = 0;

          // Process each remote notification
          for (final remoteNotification in remoteNotifications) {
            final localNotification = localNotificationMap[remoteNotification.id];

            if (localNotification == null) {
              // New notification - cache it locally
              await _localDataSource.cacheNotification(remoteNotification);
              newCount++;
            } else {
              // Check if remote notification is newer or different
              final remoteTimestamp = remoteNotification.timestamp;
              final localTimestamp = localNotification.timestamp;

              // Update if remote is newer, but preserve local read status
              // unless it was explicitly changed remotely
              if (remoteTimestamp.isAfter(localTimestamp) ||
                  _shouldUpdateNotification(localNotification, remoteNotification)) {
                
                // Preserve local read status if it was marked as read locally
                // but remote shows unread (user read it locally but sync hadn't happened)
                final updatedNotification = remoteNotification.copyWith(
                  isRead: localNotification.isRead || remoteNotification.isRead,
                );

                await _localDataSource.updateNotification(updatedNotification);
                updatedCount++;
              }
            }
          }

          AppLogger.info(
            'Notification sync completed - New: $newCount, Updated: $updatedCount',
            tag: 'NotificationRepository',
          );

          return Right(unit);
        },
      );
    } catch (e) {
      AppLogger.error(
        'Notification sync failed: $e',
        tag: 'NotificationRepository',
        error: e,
      );
      return Left(ServerFailure('Failed to sync notifications: $e'));
    }
  }

  /// Helper method to determine if a notification should be updated
  /// based on content changes, not just timestamp
  bool _shouldUpdateNotification(
    NotificationDto local,
    NotificationDto remote,
  ) {
    // Update if title, body, or payload changed
    return local.title != remote.title ||
        local.body != remote.body ||
        local.payload.toString() != remote.payload.toString();
  }
}

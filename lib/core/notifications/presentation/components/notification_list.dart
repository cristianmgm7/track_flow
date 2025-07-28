import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/loading/app_loading.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as app_notification;
import 'package:trackflow/core/notifications/presentation/components/notification_card.dart';

/// List component to display notifications
class NotificationList extends StatelessWidget {
  final List<app_notification.Notification> notifications;
  final bool isLoading;
  final bool isEmpty;
  final String? emptyMessage;
  final VoidCallback? onNotificationTap;
  final Function(app_notification.Notification)? onMarkAsRead;
  final Function(app_notification.Notification)? onDelete;
  final Map<String, bool> loadingStates; // notificationId -> isLoading

  const NotificationList({
    super.key,
    required this.notifications,
    this.isLoading = false,
    this.isEmpty = false,
    this.emptyMessage,
    this.onNotificationTap,
    this.onMarkAsRead,
    this.onDelete,
    this.loadingStates = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: AppLoading(message: 'Loading notifications...'),
      );
    }

    if (isEmpty || notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: notifications.length,
      separatorBuilder:
          (context, index) => SizedBox(height: Dimensions.space12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isLoading = loadingStates[notification.id.value] ?? false;

        return NotificationCard(
          notification: notification,
          onTap: onNotificationTap != null ? () => onNotificationTap!() : null,
          onMarkAsRead:
              onMarkAsRead != null ? () => onMarkAsRead!(notification) : null,
          onDelete: onDelete != null ? () => onDelete!(notification) : null,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: Dimensions.space16),
          Text(
            emptyMessage ?? 'No notifications',
            style: AppTextStyle.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'When you receive notifications, they will appear here',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// List component specifically for unread notifications
class UnreadNotificationList extends StatelessWidget {
  final List<app_notification.Notification> notifications;
  final bool isLoading;
  final VoidCallback? onNotificationTap;
  final Function(app_notification.Notification)? onMarkAsRead;
  final Function(app_notification.Notification)? onDelete;
  final Map<String, bool> loadingStates;

  const UnreadNotificationList({
    super.key,
    required this.notifications,
    this.isLoading = false,
    this.onNotificationTap,
    this.onMarkAsRead,
    this.onDelete,
    this.loadingStates = const {},
  });

  @override
  Widget build(BuildContext context) {
    final unreadNotifications =
        notifications.where((notification) => notification.isUnread).toList();

    return NotificationList(
      notifications: unreadNotifications,
      isLoading: isLoading,
      isEmpty: unreadNotifications.isEmpty,
      emptyMessage: 'No unread notifications',
      onNotificationTap: onNotificationTap,
      onMarkAsRead: onMarkAsRead,
      onDelete: onDelete,
      loadingStates: loadingStates,
    );
  }
}

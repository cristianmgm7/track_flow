import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/core/notifications/presentation/blocs/notifications_blocs.dart';
import 'package:trackflow/core/notifications/presentation/components/notification_list.dart';
import 'package:trackflow/features/invitations/presentation/widgets/invitation_count_badge.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as app_notification;

/// Main notification center screen
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start watching notifications
    // TODO: Get current user ID from auth service
    const currentUserId = UserId('current-user');
    context.read<NotificationWatcherBloc>().add(
      WatchAllNotifications(currentUserId),
    );
    context.read<NotificationWatcherBloc>().add(
      WatchNotificationCount(currentUserId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildTabBar(), Expanded(child: _buildTabBarView())],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Text(
        'Notifications',
        style: AppTextStyle.headlineSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        BlocBuilder<NotificationWatcherBloc, NotificationWatcherState>(
          builder: (context, state) {
            if (state is NotificationCountWatcherState) {
              return Padding(
                padding: EdgeInsets.only(right: Dimensions.space16),
                child: NotificationCountBadge(count: state.count),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
          onSelected: (value) {
            switch (value) {
              case 'mark_all_read':
                context.read<NotificationActorBloc>().add(
                  MarkAllAsRead(
                    userId: const UserId(
                      'current-user',
                    ), // TODO: Get current user ID
                  ),
                );
                break;
              case 'clear_all':
                // TODO: Implement clear all notifications
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: Dimensions.space8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: Dimensions.space8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyle.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyle.labelMedium,
        tabs: const [Tab(text: 'All'), Tab(text: 'Unread')],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [_buildAllNotificationsTab(), _buildUnreadNotificationsTab()],
    );
  }

  Widget _buildAllNotificationsTab() {
    return BlocBuilder<NotificationWatcherBloc, NotificationWatcherState>(
      builder: (context, state) {
        if (state is NotificationWatcherLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AllNotificationsWatcherState) {
          return NotificationList(
            notifications: state.notifications,
            onNotificationTap: (notification) {
              // TODO: Handle notification tap based on type
              _handleNotificationTap(notification);
            },
            onMarkAsRead: (notification) {
              context.read<NotificationActorBloc>().add(
                MarkAsRead(notificationId: notification.id),
              );
            },
            onDelete: (notification) {
              context.read<NotificationActorBloc>().add(
                DeleteNotification(notificationId: notification.id),
              );
            },
          );
        }

        if (state is NotificationWatcherError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                SizedBox(height: Dimensions.space16),
                Text(
                  'Error loading notifications',
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.space8),
                Text(
                  state.message,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimensions.space16),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<NotificationWatcherBloc>().add(
                      const WatchAllNotifications(),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No notifications'));
      },
    );
  }

  Widget _buildUnreadNotificationsTab() {
    return BlocBuilder<NotificationWatcherBloc, NotificationWatcherState>(
      builder: (context, state) {
        if (state is NotificationWatcherLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UnreadNotificationsWatcherState) {
          return UnreadNotificationList(
            notifications: state.notifications,
            onNotificationTap: (notification) {
              _handleNotificationTap(notification);
            },
            onMarkAsRead: (notification) {
              context.read<NotificationActorBloc>().add(
                MarkAsRead(notificationId: notification.id),
              );
            },
            onDelete: (notification) {
              context.read<NotificationActorBloc>().add(
                DeleteNotification(notificationId: notification.id),
              );
            },
          );
        }

        if (state is NotificationWatcherError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                SizedBox(height: Dimensions.space16),
                Text(
                  'Error loading notifications',
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.space8),
                Text(
                  state.message,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimensions.space16),
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<NotificationWatcherBloc>().add(
                      const WatchUnreadNotifications(),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No unread notifications'));
      },
    );
  }

  void _handleNotificationTap(app_notification.Notification notification) {
    // Handle different notification types
    switch (notification.type) {
      case app_notification.NotificationType.projectInvitation:
        // Navigate to invitation details or project
        if (notification.projectId != null) {
          // TODO: Navigate to project details
        }
        break;
      case app_notification.NotificationType.projectUpdate:
        if (notification.projectId != null) {
          // TODO: Navigate to project details
        }
        break;
      case app_notification.NotificationType.collaboratorJoined:
        if (notification.projectId != null) {
          // TODO: Navigate to project details
        }
        break;
      case app_notification.NotificationType.audioCommentAdded:
        // TODO: Navigate to audio comment
        break;
      case app_notification.NotificationType.audioTrackUploaded:
        // TODO: Navigate to audio track
        break;
      case app_notification.NotificationType.systemMessage:
        // System messages don't need navigation
        break;
    }

    // Mark as read when tapped
    if (notification.isUnread) {
      context.read<NotificationActorBloc>().add(
        MarkAsRead(notificationId: notification.id),
      );
    }
  }
}

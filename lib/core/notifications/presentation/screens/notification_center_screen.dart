import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/notifications/presentation/blocs/events/notification_events.dart';
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart';
import 'package:trackflow/core/notifications/presentation/blocs/states/notification_states.dart';
import 'package:trackflow/core/notifications/presentation/components/notification_list.dart';

/// Main notification center screen
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start watching notifications
    context.read<NotificationWatcherBloc>().add(const WatchAllNotifications());

    // Switch watcher based on active tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final watcherBloc = context.read<NotificationWatcherBloc>();
      if (_tabController.index == 0) {
        watcherBloc.add(const WatchAllNotifications());
      } else {
        watcherBloc.add(const WatchUnreadNotifications());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  // TODO: Implement mark all as read
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mark all as read coming soon!'),
                    ),
                  );
                  break;
                case 'clear_all':
                  // TODO: Implement clear all
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clear all coming soon!')),
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Text('Mark all as read'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Text('Clear all'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All'), Tab(text: 'Unread')],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Notifications Tab
          BlocBuilder<NotificationWatcherBloc, NotificationWatcherState>(
            builder: (context, state) {
              if (state is NotificationWatcherLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotificationWatcherError) {
                return Center(child: Text(state.message));
              }
              if (state is AllNotificationsWatcherState) {
                return NotificationList(
                  notifications: state.notifications,
                  isEmpty: state.notifications.isEmpty,
                );
              }
              // Fallback UI
              return const Center(child: Text('No notifications'));
            },
          ),
          // Unread Notifications Tab
          BlocBuilder<NotificationWatcherBloc, NotificationWatcherState>(
            builder: (context, state) {
              if (state is NotificationWatcherLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotificationWatcherError) {
                return Center(child: Text(state.message));
              }
              if (state is UnreadNotificationsWatcherState) {
                return NotificationList(
                  notifications: state.unreadNotifications,
                  isEmpty: state.unreadNotifications.isEmpty,
                );
              }
              // Fallback UI
              return const Center(child: Text('No unread notifications'));
            },
          ),
        ],
      ),
    );
  }
}

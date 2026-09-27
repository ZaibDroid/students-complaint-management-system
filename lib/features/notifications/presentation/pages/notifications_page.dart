import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/notification_tile.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.notifications),
      appBar: CustomAppBar(
        title: 'Notifications',
        subtitle: '${state.unreadCount} unread updates',
        actions: [
          if (state.notifications.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(notificationProvider.notifier).fetchNotifications(),
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.notifications.isEmpty) {
                return const LoadingWidget(message: 'Loading notifications...');
              }

              if (state.errorMessage != null && state.notifications.isEmpty) {
                return AppErrorWidget(
                  message: state.errorMessage!,
                  onRetry: () => ref.read(notificationProvider.notifier).fetchNotifications(),
                );
              }

              if (state.notifications.isEmpty) {
                return const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No Notifications Yet',
                  message: 'You will receive push notifications when your complaints are forwarded, reviewed, or resolved.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return NotificationTile(
                    title: notif.title,
                    message: notif.message,
                    createdAt: notif.createdAt,
                    isRead: notif.isRead,
                    type: notif.type,
                    onTap: () {
                      ref.read(notificationProvider.notifier).markAsRead(notif.id);
                      if (notif.referenceId != null) {
                        if (notif.type == 'new_notice') {
                          context.push(RouteNames.noticeDetailPath(notif.referenceId!));
                        } else {
                          context.push(RouteNames.complaintDetailPath(notif.referenceId!));
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

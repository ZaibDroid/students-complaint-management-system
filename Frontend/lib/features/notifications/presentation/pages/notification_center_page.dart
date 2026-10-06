import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/providers/notification_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';


class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Notices', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () async {
              if (user != null) {
                await ref.read(notificationServiceProvider).markAllAsRead(user.id);
                ref.invalidate(userNotificationsProvider);
              }
            },
            icon: const Icon(Icons.done_all, size: 20),
            label: const Text('Mark all as read'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: ['All', 'Complaints', 'Notices', 'System'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = category);
                    },
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? theme.primaryColor : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filteredNotifications = _selectedCategory == 'All'
                    ? notifications
                    : notifications.where((n) => n.category == _selectedCategory).toList();

                if (filteredNotifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No alerts here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                        const SizedBox(height: 8),
                        const Text('We couldn\'t find any notifications in this category.', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = filteredNotifications[index];
                    
                    Color notifColor;
                    IconData notifIcon;
                    
                    switch (notif.category) {
                      case 'Complaints':
                        notifColor = const Color(0xFF6366F1);
                        notifIcon = Icons.assignment_late;
                        break;
                      case 'Notices':
                        notifColor = const Color(0xFFF59E0B);
                        notifIcon = Icons.campaign;
                        break;
                      default:
                        notifColor = Colors.grey;
                        notifIcon = Icons.security;
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (!notif.isRead) {
                          await ref.read(notificationServiceProvider).markAsRead(notif.id);
                          ref.invalidate(userNotificationsProvider);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: notifColor,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: notifColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(notifIcon, color: notifColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text(notif.title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 16))),
                                                Row(
                                                  children: [
                                                    Text(timeago.format(notif.timestamp), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                                    if (!notif.isRead) ...[
                                                      const SizedBox(width: 8),
                                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle)),
                                                    ]
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(notif.body, style: const TextStyle(color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading notifications: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

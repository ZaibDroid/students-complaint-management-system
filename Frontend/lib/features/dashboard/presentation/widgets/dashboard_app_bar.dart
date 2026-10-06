import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/data/providers/notification_provider.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (user?.role.toLowerCase() == 'student') {
                context.push('/profile');
              } else {
                context.push('/staff_profile');
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: theme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome,',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                user?.name ?? 'Student',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          alignment: Alignment.center,
          child: IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(unreadNotificationCountProvider) > 0,
              label: Text(ref.watch(unreadNotificationCountProvider).toString()),
              child: const Icon(Icons.notifications_outlined, color: Colors.black87),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.push('/notification_center');
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

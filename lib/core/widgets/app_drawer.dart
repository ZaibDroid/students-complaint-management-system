import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/route_names.dart';
import 'confirmation_dialog.dart';
import 'drawer_tile.dart';
import 'user_avatar.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    name: user?.fullName ?? 'User',
                    imageUrl: user?.avatarUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'UET Member',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role?.displayName ?? 'Student',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerTile(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: currentRoute == RouteNames.dashboard,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.dashboard);
                    },
                  ),
                  DrawerTile(
                    icon: Icons.assignment_outlined,
                    title: 'Complaints',
                    isSelected: currentRoute == RouteNames.complaintsList,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.complaintsList);
                    },
                  ),
                  if (role?.isStaff != true)
                    DrawerTile(
                      icon: Icons.add_circle_outline,
                      title: 'Submit Complaint',
                      isSelected: currentRoute == RouteNames.submitComplaint,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RouteNames.submitComplaint);
                      },
                    ),
                  DrawerTile(
                    icon: Icons.campaign_outlined,
                    title: 'Notice Board',
                    isSelected: currentRoute == RouteNames.noticeBoard,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.noticeBoard);
                    },
                  ),
                  DrawerTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    isSelected: currentRoute == RouteNames.notifications,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.notifications);
                    },
                  ),
                  DrawerTile(
                    icon: Icons.school_outlined,
                    title: 'Batches & Advisers',
                    isSelected: currentRoute == RouteNames.batchManagement,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.batchManagement);
                    },
                  ),
                  if (role?.isAdmin == true || role?.isChairman == true)
                    DrawerTile(
                      icon: Icons.people_outline,
                      title: 'User Management',
                      isSelected: currentRoute == RouteNames.usersList,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RouteNames.usersList);
                      },
                    ),
                  if (role?.isAdmin == true)
                    DrawerTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Console',
                      isSelected: currentRoute == RouteNames.adminPanel,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RouteNames.adminPanel);
                      },
                    ),
                  DrawerTile(
                    icon: Icons.person_outline,
                    title: 'Profile Settings',
                    isSelected: currentRoute == RouteNames.profile,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RouteNames.profile);
                    },
                  ),
                ],
              ),
            ),

            // University Footer & Logout
            const Divider(color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.departmentName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Text(
                          AppStrings.universityName,
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: AppColors.statusRejected, size: 20),
                    tooltip: 'Logout',
                    onPressed: () async {
                      final confirm = await ConfirmationDialog.show(
                        context: context,
                        title: 'Log Out',
                        message: 'Are you sure you want to log out of DCMS?',
                        confirmText: 'Log Out',
                        confirmColor: AppColors.statusRejected,
                        icon: Icons.logout,
                      );
                      if (confirm == true) {
                        ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(RouteNames.login);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

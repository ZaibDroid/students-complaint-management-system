import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_complaint_managment_system/core/constants/app_colors.dart';
import 'package:student_complaint_managment_system/core/constants/app_strings.dart';
import 'package:student_complaint_managment_system/core/routes/route_names.dart';
import 'package:student_complaint_managment_system/core/utils/ui_helpers.dart';
import 'package:student_complaint_managment_system/core/widgets/app_drawer.dart';
import 'package:student_complaint_managment_system/core/widgets/confirmation_dialog.dart';
import 'package:student_complaint_managment_system/core/widgets/custom_app_bar.dart';
import 'package:student_complaint_managment_system/core/widgets/profile_tile.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/profile/presentation/providers/profile_provider.dart';
import 'package:student_complaint_managment_system/shared/enums/user_role.dart';
import '../widgets/profile_user_header.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final fullName = profile?.fullName ?? authUser?.fullName ?? 'User';
    final email = profile?.email ?? authUser?.email ?? '';
    final role = profile?.role ?? authUser?.role ?? UserRole.student;
    final regNo = profile?.regNo ?? authUser?.regNo ?? '22MRCS042';
    final batch = profile?.batch ?? authUser?.batch ?? '2022-2026';
    final section = profile?.section ?? authUser?.section ?? 'Section A';
    final avatarUrl = profile?.avatarUrl ?? authUser?.avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.profile),
      appBar: const CustomAppBar(title: 'My Profile', subtitle: 'Academic and account information'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.page,
          child: Column(
            children: [
              // User Card Header
              ProfileUserHeader(
                fullName: fullName,
                email: email,
                role: role,
                avatarUrl: avatarUrl,
              ),
              AppSpacing.v20,

              // Academic Details Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Academic Information',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              AppSpacing.v10,
              ProfileTile(
                icon: Icons.badge_outlined,
                title: 'Registration Number',
                subtitle: regNo,
                trailing: const SizedBox.shrink(),
              ),
              ProfileTile(
                icon: Icons.calendar_today_outlined,
                title: 'Batch Session',
                subtitle: batch,
                trailing: const SizedBox.shrink(),
              ),
              ProfileTile(
                icon: Icons.class_outlined,
                title: 'Assigned Section',
                subtitle: section,
                trailing: const SizedBox.shrink(),
              ),
              const ProfileTile(
                icon: Icons.account_balance_outlined,
                title: 'Department',
                subtitle: AppStrings.departmentName,
                trailing: SizedBox.shrink(),
              ),
              AppSpacing.v20,

              // Account & Security Options
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              AppSpacing.v10,
              ProfileTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile Information',
                subtitle: 'Update phone number and details',
                onTap: () => context.push(RouteNames.editProfile),
              ),
              ProfileTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update account password',
                onTap: () => context.push(RouteNames.changePassword),
              ),
              ProfileTile(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out of DCMS on this device',
                iconColor: AppColors.statusRejected,
                titleColor: AppColors.statusRejected,
                onTap: () async {
                  final confirm = await ConfirmationDialog.show(
                    context: context,
                    title: 'Log Out',
                    message: 'Are you sure you want to log out?',
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
              AppSpacing.v32,
            ],
          ),
        ),
      ),
    );
  }
}

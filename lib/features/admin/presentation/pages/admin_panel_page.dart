import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/profile_tile.dart';

class AdminPanelPage extends ConsumerWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.adminPanel),
      appBar: const CustomAppBar(
        title: 'Department Admin Console',
        subtitle: 'System governance, roles, and archival records',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Health & Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              AppSpacing.v12,
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  DashboardCard(
                    title: 'Total Registered Users',
                    value: '450+',
                    icon: Icons.people_outline,
                    onTap: () => context.push(RouteNames.usersList),
                  ),
                  DashboardCard(
                    title: 'Cumulative Complaints',
                    value: '184',
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.statusForwarded,
                    onTap: () => context.push(RouteNames.complaintsList),
                  ),
                  const DashboardCard(
                    title: 'Avg. Resolution Time',
                    value: '2.4 Days',
                    icon: Icons.speed,
                    iconColor: AppColors.statusResolved,
                  ),
                  DashboardCard(
                    title: 'Archived Records',
                    value: '142',
                    icon: Icons.archive_outlined,
                    iconColor: AppColors.textSecondary,
                    onTap: () => context.push(RouteNames.archives),
                  ),
                ],
              ),
              AppSpacing.v24,

              const Text(
                'Administrative Governance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              AppSpacing.v12,
              ProfileTile(
                icon: Icons.manage_accounts_outlined,
                title: 'User Roles & Authority Assignment',
                subtitle: 'Assign Batch Advisers, Coordinators, Office Staff',
                onTap: () => context.push(RouteNames.usersList),
              ),
              ProfileTile(
                icon: Icons.school_outlined,
                title: 'Academic Batches & Section Config',
                subtitle: 'Configure sessions, sections, and advisers',
                onTap: () => context.push(RouteNames.batchManagement),
              ),
              ProfileTile(
                icon: Icons.campaign_outlined,
                title: 'Department Circulars & Broadcasts',
                subtitle: 'Issue announcements to batches and years',
                onTap: () => context.push(RouteNames.createNotice),
              ),
              ProfileTile(
                icon: Icons.archive_outlined,
                title: 'Complaint History & Archives',
                subtitle: 'Search historical resolved and rejected cases',
                onTap: () => context.push(RouteNames.archives),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

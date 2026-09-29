import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/complaint_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/enums/user_role.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/complaints/presentation/providers/complaints_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_quick_action_card.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/dashboard_welcome_banner.dart';
import '../widgets/role_switcher_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? UserRole.student;
    final dashboardState = ref.watch(dashboardProvider);
    final complaintsState = ref.watch(complaintsListProvider);
    final stats = dashboardState.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: RouteNames.dashboard),
      appBar: CustomAppBar(
        title: AppStrings.appName,
        subtitle: AppStrings.departmentName,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
            tooltip: 'Switch Role Preview',
            onPressed: () {
              RoleSwitcherSheet.show(
                context,
                currentRole: role,
                onRoleSelected: (newRole) {
                  ref.read(authProvider.notifier).switchDemoRole(newRole);
                  ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push(RouteNames.notifications),
          ),
        ],
      ),
      floatingActionButton: !role.isStaff
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.submitComplaint),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Complaint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardProvider.notifier).fetchStats();
            await ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppPaddings.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                DashboardWelcomeBanner(
                  userName: user?.fullName ?? 'Student Member',
                  avatarUrl: user?.avatarUrl,
                  role: role,
                ),
                AppSpacing.v20,

                // Statistics Grid
                const Text(
                  'Overview & Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                AppSpacing.v12,
                DashboardStatsGrid(stats: stats, role: role),
                AppSpacing.v24,

                // Quick Navigation Shortcuts
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                AppSpacing.v12,
                Row(
                  children: [
                    if (!role.isStaff) ...[
                      Expanded(
                        child: DashboardQuickActionCard(
                          icon: Icons.add_task,
                          title: 'Lodge Complaint',
                          color: AppColors.primary,
                          onTap: () => context.push(RouteNames.submitComplaint),
                        ),
                      ),
                      AppSpacing.h10,
                    ],
                    Expanded(
                      child: DashboardQuickActionCard(
                        icon: Icons.campaign_outlined,
                        title: 'Notice Board',
                        color: AppColors.accent,
                        onTap: () => context.push(RouteNames.noticeBoard),
                      ),
                    ),
                    AppSpacing.h10,
                    Expanded(
                      child: DashboardQuickActionCard(
                        icon: Icons.school_outlined,
                        title: 'Batch Adviser',
                        color: AppColors.statusInReview,
                        onTap: () => context.push(RouteNames.batchManagement),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v24,

                // Recent Complaints / Queue Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      role.isStaff ? 'Incoming Priority Queue' : 'My Recent Grievances',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.complaintsList),
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                AppSpacing.v8,

                if (complaintsState.isLoading && complaintsState.complaints.isEmpty)
                  const LoadingWidget(message: 'Loading complaints...')
                else if (complaintsState.complaints.isEmpty)
                  EmptyState(
                    title: 'No Complaints Found',
                    message: role.isStaff
                        ? 'Your queue has no pending complaints at this time.'
                        : 'You have not submitted any complaints yet.',
                    actionText: !role.isStaff ? 'Lodge Complaint' : null,
                    onActionPressed: !role.isStaff ? () => context.push(RouteNames.submitComplaint) : null,
                  )
                else
                  ...complaintsState.complaints.take(3).map((complaint) {
                    return ComplaintCard(
                      id: complaint.id,
                      trackingNumber: complaint.trackingNumber,
                      title: complaint.title,
                      description: complaint.description,
                      category: complaint.category,
                      status: complaint.status,
                      priority: complaint.priority,
                      createdAt: complaint.createdAt,
                      studentName: complaint.studentName,
                      batch: complaint.batch,
                      currentHandlerRole: complaint.currentHandlerRole.displayName,
                      onTap: () => context.push(RouteNames.complaintDetailPath(complaint.id)),
                    );
                  }),
                AppSpacing.v40,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

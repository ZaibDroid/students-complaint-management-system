import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/complaint_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../shared/enums/user_role.dart';
import 'package:student_complaint_managment_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:student_complaint_managment_system/features/complaints/presentation/providers/complaints_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _showRoleSwitcher(BuildContext context, WidgetRef ref, UserRole currentRole) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Switch Active Role (Demo / Switcher)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quickly preview the DCMS interface from any role perspective.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UserRole.values.map((role) {
                    final isSelected = currentRole == role;
                    return ChoiceChip(
                      label: Text(role.displayName),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) {
                          ref.read(authProvider.notifier).switchDemoRole(role);
                          ref.read(complaintsListProvider.notifier).fetchComplaints(page: 1);
                          Navigator.pop(ctx);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            onPressed: () => _showRoleSwitcher(context, ref, role),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      UserAvatar(
                        name: user?.fullName ?? 'User',
                        imageUrl: user?.avatarUrl,
                        size: 52,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        textColor: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalam-o-Alaikum,',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            Text(
                              user?.fullName ?? 'Student Member',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role.displayName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Grid
                const Text(
                  'Overview & Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    DashboardCard(
                      title: role.isStaff ? 'Pending Review' : 'Active Grievances',
                      value: stats.pendingComplaints.toString(),
                      icon: Icons.pending_actions,
                      iconColor: AppColors.statusPending,
                      iconBackgroundColor: AppColors.statusPendingLight,
                      onTap: () => context.push(RouteNames.complaintsList),
                    ),
                    DashboardCard(
                      title: 'Forwarded / In-Flow',
                      value: stats.forwardedComplaints.toString(),
                      icon: Icons.forward,
                      iconColor: AppColors.statusForwarded,
                      iconBackgroundColor: AppColors.statusForwardedLight,
                      onTap: () => context.push(RouteNames.complaintsList),
                    ),
                    DashboardCard(
                      title: 'Resolved Complaints',
                      value: stats.resolvedComplaints.toString(),
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.statusResolved,
                      iconBackgroundColor: AppColors.statusResolvedLight,
                      onTap: () => context.push(RouteNames.complaintsList),
                    ),
                    DashboardCard(
                      title: 'Department Notices',
                      value: stats.activeNotices.toString(),
                      icon: Icons.campaign_outlined,
                      iconColor: AppColors.accent,
                      iconBackgroundColor: AppColors.primarySurface,
                      onTap: () => context.push(RouteNames.noticeBoard),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Navigation Shortcuts
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!role.isStaff)
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_task,
                          title: 'Lodge Complaint',
                          color: AppColors.primary,
                          onTap: () => context.push(RouteNames.submitComplaint),
                        ),
                      ),
                    if (!role.isStaff) const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.campaign_outlined,
                        title: 'Notice Board',
                        color: AppColors.accent,
                        onTap: () => context.push(RouteNames.noticeBoard),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.school_outlined,
                        title: 'Batch Adviser',
                        color: AppColors.statusInReview,
                        onTap: () => context.push(RouteNames.batchManagement),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 8),

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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

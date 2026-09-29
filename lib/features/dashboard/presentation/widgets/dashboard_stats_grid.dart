import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../shared/enums/user_role.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

/// Reusable metrics grid for dashboard statistics
class DashboardStatsGrid extends StatelessWidget {
  final DashboardStatsEntity stats;
  final UserRole role;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
    );
  }
}

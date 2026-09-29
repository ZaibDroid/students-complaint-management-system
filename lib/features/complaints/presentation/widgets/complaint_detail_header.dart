import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';

/// Reusable top header card on complaint detail screen
class ComplaintDetailHeader extends StatelessWidget {
  final String title;
  final String category;
  final ComplaintStatus status;
  final PriorityLevel priority;
  final DateTime createdAt;

  const ComplaintDetailHeader({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.all16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r16,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(status: status),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priority.color.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadii.r6,
                ),
                child: Text(
                  '${priority.displayName.toUpperCase()} PRIORITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: priority.color,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v14,
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          AppSpacing.v8,
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 14, color: AppColors.textMuted),
              AppSpacing.h4,
              Text(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
              AppSpacing.h4,
              Text(
                DateFormatter.formatDate(createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

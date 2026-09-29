import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../shared/enums/user_role.dart';

/// Reusable student & handler information card for complaint detail view
class ComplainantInfoCard extends StatelessWidget {
  final String studentName;
  final String? studentAvatarUrl;
  final String? batch;
  final String? section;
  final String? studentEmail;
  final UserRole handlerRole;

  const ComplainantInfoCard({
    super.key,
    required this.studentName,
    this.studentAvatarUrl,
    this.batch,
    this.section,
    this.studentEmail,
    required this.handlerRole,
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
      child: Row(
        children: [
          UserAvatar(name: studentName, imageUrl: studentAvatarUrl, size: 44),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v2,
                Text(
                  'Batch: ${batch ?? 'N/A'} • Section: ${section ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (studentEmail != null)
                  Text(
                    studentEmail!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppBorderRadii.r6,
            ),
            child: Text(
              'Handler: ${handlerRole.displayName}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

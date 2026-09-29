import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/user_management_entity.dart';

/// Reusable user row card in the department directory
class UserTileCard extends StatelessWidget {
  final UserManagementEntity user;
  final VoidCallback onRoleTap;

  const UserTileCard({
    super.key,
    required this.user,
    required this.onRoleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r16,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          UserAvatar(name: user.fullName, size: 44),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v2,
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (user.regNo != null || user.batch != null) ...[
                  AppSpacing.v2,
                  Text(
                    '${user.regNo ?? ''} • ${user.batch ?? ''} • ${user.section ?? ''}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onRoleTap,
            borderRadius: AppBorderRadii.r8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppBorderRadii.r8,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.role.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.h4,
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

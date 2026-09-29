import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../shared/enums/user_role.dart';

/// Reusable user profile header card with avatar, name, email, and role badge
class ProfileUserHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  const ProfileUserHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.all20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r16,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          UserAvatar(
            name: fullName,
            imageUrl: avatarUrl,
            size: 64,
          ),
          AppSpacing.v12,
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v4,
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.v8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppBorderRadii.r20,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              role.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

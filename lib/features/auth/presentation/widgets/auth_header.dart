import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Reusable university and department branding header for all auth screens
class AuthHeader extends StatelessWidget {
  final String? subtitle;

  const AuthHeader({
    super.key,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            padding: AppPaddings.all16,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.account_balance,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        AppSpacing.v16,
        const Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        AppSpacing.v4,
        Text(
          subtitle ?? AppStrings.departmentName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

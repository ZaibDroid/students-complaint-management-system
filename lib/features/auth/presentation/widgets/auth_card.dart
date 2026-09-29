import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Reusable auth card wrapper with consistent styling, paddings, and shadows
class AuthCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AuthCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.all24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadii.r20,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.v4,
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          AppSpacing.v24,
          child,
        ],
      ),
    );
  }
}

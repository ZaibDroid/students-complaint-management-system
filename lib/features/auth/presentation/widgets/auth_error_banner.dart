import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Reusable banner for displaying authentication errors
class AuthErrorBanner extends StatelessWidget {
  final String? errorMessage;

  const AuthErrorBanner({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusRejectedLight,
        borderRadius: AppBorderRadii.r10,
        border: Border.all(
          color: AppColors.statusRejected.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.statusRejected, size: 18),
          AppSpacing.h10,
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.statusRejected,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

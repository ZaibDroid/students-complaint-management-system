import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/notice_target.dart';

/// Reusable dropdown selector for choosing target audience of a notice
class NoticeAudienceSelector extends StatelessWidget {
  final NoticeTarget selectedTarget;
  final ValueChanged<NoticeTarget> onTargetChanged;

  const NoticeAudienceSelector({
    super.key,
    required this.selectedTarget,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Audience',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v6,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadii.r12,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NoticeTarget>(
              isExpanded: true,
              value: selectedTarget,
              items: NoticeTarget.values.map((target) {
                return DropdownMenuItem(
                  value: target,
                  child: Text(target.displayName, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (target) {
                if (target != null) onTargetChanged(target);
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/notice_target.dart';

/// Reusable horizontal filter chips row for Notice Board targets
class NoticeTargetFilterRow extends StatelessWidget {
  final NoticeTarget? selectedTarget;
  final ValueChanged<NoticeTarget?> onTargetChanged;

  const NoticeTargetFilterRow({
    super.key,
    required this.selectedTarget,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Notices'),
            selected: selectedTarget == null,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selectedTarget == null ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onTargetChanged(null),
          ),
          AppSpacing.h8,
          ...NoticeTarget.values.map((target) {
            final isSelected = selectedTarget == target;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(target.displayName),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  onTargetChanged(selected ? target : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

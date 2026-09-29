import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/priority_level.dart';

/// Reusable priority selector pills widget
class PrioritySelector extends StatelessWidget {
  final PriorityLevel selectedPriority;
  final ValueChanged<PriorityLevel> onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PriorityLevel.values.map((priority) {
        final isSelected = selectedPriority == priority;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onPrioritySelected(priority),
              borderRadius: AppBorderRadii.r10,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? priority.color.withValues(alpha: 0.15) : Colors.white,
                  borderRadius: AppBorderRadii.r10,
                  border: Border.all(
                    color: isSelected ? priority.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    priority.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? priority.color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/complaint_status.dart';
import '../../../../shared/enums/priority_level.dart';

/// Reusable active filters bar with removable chips
class ActiveFiltersBar extends StatelessWidget {
  final ComplaintStatus? selectedStatus;
  final PriorityLevel? selectedPriority;
  final VoidCallback onClearStatus;
  final VoidCallback onClearPriority;

  const ActiveFiltersBar({
    super.key,
    this.selectedStatus,
    this.selectedPriority,
    required this.onClearStatus,
    required this.onClearPriority,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedStatus == null && selectedPriority == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('Filtered by: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (selectedStatus != null)
            Chip(
              label: Text(selectedStatus!.displayName, style: const TextStyle(fontSize: 11)),
              backgroundColor: selectedStatus!.backgroundColor,
              onDeleted: onClearStatus,
            ),
          AppSpacing.h6,
          if (selectedPriority != null)
            Chip(
              label: Text(selectedPriority!.displayName, style: const TextStyle(fontSize: 11)),
              backgroundColor: selectedPriority!.color.withValues(alpha: 0.15),
              onDeleted: onClearPriority,
            ),
        ],
      ),
    );
  }
}

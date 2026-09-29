import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/user_role.dart';

/// Reusable horizontal choice chips row for filtering user roles
class UserRoleFilterRow extends StatelessWidget {
  final UserRole? selectedRole;
  final ValueChanged<UserRole?> onRoleChanged;

  const UserRoleFilterRow({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Roles'),
            selected: selectedRole == null,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selectedRole == null ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onRoleChanged(null),
          ),
          AppSpacing.h8,
          ...UserRole.values.map((role) {
            final isSelected = selectedRole == role;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(role.displayName),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  onRoleChanged(selected ? role : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

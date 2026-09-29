import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/user_role.dart';

/// Reusable modal sheet for role preview and switching
class RoleSwitcherSheet extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleSelected;

  const RoleSwitcherSheet({
    super.key,
    required this.currentRole,
    required this.onRoleSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required UserRole currentRole,
    required ValueChanged<UserRole> onRoleSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RoleSwitcherSheet(
        currentRole: currentRole,
        onRoleSelected: onRoleSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppPaddings.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Active Role (Demo / Switcher)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v4,
            const Text(
              'Quickly preview the DCMS interface from any role perspective.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            AppSpacing.v16,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserRole.values.map((role) {
                final isSelected = currentRole == role;
                return ChoiceChip(
                  label: Text(role.displayName),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (val) {
                    if (val) {
                      Navigator.pop(context);
                      onRoleSelected(role);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

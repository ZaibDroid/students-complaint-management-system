import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/enums/user_role.dart';

/// Reusable modal dialog for assigning user roles
class RoleAssignmentDialog extends StatefulWidget {
  final String userName;
  final UserRole initialRole;
  final ValueChanged<UserRole> onRoleSaved;

  const RoleAssignmentDialog({
    super.key,
    required this.userName,
    required this.initialRole,
    required this.onRoleSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    required UserRole currentRole,
    required ValueChanged<UserRole> onRoleSaved,
  }) {
    return showDialog(
      context: context,
      builder: (_) => RoleAssignmentDialog(
        userName: userName,
        initialRole: currentRole,
        onRoleSaved: onRoleSaved,
      ),
    );
  }

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  late UserRole _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadii.r16),
      title: Text('Assign Role: ${widget.userName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            final isSelected = _selected == role;
            return InkWell(
              onTap: () => setState(() => _selected = role),
              borderRadius: AppBorderRadii.r8,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySurface : Colors.transparent,
                  borderRadius: AppBorderRadii.r8,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 20,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                    AppSpacing.h10,
                    Text(
                      role.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadii.r8),
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onRoleSaved(_selected);
          },
          child: const Text('Save Role'),
        ),
      ],
    );
  }
}

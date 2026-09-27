import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../shared/enums/user_role.dart';

/// Atomic Reusable Role Badge
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final double fontSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (role) {
      case UserRole.student:
        bg = AppColors.primarySurface;
        fg = AppColors.primary;
        break;
      case UserRole.cr:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        break;
      case UserRole.batchAdviser:
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF15803D);
        break;
      case UserRole.coordinator:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        break;
      case UserRole.chairman:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case UserRole.officeStaff:
      case UserRole.dean:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case UserRole.admin:
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFFE11D48);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

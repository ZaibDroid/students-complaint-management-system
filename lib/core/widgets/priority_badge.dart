import 'package:flutter/material.dart';
import '../../shared/enums/priority_level.dart';

/// Atomic Reusable Priority Chip
class PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;
  final double fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: priority.color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}

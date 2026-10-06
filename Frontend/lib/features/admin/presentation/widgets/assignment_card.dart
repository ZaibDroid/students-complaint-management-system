import 'package:flutter/material.dart';
import '../../domain/entities/adviser_assignment.dart';

class AssignmentCard extends StatelessWidget {
  final AdviserAssignment assignment;
  final VoidCallback onTapAction;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAdviser = assignment.adviserName != null && assignment.adviserName!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Semester & Section Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    assignment.semester,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sec ${assignment.section}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Adviser Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Adviser',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasAdviser ? assignment.adviserName! : 'Not Assigned',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasAdviser ? const Color(0xFF010F32) : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            ElevatedButton(
              onPressed: onTapAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAdviser ? theme.primaryColor : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: Text(
                hasAdviser ? 'Change' : 'Assign',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
